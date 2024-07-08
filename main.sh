#!/bin/sh

# ====( FUNCTIONS )==== #
usage() {
    echo "Usage: $0 [-i]"
    echo "  -i    Run the container in interactive mode."
    exit 1
}

parse_args() {
    INTERACTIVE_MODE=false
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -i)
                INTERACTIVE_MODE=true
                shift
                ;;
            *)
                usage
                ;;
        esac
    done
}

# ====( CONSTANTS )==== #
PIPELINE_REPO_PATH="/root/wazuh_pipeline"

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"
. "$PIPELINE_REPO_PATH/constants.sh"

# =====( MAIN )===== #
setup_logging

# Parse arguments
parse_args "$@"

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
passed=$(sh ./run_tests.sh)

if [ "$INTERACTIVE_MODE" = true ]; then
    log_message "$INFO_LVL" "Running in interactive mode"
    /bin/sh
else
    if ! $passed; then
        exit "$EXIT_ERR"
    fi
fi

exit "$EXIT_SUCCESS"