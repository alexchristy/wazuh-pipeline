#!/bin/sh


# =====( CONSTANTS )===== #

# Wazuh 
WAZUH_HOME="/var/ossec"
WAZUH_USER="wazuh"
WAZUH_GROUP="wazuh"
WAZUH_SETTINGS="$WAZUH_HOME/etc/ossec.conf"
WAZUH_BIN="$WAZUH_HOME/bin"
DEFAULT_DECODERS_PREFIX="ruleset/decoders"
DEFAULT_DECODERS_HOME="$WAZUH_HOME/$DEFAULT_DECODERS_PREFIX"
DEFAULT_RULES_PREFIX="ruleset/rules"
DEFAULT_RULES_HOME="$WAZUH_HOME/$DEFAULT_RULES_PREFIX"
CUSTOM_DECODERS_HOME="$WAZUH_HOME/etc/decoders"
CUSTOM_RULES_HOME="$WAZUH_HOME/etc/rules"

# Logging
SCRIPT_NAME=$(basename "$0" | sed 's/\.[^.]*$//')
LOG_PATH="./$SCRIPT_NAME" # Default log path
SCRIPT_LOG=$LOG_PATH"_script.log"
SHELL_LOG=$LOG_PATH"_shell.log"
INFO_LVL="INFO"
WARN_LVL="WARNING"
ERR_LVL="ERROR"
EXIT_ERR=1
EXIT_SUCCESS=0

# PIPELINE VARIABLES
REPO_DECODERS=$(pwd)"/decoders"
REPO_RULES=$(pwd)"/rules"

# GLOBALS
DISABLED_DECODERS=false

# =====( ARGUMENTS )===== #
usage() {
  echo "Usage: $0 [args] [-h]"
  echo "  -$LOG_PATH_ARG    Output directory for log files."
  exit $EXIT_ERR
}

# =====( LOGGING FUNCTIONS )===== #
setup_logging() {
  # Create the log file if it doesn't exist
  if [ ! -f "$SCRIPT_LOG" ]; then
    touch "$SCRIPT_LOG"
    log_message $INFO_LVL "Created script log file: $SCRIPT_LOG"
  fi

  # Create the shell log file if it doesn't exist
  if [ ! -f "$SHELL_LOG" ]; then
    touch "$SHELL_LOG"
    log_message $INFO_LVL "Created shell log file: $SHELL_LOG"
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
    log_message $ERR_LVL "$_run_command_failure_msg"
    exit $EXIT_ERR
  fi
}

# =====( PERMISSIONS FUNCTIONS )===== #
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        log_message $INFO_LVL "Verfied root level permissions"
        return 0
    else
        log_message $ERR_LVL "Not running as root."
        return 1
    fi
}

# =====( FILESYSTEM FUNCTIONS )===== #
check_dir_exists() {
  _check_dir_exists_dir_path="$1"
  if [ -d "$_check_dir_exists_dir_path" ]; then
    log_message $INFO_LVL "Directory '$_check_dir_exists_dir_path' exists."
    return 0
  else
    log_message $ERR_LVL "Directory '$_check_dir_exists_dir_path' does not exist."
    return 1
  fi
}

# =====( WAZUH FUNCTIONS )===== #
restart_wazuh() {
  log_message $INFO_LVL "Restarting Wazuh server..."
  
  # Redirect both stdout and stderr to tee to log and display
  if "$WAZUH_BIN/wazuh-control" restart -v 2>&1 | tee -a "$SCRIPT_LOG"; then
    log_message $INFO_LVL "Successfully restarted Wazuh server."
  else
    log_message $ERR_LVL "Failed to restart Wazuh server."
    exit $EXIT_ERR
  fi
}

