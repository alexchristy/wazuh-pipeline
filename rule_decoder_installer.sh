#!/bin/sh


# =====( CONSTANTS )===== #

# Wazuh 
WAZUH_HOME="/var/ossec"
WAZUH_USER="wazuh"
WAZUH_GROUP="wazuh"
WAZUH_BIN="$WAZUH_HOME/bin"
DEFAULT_DECODERS_HOME="$WAZUH_HOME/ruleset/decoders"
DEFAULT_RULES_HOME="$WAZUH_HOME/ruleset/rules"
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
  if service wazuh-manager restart 2>&1 | tee -a "$SCRIPT_LOG"; then
    log_message $INFO_LVL "Successfully restarted Wazuh server."
  else
    log_message $ERR_LVL "Failed to restart Wazuh server."
    exit $EXIT_ERR
  fi
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

# Check for duplicated decoders
for file in "$REPO_DECODERS"/*; do
  echo "$file"
done

# restart_wazuh

# Exit
exit $EXIT_SUCCESS