#!/bin/sh

# Delay until the server is fully started
sh ./start_delay.sh

# Install custom rules and decoders
sh ./rule_decoder_installer.sh