add_ruleset_config() {
    _add_ruleset_config_config_file="$WAZUH_SETTINGS"
    _add_ruleset_config_config_str="$1"

    if [ ! -f "$_add_ruleset_config_config_file" ]; then
        log_message $ERR_LVL "File '$_add_ruleset_config_config_file' not found."
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
        log_message $ERR_LVL "Failed to process file with awk."
        rm "$temp_file"
        return 1
    fi

    # Backup the original file
    # Check if backup succeeded
    if cp "$_add_ruleset_config_config_file" "$_add_ruleset_config_config_file.bak"; then
      log_message $INFO_LVL "Created backup of '$_add_ruleset_config_config_file'."
    else
        echo "Error: Failed to create backup of '$_add_ruleset_config_config_file'."
        rm "$temp_file"
        return 1
    fi

    # Replace the original file with the modified one
    # Check if move succeeded
    if mv "$temp_file" "$_add_ruleset_config_config_file"; then
      log_message $INFO_LVL "Successfully updated '$_add_ruleset_config_config_file'."
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

# =====( MAIN )===== #

# TODO: Make arg parsing function

# Logging
setup_logging

# Ensure that we have root permissions
# so that we can modify the /var/ossec dir
if ! check_root; then
  exit $EXIT_ERR
fi

# Check all proper directories exist
if ! check_dir_exists $WAZUH_HOME; then
  exit $EXIT_ERR
fi

if ! check_dir_exists $DEFAULT_RULES_HOME; then
  exit $EXIT_ERR
fi

if ! check_dir_exists $DEFAULT_DECODERS_HOME; then
  exit $EXIT_ERR
fi

if ! check_dir_exists $CUSTOM_RULES_HOME; then
  exit $EXIT_ERR
fi

if ! check_dir_exists $CUSTOM_DECODERS_HOME; then
  exit $EXIT_ERR
fi

# Copy over the custom rules and decoders
run_command "cp ""$REPO_RULES""/* $CUSTOM_RULES_HOME" "Failed to copy custom rule files from $REPO_RULES to $CUSTOM_RULES_HOME"
run_command "chmod -R 660 $CUSTOM_RULES_HOME/*.xml" "Failed to set 660 permissions on rule files in $CUSTOM_RULES_HOME"
run_command "chown $WAZUH_USER:$WAZUH_GROUP -R $CUSTOM_RULES_HOME/*.xml" "Failed to chown rule files in $CUSTOM_RULES_HOME"
log_message $INFO_LVL "Successfully copied over custom rules."

run_command "cp ""$REPO_DECODERS""/* $CUSTOM_DECODERS_HOME" "Failed to copy custom decoder files from $REPO_DECODERS to $CUSTOM_DECODERS_HOME"
run_command "chmod -R 660 $CUSTOM_DECODERS_HOME/*.xml" "Failed to set 660 permissions on decoder files in $CUSTOM_DECODERS_HOME"
run_command "chown $WAZUH_USER:$WAZUH_GROUP -R $CUSTOM_DECODERS_HOME/*.xml" "Failed to chown rule files in $CUSTOM_DECODERS_HOME"
log_message $INFO_LVL "Successfully copied over custom decoders."

# Temporary file to store the results
tmpfile=$(mktemp) || exit 1
dedup_tmpfile=$(mktemp) || exit 1
disable_tmpfile=$(mktemp) || exit 1

# Ensure the temporary files are removed on script exit
trap 'rm -f "$tmpfile" "$dedup_tmpfile" "$disable_tmpfile"' EXIT

# Collect decoders from the repository files
for file in "$REPO_DECODERS"/*; do
  grep -oP '<decoder.*?>' "$file" >> "$tmpfile"
done

# Deduplicate the decoders and store them in a second temporary file
sort -u "$tmpfile" > "$dedup_tmpfile"

# Create a file descriptor for reading the deduplicated decoders
exec 3< "$dedup_tmpfile"

# Flag to track if any decoder is disabled
DISABLED_DECODERS=false

# Collect the default decoders that need to be disabled
while IFS= read -r decoder <&3; do
  echo "Processing decoder: $decoder" # Debug statement
  # Capture the list of default decoders that collide with our custom decoders
  tmpfile2=$(mktemp) || exit 1
  trap 'rm -f "$tmpfile2"' EXIT

  grep -R "$decoder" "$DEFAULT_DECODERS_HOME" | awk -F: '{print $1}' | sort -u >> "$disable_tmpfile"

  rm -f "$tmpfile2"
done

# Close the file descriptor
exec 3<&-

# Deduplicate the list of default decoders to disable
sort -u "$disable_tmpfile" > "$dedup_tmpfile"

# Create a file descriptor for reading the finalized list of default decoders to disable
exec 4< "$dedup_tmpfile"

# Process the deduplicated list of default decoders
while IFS= read -r def_decoder <&4; do
  echo "Disabling default decoder: $def_decoder" # Debug statement
  if [ "$DISABLED_DECODERS" = false ]; then
    DISABLED_DECODERS=true
  fi

  partial_decoder_path=${def_decoder#"$WAZUH_HOME/"}
  exclusion_line="    <decoder_exclude>$partial_decoder_path</decoder_exclude>"
  if add_ruleset_config "$exclusion_line"; then
    log_message $INFO_LVL "Successfully added decoder exclusion: $exclusion_line"
  else
    log_message $ERR_LVL "Failed to add decoder exclusion: $exclusion_line"
    exit $EXIT_ERR
  fi
done

# Close the file descriptor
exec 4<&-

# Set the correct permissions on the new config file
run_command "chgrp $WAZUH_GROUP $WAZUH_SETTINGS" "Failed to change $WAZUH_SETTINGS file to the $WAZUH_GROUP."
run_command "chmod 660 $WAZUH_SETTINGS" "Failed to add RW permissions to $WAZUH_SETTINGS for the $WAZUH_GROUP group."

# Clean up the temporary files
rm -f "$tmpfile" "$dedup_tmpfile" "$disable_tmpfile"

# Restart Wazuh
restart_wazuh

# Exit successfully
exit $EXIT_SUCCESS