#!/bin/bash
# Runs setup - e.g. ensures certain prerequisites each benchmark execution (not each iteration)
# Script should be executed on server by main.sh

set -x # Print each command before execution
set -e # fail and abort script if one command fails
set -o pipefail

mkdir -p $HOME/benchmark