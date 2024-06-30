#!/bin/sh

echo "Starting wazuh manager..."
/init &

# Delay until the server is fully started
echo "Waiting for wazuh manager to start up..."
sh ./start_delay.sh

# Install custom rules and decoders
echo "Installing custom rules and decoders..."
sh ./rule_decoder_installer.sh

# Keep container running
tail -f /dev/null