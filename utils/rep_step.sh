#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 file rep"
    exit 1
fi

STEPNAME=$1
NREP=$2

for ((istep=1;istep<=NREP;istep++)); do
	istep=$(printf "%0${#NREP}d" "$istep")
    cp $STEPNAME "${STEPNAME%.*}_$istep.in"
done
