#!/bin/sh

MAX_ATTEMPTS=10
DELAY=5

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
        echo "Success: All ports are listening."
        exit 0
    fi

    attempt=$((attempt + 1))

    sleep $DELAY
done

echo "Failure: Not all ports are listening after $MAX_ATTEMPTS attempts."
exit 1