#!/bin/bash

dir=$(date +"%Y-%m-%d+%T")
mkdir -p backup/$dir
cp -r glibc markus mimalloc backup/$dir
