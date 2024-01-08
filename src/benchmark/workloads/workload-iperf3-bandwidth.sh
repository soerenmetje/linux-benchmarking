#!/bin/bash
# Docs:
# - https://iperf.fr/iperf-doc.php#3doc
# - https://docs.nvidia.com/networking-ethernet-software/knowledge-base/Configuration-and-Usage/Monitoring/Throughput-Testing-and-Troubleshooting/

set -x # Print each command before execution

MAX_RETRIES=30
RETRY_COUNT=0

echo "Benchmarking network upload bandwidth"
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # Run the iperf3 command
    echo "Running iperf3 (attempt $((RETRY_COUNT+1)) / $MAX_RETRIES)..."

    # List of existing test servers: https://github.com/R0GGER/public-iperf3-servers#europe
    # Test upload: Server to test server
    iperf3 --json -c a400.speedtest.wobcom.de -i 1 -t 10

    # Check the exit status of the iperf3 command
    if [ $? -eq 0 ]; then
        echo "iperf3 command successful."
        break
    else
        echo "iperf3 command failed. Retrying..."
        RETRY_COUNT=$((RETRY_COUNT+1))
        sleep 3
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Exceeded maximum retries. iperf3 command did not succeed."
fi

RETRY_COUNT=0


echo "Benchmarking network download bandwidth"
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # Run the iperf3 command
    echo "Running iperf3 (attempt $((RETRY_COUNT+1)) / $MAX_RETRIES)..."

    # List of existing test servers: https://github.com/R0GGER/public-iperf3-servers#europe
    # Test upload: Server to test server
    iperf3 --json -c a400.speedtest.wobcom.de -R -i 1 -t 10

    # Check the exit status of the iperf3 command
    if [ $? -eq 0 ]; then
        echo "iperf3 command successful."
        break
    else
        echo "iperf3 command failed. Retrying..."
        RETRY_COUNT=$((RETRY_COUNT+1))
        sleep 3
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Exceeded maximum retries. iperf3 command did not succeed."
fi
