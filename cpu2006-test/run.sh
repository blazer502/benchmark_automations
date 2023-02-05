#!/bin/bash

: << "END"
echo "mimalloc"
pushd mimalloc/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh > /dev/null
    ./$dir
done
popd

echo "markus"
pushd markus/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd

echo "glibc"
pushd glibc/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd
END

echo "mimalloc-kmscan"
pushd mimalloc-kmscan/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd
