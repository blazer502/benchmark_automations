#!/bin/bash

set -e

# Envrionments
PWD=`pwd`
BENCH=$HOME/cpu2017

CONFIG="baseline"

SIZE=""
SIZE_CMD=""

#BENCH_SUIT="600.perlbench_s"
BENCH_SUIT="619.lbm_s 644.nab_s 600.perlbench_s 605.mcf_s 620.omnetpp_s 623.xalancbmk_s 625.x264_s 631.deepsjeng_s 641.leela_s 657.xz_s 638.imagick_s 602.gcc_s"

BENCH_SET=("c" "cpp")


# Variables
RESULT=$PWD/result
TRIAL=""

if [ "$1" == "test" ]; then
    SIZE="test"
    SIZE_CMD="test"
elif [ "$1" == "train" ]; then
    SIZE="train"
    SIZE_CMD="train"
elif [ "$1" == "ref" ]; then
    SIZE="refspeed"
    SIZE_CMD="ref"
else
    exit 1
fi

# 0. Env settings
cp baseline.cfg ${BENCH}/config/
cd ${BENCH}
source shrc
#runcpu --config=${CONFIG} all --action=realclean
runcpu --config=${CONFIG} --size=${SIZE_CMD} --copies=1 \
    --iterations=1  --tune=all --action=runsetup ${BENCH_SUIT}
