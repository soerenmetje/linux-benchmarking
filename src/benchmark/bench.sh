#!/bin/bash
# Script should be execute on the server by main.sh

set -x # Print each command before execution
set -e # fail and abort script if one command fails
set -o pipefail

if [ -z "$MACHINE" ]; then
    echo "Missing argument: MACHINE is not specified" >&2
    exit 1
fi

if [ -z "$BENCHMARK" ]; then
    echo "Missing argument: BENCHMARK is not specified" >&2
    exit 1
fi

export ITERATIONS=10

cd /home/$USER/benchmark/ || exit 1

# Load parse and init functions
source ./common/parse.sh


# Create dirs in case not already exist
mkdir -p logs/
mkdir -p data/

# Empty dirs
rm -rf logs/*
rm -rf data/*

fileResult="./data/temp.csv"

# Create and init temporary result file
initResultFile > "$fileResult" || (echo "Failed to init result file. No benchmark found for '$BENCHMARK'" >&2 && exit 1)

for (( i=0; i<ITERATIONS; i++ )); do
  echo "Starting interation $i / $ITERATIONS ..."

  fileLog="./logs/$(printf "log%03d.txt" $i)"

  # Store stdout and stderr in file, but keep console output. Source: https://unix.stackexchange.com/a/362452
  /bin/bash "$PWD/workloads/workload-$BENCHMARK.sh"  2>&1 | tee "$fileLog"

  parseLogFile "$fileLog" >> "$fileResult" || (echo "Failed to parse log file. No benchmark found for '$BENCHMARK'" >&2 && exit 1)

  # Give resources some time to recover - e.g. CPU to cool down (fair for comparison with other projects that have greater startup time)
  sleep 10
done

# Clean files
rm ./tmp/* || echo "Failed to delete temporary files in directory tmp"