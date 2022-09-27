#!/bin/bash

STEPNAME=$1
NREP=$2

for ((istep=1;istep<=NREP;istep++)); do
	istep=$(printf "%0${#NREP}d" "$istep")
    cp $STEPNAME "${STEPNAME%.*}_$istep.in"
done
