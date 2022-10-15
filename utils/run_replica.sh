#!/bin/bash
#SBATCH -A eberini
#SBATCH -p normal
#SBATCH --gres=gpu:1
#SBATCH --job-name amber
#SBATCH -o slurm_%j.out
#SBATCH -e slurm_%j.err

# export CUDA_VISIBLE_DEVICES=0

module load amber/21_omp     # sets AMBERHOME and AMBERPROTOCOLS

NREPLICAS=3
BASENAME=replica


RUN_EQUIL=true               # Whether to run the equilibration steps
NAME=MD_equil                # The basename for MD files
PRMTOP=system.prmtop         # Input topology
INPCRD=system.inpcrd         # Input coordinates
PROTDIR=$(pwd)               # Directory containing protocol *.in files

for ((i = 1; i <= NREPLICAS; i++)); do
	irep=$(printf "%0${#NREPLICAS}d" "$i")
	dir=${BASENAME}_${irep}
	mkdir -p "$dir"

    if $RUN_EQUIL; then
        srun --gres=gpu:1 --job-name "$dir" ./run_steps $PRMTOP $INPCRD $PROTDIR $dir/$NAME &
    fi
done


RUN_PROD=false               # Whether to run the production MD
NAME=MD_prod                 # The basename for MD files
INPCRD=last_step.rst7        # The input coordinates for the production run (usually the rst7 from the last equilibration step)
STEP_IN=Prod.mdin            # The name of the production step
NSTEPS=10                    # The number of times to repeat the production step

for ((i = 1; i <= NREPLICAS; i++)); do
	irep=$(printf "%0${#NREPLICAS}d" "$i")
	dir=${BASENAME}_${irep}
	mkdir -p "$dir"

    if $RUN_PROD; then
        srun --gres=gpu:1 --job-name "$dir" ./loop_step $PRMTOP $INPCRD $STEP_IN $NSTEPS $dir/$NAME
    fi
done
