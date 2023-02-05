#!/bin/bash


SPEC_SRC=${HOME}/cpu2006/spec

pushd $SPEC_SRC

source shrc

#runspec --config=default.cfg all --action=realclean 
runspec --config=default.cfg \
        --size=ref \
        --copies=1 \
        --noreportable \
        --iterations=1 \
        --action runsetup \
        --tune all \
        int fp
        #453.povray
popd
