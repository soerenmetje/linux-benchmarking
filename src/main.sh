#!/bin/bash
# Script to run a variety of benchmarks on several projects
# Run Script on local computer/laptop from project root.
# Parameters:
# - user@server
# - benchmark
#
# /bin/bash src/main.sh cloud 141.5.100.173 sysbench-cpu


set -e # fail and abort script if one command fails
set -o pipefail


if [ -z "$1" ]; then
    echo "Missing argument: user is not specified" >&2
    exit 1
fi

if [ -z "$2" ]; then
    echo "Missing argument: server is not specified" >&2
    exit 1
fi

if [ -z "$3" ]; then
    echo "Missing argument: machine description is not specified" >&2
    exit 1
fi

if [ -z "$4" ]; then
    echo "Missing argument: benchmark is not specified. Pass one of the following values [sysbench-cpu sysbench-memory fio-diskrnd fio-diskseq iperf3-bandwidth]" >&2
    exit 1
fi

export SERVER_USER=$1
export SERVER=$2
export MACHINE=$3
export BENCHMARK=$4


# Find out and returns the next benchmark number. This can be used for the next result file.
# Expects a directory to result files as a parameter.
# E.g. if following files already exit 000.csv 001.csv
# the next benchmark number is 2
function getNextBenchmarkNumber() {
  local resultDir=${1:?} # parameter is mandatory

  # Source: https://stackoverflow.com/a/76573714/14355362
  local entries=("$resultDir"/*)
  [[ ${entries[0]} == "$resultDir/*" ]] && unset entries[0]

  local num
  if [ ${#entries[@]} != 0 ]; then
    num=$(basename "${entries[-1]}" | sed -e s/[^0-9]//g)
    num=$((num+1))
  else
    # No result files yet
    num=0
  fi
  # Return
  echo $num
}

dirResult="data/$BENCHMARK/$MACHINE"
mkdir -p "$dirResult"

benchmarkNumber=$(getNextBenchmarkNumber "$dirResult")
# Source: https://stackoverflow.com/a/18460742/14355362
fileResult=$(printf "$dirResult/%03d.csv" $benchmarkNumber)
echo "Result file: $fileResult"

dirLogs=$(printf "./logs/$BENCHMARK/$MACHINE/%03d/" $benchmarkNumber)
mkdir -p "$dirLogs"

# Start benchmarking
# Run setup script on server using SSH
# Source: https://stackoverflow.com/a/76544706/14355362
cat src/benchmark/setup.sh | ssh -i "$HOME/.ssh/id_rsa" $SERVER_USER@$SERVER bash -s

# Copy the benchmark scripts using scp
scp -r -i "$HOME/.ssh/id_rsa" src/benchmark/* $SERVER_USER@$SERVER:/home/$SERVER_USER/benchmark

# Run benchmark script on server using SSH
cat src/benchmark/bench.sh | ssh -i "$HOME/.ssh/id_rsa" -o SendEnv=MACHINE $SERVER_USER@$SERVER "export MACHINE='$MACHINE' && export BENCHMARK='$BENCHMARK' && bash -s"


# Copy benchmark result files from server back to laptop
scp -i "$HOME/.ssh/id_rsa" $SERVER_USER@$SERVER:/home/$SERVER_USER/benchmark/data/temp.csv "$fileResult"

# Copy log files from server back to laptop
scp -r -i "$HOME/.ssh/id_rsa" $SERVER_USER@$SERVER:/home/$SERVER_USER/benchmark/logs/* "$dirLogs"

# Run plotting python script depending on Benchmark
echo "Creating / updating plots..."
plotScriptFile="src/plot/plot-$BENCHMARK.py"
if [ -f "$plotScriptFile" ]; then
  python3 "$plotScriptFile" && echo "Successfully created / updated plot for $BENCHMARK"
else
  echo "No plotting python script available for benchmark '$BENCHMARK'" >&2
  exit 1
fi
