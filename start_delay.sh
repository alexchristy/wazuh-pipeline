#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"

# =====( MAIN )===== #

MAX_ATTEMPTS=120
DELAY=1

# Wazuh ports
PORTS="55000 1514 1515"

check_ports() {
    for port in $PORTS; do
        if ! ss -tulpn | grep -q ":$port"; then
            return 1
        fi
    done
    return 0
}

attempt=0

while [ $attempt -lt $MAX_ATTEMPTS ]; do
    if check_ports; then
        log_message "$INFO_LVL" "Success: All ports are listening."
        exit "$EXIT_SUCCESS"
    fi

    attempt=$((attempt + 1))

    sleep $DELAY
done

log_message "$ERR_LVL" "Failure: Not all ports are listening after $MAX_ATTEMPTS attempts."
exit "$EXIT_ERR"