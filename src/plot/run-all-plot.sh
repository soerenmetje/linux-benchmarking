#!/bin/bash

set -e # fail and abort script if one command fails
set -o pipefail

python3 plot-fio-diskrnd.py && echo "Successfully created / updated plot"
python3 plot-fio-diskseq.py && echo "Successfully created / updated plot"
python3 plot-iperf3-bandwidth.py && echo "Successfully created / updated plot"
python3 plot-sysbench-cpu.py && echo "Successfully created / updated plot"
python3 plot-sysbench-memory.py && echo "Successfully created / updated plot"
