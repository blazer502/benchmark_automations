#!/bin/bash

nCPU=`nproc`

for ((i=0; i<${nCPU}; i++)); do
    echo performance | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done
