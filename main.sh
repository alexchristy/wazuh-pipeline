#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"
. "$PIPELINE_REPO_PATH/constants.sh"

# =====( MAIN )===== #
setup_logging

log_message "$INFO_LVL" "Starting wazuh manager..."
/init &

# Load in constants
log_message "$INFO_LVL" "Setting up enviroment..."
sh ./constants.sh

# Update the pipeline repo
log_message "$INFO_LVL" "Checking for updates to pipeline repo..."
sh ./git_update.sh

# Delay until the server is fully started
log_message "$INFO_LVL" "Waiting for wazuh manager to start up..."
sh ./start_delay.sh

# Install custom rules and decoders
log_message "$INFO_LVL" "Installing custom rules and decoders..."
sh ./rule_decoder_installer.sh

# Run tests
log_message "$INFO_LVL" "Running tests..."
sh ./run_tests.sh

# Keep container running
tail -f /dev/null