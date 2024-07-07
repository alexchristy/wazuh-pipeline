#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"
. "$PIPELINE_REPO_PATH/constants.sh"

# =====( MAIN )===== #

# Configure wazuh log test to scale the number of threads
# with the number of CPUs available to the container
if ! update_threads_tag "$WAZUH_SETTINGS"; then
    exit "$ERR_LVL"
fi

# Count CPUs to pass as threads arg
# for WazuhTest
num_cpus=$(count_logical_cpus)

if [ "$num_cpus" -lt 0 ]; then
    exit "$EXIT_ERR"
fi

# Host set to localhost since we are running tests from
# within the manager container itself
#
# Username and password are the default for the wazuh/wazuh-manager container on docker hub
WazuhTest -d "$PIPELINE_REPO_PATH/tests" -t "$num_cpus" -u "wazuh" -p "wazuh" -v 127.0.0.1 > "$WAZUH_TEST_LOG" 2>&1
passed=$?

cat "$WAZUH_TEST_LOG"

exit "$passed"