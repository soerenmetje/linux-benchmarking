#!/bin/bash
# Source: https://www.thomas-krenn.com/de/wiki/Fio_Grundlagen#Throughput_Test

set -x # Print each command before execution

mkdir -p tmp
cd tmp || exit 1

fio --rw=randwrite --name=kube-fio-write --output-format=normal,terse --bs=256k --size=16G
fio --rw=randread --name=kube-fio-read --output-format=normal,terse --bs=256k --size=16G

# Reuse created files in each iteration. Files are deleted in bench.sh after run is finished