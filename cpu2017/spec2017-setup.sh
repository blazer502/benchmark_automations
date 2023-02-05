#!/bin/bash


set -e

PROJ_ROOT=${HOME}/v0/sfmalloc/src
SPEC_ROOT=${HOME}/cpu2017
SIZE="$1"

CONFIG="$2"
if [ -z "$CONFIG" ]; then
    CONFIG=baseline
fi


# Give LD_PRELOAD
OPT=$3
SHARED_LIB=""
case "${OPT}" in
    "mimalloc")
        SHARED_LIB=${PROJ_ROOT}/mimalloc-2.0.6/out/release/libmimalloc.so
        ;;
    "mimalloc-kmscan")
        SHARED_LIB=${PROJ_ROOT}/mimalloc-kmscan/out/release/libmimalloc.so
        ;;
    "markus")
        SHARED_LIB="${HOME}/markus-allocator/lib/libgc.so ${HOME}/markus-allocator/lib/libgccpp.so"
        ;;
    "markus+")
        SHARED_LIB="${HOME}/markus-allocator-ours/lib/libgc.so ${HOME}/markus-allocator-ours/lib/libgccpp.so"
        ;;
    "markus+2")
        SHARED_LIB="${HOME}/markus-allocator-other/lib/libgc.so ${HOME}/markus-allocator-other/lib/libgccpp.so"
        ;;
    "kmscan")
        SHARED_LIB=${PROJ_ROOT}/hooking/hook.so
        ;;
     "glibc")
        SHARED_LIB="-i"
        ;;
     *)
        SHARED_LIB="-i"
        ;; 
esac

echo "Create bench-script directory"
mkdir -p ${OPT}/bench-script
SCRIPTS=${OPT}/bench-script


TOOL="$4"
case "${TOOL}" in
    "time")
        TOOL="/usr/bin/time -v "
        ;;
    "perf")
        # @TODO
        EVENTS=syscalls:sys_enter_mprotect,page-faults,dtlb_store_misses.miss_causes_a_walk:u,dtlb_load_misses.miss_causes_a_walk:u
        TOOL="${HOME}/src/linux-5.5.7/tools/perf/perf stat"
        TOOL="time -v $TOOL $EVENTS -M ${METRIC}"
        ;;
esac


TARGET_SET=()
while read line; do
    TARGET_SET+=(${line})
done < bench-list


pushd ${SPEC_ROOT}
source shrc
popd



echo "Current working directory: $(pwd)"
CURR=$(pwd)

for bench in ${TARGET_SET[@]}; do
    DIR=${SPEC_ROOT}/benchspec/CPU/${bench}/run/run_base_${SIZE}_${CONFIG}-m64.0000

    OUTFILE=${CURR}/${SCRIPTS}/${bench}-${SIZE}-${CONFIG}.sh

    echo "${bench}..."

    # Get the formal benchmark script
    pushd ${DIR}
    specinvoke -nn > ${OUTFILE}
    popd


    # Remove the last line
    sed -i '$d' ${OUTFILE}


    # Copy *.err and *.out
    mkdir -p ${CURR}/${OPT}/${bench}/out
    echo "mv ${DIR}/*.out ${CURR}/${OPT}/${bench}/out" >> ${OUTFILE}

    mkdir -p ${CURR}/${OPT}/${bench}/err
    echo "mv ${DIR}/*.err ${CURR}/${OPT}/${bench}/err" >> ${OUTFILE}

    # TOOL option
    # time, perf
    CMD_LINES=($(awk '/cd \/home/{ print NR;}' ${OUTFILE}))
    echo "${bench} execute ${#CMD_LINES[@]}"

    # What do you want to measure?
    i=1
    for prev_cmd in ${CMD_LINES[@]}; do
        line=`expr $prev_cmd + 1`
        cmd=$(sed "$line!d" ${OUTFILE})

        if [ "$4" == "time" ]; then
            mkdir -p ${CURR}/${OPT}/${bench}/result
            TOOL_CMD="${TOOL} -o ${CURR}/${OPT}/${bench}/result/${bench}-$i-${SIZE}-${CONFIG}.res"
        fi


        echo "${SHARED_LIB}"
        if [ "${OPT}" != "glibc" ]; then
            cmd="${TOOL_CMD} env LD_PRELOAD=\"${SHARED_LIB}\" ${cmd}"
        else
            cmd="${TOOL_CMD} env ${SHARED_LIB} ${cmd}"
        fi

        if [ "${OPT}" == "mimalloc-kmscan" ]; then
            cmd="pushd ${PROJ_ROOT}/kmscan; ./insert.sh; popd; ${cmd}"
        elif [ "${OPT}" == "kmscan" ]; then
            cmd="pushd ${PROJ_ROOT}/kmscan; ./insert.sh; popd; ${cmd}"
        fi

        sed -i "$line d" ${OUTFILE}
        sed -i "$line i $cmd" ${OUTFILE}

        i=`expr $i + 1`
    done

    chmod +x ${OUTFILE}
        
    echo "${bench}...done"
done
