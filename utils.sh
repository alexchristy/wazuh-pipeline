#!/bin/sh


# =====( LOGGING FUNCTIONS )===== #
setup_logging() {
  # Create the log file if it doesn't exist
  if [ ! -f "$SCRIPT_LOG" ]; then
    touch "$SCRIPT_LOG"
    log_message "$INFO_LVL" "Created script log file: $SCRIPT_LOG"
  fi

  # Create the shell log file if it doesn't exist
  if [ ! -f "$SHELL_LOG" ]; then
    touch "$SHELL_LOG"
    log_message "$INFO_LVL" "Created shell log file: $SHELL_LOG"
  fi

  # Enable shell logging
  exec 2>>"$SHELL_LOG"
  set -x
}

log_message() {
    _log_message_level="$1"
    _log_message_log_msg="$2"
    _log_message_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    _log_message_formatted_msg="$_log_message_timestamp - $_log_message_level: $_log_message_log_msg"

    # Log to the log file without color
    echo "$_log_message_formatted_msg" >> "$SCRIPT_LOG"

    # Print to terminal with color if appropriate
    case "$_log_message_level" in
        "$INFO_LVL")
            echo "$_log_message_formatted_msg"
            ;;
        "$WARN_LVL")
            printf "%s%s\033[1;33m%s\033[0m\n" "$_log_message_timestamp" " - $_log_message_level: " "$_log_message_log_msg"
            ;;
        "$ERR_LVL")
            printf "%s%s\033[1;31m%s\033[0m\n" "$_log_message_timestamp" " - $_log_message_level: " "$_log_message_log_msg"
            ;;
        *)
            echo "$_log_message_timestamp - $_log_message_level: Invalid log level: $_log_message_level" >> "$SCRIPT_LOG"
            exit 1
            ;;
    esac
}

run_command() {
  _run_command_command=$1
  _run_command_failure_msg=$2

  if ! eval "$_run_command_command"; then
    log_message "$ERR_LVL" "$_run_command_failure_msg"
    exit "$EXIT_ERR"
  fi
}

# =====( PERMISSIONS FUNCTIONS )===== #
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        log_message "$INFO_LVL" "Verfied root level permissions"
        return 0
    else
        log_message "$ERR_LVL" "Not running as root."
        return 1
    fi
}

# =====( FILESYSTEM FUNCTIONS )===== #
check_dir_exists() {
  _check_dir_exists_dir_path="$1"
  if [ -d "$_check_dir_exists_dir_path" ]; then
    log_message "$INFO_LVL" "Directory '$_check_dir_exists_dir_path' exists."
    return 0
  else
    log_message "$ERR_LVL" "Directory '$_check_dir_exists_dir_path' does not exist."
    return 1
  fi
}

has_xml_files() {
    directory="$1"

    # Check if the path exists
    if [ ! -e "$directory" ]; then
        log_message "$ERR_LVL" "The path '$directory' does not exist."
        return 1
    fi

    # Check if the path is a directory
    if [ ! -d "$directory" ]; then
        log_message "$ERR_LVL" "The path '$directory' is not a directory."
        return 1
    fi

    # Check for .xml files in the directory
    if ls "$directory"/*.xml >/dev/null 2>&1; then
        log_message "$INFO_LVL" "XML files found in the directory '$directory'."
        return 0
    else
        log_message "$INFO_LVL" "No XML files found in the directory '$directory'."
        return 1
    fi
}

# =====( WAZUH FUNCTIONS )===== #
restart_wazuh() {
  log_message "$INFO_LVL" "Restarting Wazuh server..."
  
  # Redirect both stdout and stderr to tee to log and display
  if "$WAZUH_BIN/wazuh-control" restart -v 2>&1 | tee -a "$SCRIPT_LOG"; then
    log_message "$INFO_LVL" "Successfully restarted Wazuh server."
  else
    log_message "$ERR_LVL" "Failed to restart Wazuh server."
    exit "$EXIT_ERR"
  fi
}

add_ruleset_config() {
    _add_ruleset_config_config_file="$WAZUH_SETTINGS"
    _add_ruleset_config_config_str="$1"

    if [ ! -f "$_add_ruleset_config_config_file" ]; then
        log_message "$ERR_LVL" "File '$_add_ruleset_config_config_file' not found."
        return 1
    fi

    # Create a temporary file
    temp_file=$(mktemp)

    awk -v _add_ruleset_config_config_str="$_add_ruleset_config_config_str" '
    BEGIN {
        # Flag to indicate if inside ruleset tag
        inside_ruleset = 0
    }

    {
        if ($0 ~ /<ruleset>/) {
            inside_ruleset = 1
        }

        # Print the line
        if (inside_ruleset && $0 ~ /<\/ruleset>/) {
            print _add_ruleset_config_config_str
            inside_ruleset = 0
        }
        
        print $0
    }' "$_add_ruleset_config_config_file" > "$temp_file"

    # Check if awk succeeded
    # shellcheck disable=SC2181 # Disabled because the awk command lengthy
    if [ $? -ne 0 ]; then
        log_message "$ERR_LVL" "Failed to process file with awk."
        rm "$temp_file"
        return 1
    fi

    # Backup the original file
    # Check if backup succeeded
    if cp "$_add_ruleset_config_config_file" "$_add_ruleset_config_config_file.bak"; then
      log_message "$INFO_LVL" "Created backup of '$_add_ruleset_config_config_file'."
    else
        echo "Error: Failed to create backup of '$_add_ruleset_config_config_file'."
        rm "$temp_file"
        return 1
    fi

    # Replace the original file with the modified one
    # Check if move succeeded
    if mv "$temp_file" "$_add_ruleset_config_config_file"; then
      log_message "$INFO_LVL" "Successfully updated '$_add_ruleset_config_config_file'."
    else
        echo "Error: Failed to update '$_add_ruleset_config_config_file'."
        mv "$_add_ruleset_config_config_file.bak" "$_add_ruleset_config_config_file"
        rm "$temp_file"
        return 1
    fi
 

    echo "New strings inserted successfully."

    # Clean up temporary file if it still exists
    [ -f "$temp_file" ] && rm "$temp_file"

    return 0
}

# Function to update the <threads> tag value to "auto"
update_threads_tag() {
    _update_threads_tag_file_path="$1"

    # Check if the file exists
    if [ ! -f "$_update_threads_tag_file_path" ]; then
        log_message "$ERR_LVL" "Error: The file '$_update_threads_tag_file_path' does not exist."
        return 1
    fi

    # Use sed to update the <threads> tag value to "auto"
    sed -i 's|<threads>.*</threads>|<threads>auto</threads>|' "$_update_threads_tag_file_path"

    # Check if the sed command was successful
    # shellcheck disable=SC2181 # Sed command too long to put directly into if statement
    if [ $? -ne 0 ]; then
        log_message "$ERR_LVL" "Error: Failed to update the <threads> tag in '$_update_threads_tag_file_path'."
        return 1
    fi

    log_message "$INFO_LVL" "Successfully updated the <threads> tag in '$_update_threads_tag_file_path'."
    return 0
}

# ====( MISC FUNCTIONS )==== #
count_logical_cpus() {
    if [ -f /proc/cpuinfo ]; then
        _count_logical_cpus_num_cpus=$(grep -c ^processor /proc/cpuinfo)
        log_message "$INFO_LVL" "Successfully determined the number of CPUs."
        echo "$_count_logical_cpus_num_cpus"
    else
        log_message "$INFO_LVL" "Unable to determine the number of CPUs. /proc/cpuinfo not found."
        return 1
    fi
}