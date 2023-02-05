#!/bin/bash

set -e

echo "kmscan"
pushd kmscan/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd

echo "mimalloc"
: << "END"
echo "markus+2"
pushd markus+2/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd

echo "mimalloc"
pushd mimalloc/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh > /dev/null
    ./$dir
done
popd

exit


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

echo "mimalloc-kmscan"
pushd mimalloc-kmscan/bench-script
for dir in *.sh; do
    echo "$dir"
    ./../../scripts/cpu-setting.sh >> /dev/null
    ./$dir
done
popd

END
