#!/bin/bash

NREPLICAS=6      # Number of replicas
BASENAME=replica # Basename of replica directory

for ((i = 1; i <= NREPLICAS; i++)); do
    irep=$(printf "%0${#NREPLICAS}d" "$i")
    dir=${BASENAME}_${irep}
    mkdir -p "$dir"
    export REPLICA_DIR="$dir"
    sbatch --job-name "$dir" run.sh
done
