#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"

# =====( MAIN )===== #
setup_logging

echo "Starting wazuh manager..."
/init &

# Load in constants
echo "Setting up enviroment..."
sh ./constants.sh

# Delay until the server is fully started
echo "Waiting for wazuh manager to start up..."
sh ./start_delay.sh

# Install custom rules and decoders
echo "Installing custom rules and decoders..."
sh ./rule_decoder_installer.sh

# Run tests
sh ./run_tests.sh

# Keep container running
tail -f /dev/null