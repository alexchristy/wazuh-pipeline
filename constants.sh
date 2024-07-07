#!/bin/sh
# =====( CONSTANTS )===== #

# Wazuh 
export WAZUH_USER="wazuh"
export WAZUH_HOME="/var/ossec"
export WAZUH_GROUP="wazuh"
export WAZUH_SETTINGS="$WAZUH_HOME/etc/ossec.conf"
export WAZUH_BIN="$WAZUH_HOME/bin"
export DEFAULT_DECODERS_PREFIX="ruleset/decoders"
export DEFAULT_DECODERS_HOME="$WAZUH_HOME/$DEFAULT_DECODERS_PREFIX"
export DEFAULT_RULES_PREFIX="ruleset/rules"
export DEFAULT_RULES_HOME="$WAZUH_HOME/$DEFAULT_RULES_PREFIX"
export CUSTOM_DECODERS_HOME="$WAZUH_HOME/etc/decoders"
export CUSTOM_RULES_HOME="$WAZUH_HOME/etc/rules"

# Logging
export SCRIPT_NAME="wazuh_pipeline"
export LOG_PATH="./$SCRIPT_NAME" # Default log path
export SCRIPT_LOG=$LOG_PATH"_script.log"
export SHELL_LOG=$LOG_PATH"_shell.log"
export WAZUH_TEST_LOG=$LOG_PATH"_wazuh_test.log"
export INFO_LVL="INFO"
export WARN_LVL="WARNING"
export ERR_LVL="ERROR"
export EXIT_ERR=1
export EXIT_SUCCESS=0

# PIPELINE VARIABLES
export PIPELINE_REPO_PATH="/root/wazuh_pipeline"
export REPO_DECODERS="$PIPELINE_REPO_PATH/decoders"
export REPO_RULES="$PIPELINE_REPO_PATH/rules"

# GLOBALS
export DISABLED_DECODERS=false
export HAVE_CUSTOM_RULES=false
export HAVE_CUSTOM_DECODERS=false