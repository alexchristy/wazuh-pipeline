#!/bin/sh

# ====( CONSTANTS )==== #
PIPELINE_REPO_PATH="/root/wazuh_pipeline"

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
if ! sh ./constants.sh; then
    exit "$EXIT_ERR"
fi

# Update the pipeline repo
log_message "$INFO_LVL" "Checking for updates to pipeline repo..."
if ! sh ./git_update.sh; then
    exit "$EXIT_ERR"
fi

# Delay until the server is fully started
log_message "$INFO_LVL" "Waiting for wazuh manager to start up..."
if ! sh ./start_delay.sh; then
    exit "$EXIT_ERR"
fi

# Install custom rules and decoders
log_message "$INFO_LVL" "Installing custom rules and decoders..."
if ! sh ./rule_decoder_installer.sh; then
    exit "$EXIT_ERR"
fi

# Run tests
log_message "$INFO_LVL" "Running tests..."
if ! sh ./run_tests.sh; then
    exit "$EXIT_ERR"
fi

# Keep container running
tail -f /dev/null