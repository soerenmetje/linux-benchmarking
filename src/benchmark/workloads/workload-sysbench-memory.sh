#!/bin/bash
set -x # Print each command before execution

sysbench memory --threads=16 --memory-block-size=1K --memory-total-size=100G --memory-access-mode=seq --memory-oper=write run