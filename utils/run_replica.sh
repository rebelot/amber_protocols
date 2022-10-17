#!/bin/bash

NREPLICAS=6
BASENAME=replica

for ((i = 1; i <= NREPLICAS; i++)); do
	irep=$(printf "%0${#NREPLICAS}d" "$i")
	dir=${BASENAME}_${irep}
	mkdir -p "$dir"
	export REPLICA_DIR="$dir"
	sbatch --job-name $dir run.sh
done

