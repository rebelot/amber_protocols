#!/bin/bash
#SBATCH -A eberini
#SBATCH -p normal
#SBATCH --gres=gpu:1
#SBATCH --job-name amber
#SBATCH -o slurm_%j.out
#SBATCH -e slurm_%j.err

# export CUDA_VISIBLE_DEVICES=0

module load amber/21_omp     # sets AMBERHOME and AMBERPROTOCOLS

RUN_EQUIL=true               # Whether to run the equilibration steps
NAME=MD                      # The basename for MD files
PRMTOP=system.prmtop         # Input topology
INPCRD=system.inpcrd         # Input coordinates

RUN_PROD=false               # Whether to run the production MD
PROD_INPCRD=last_step.rst7   # The input coordinates for the production run (usually the rst7 from the last equilibration step)
PROD_STEP=Prod.mdin          # The name of the production step
NSTEPS=10                    # The number of times to repeat the production step

if $RUN_EQUIL; then
    $AMBERPROTOCOLS/utils/run_steps $PRMTOP $INPCRD $NAME || exit 1
fi

if $RUN_PROD; then
    $AMBERPROTOCOLS/utils/loop_step $PRMTOP $PROD_INPCRD $PROD_STEP $NSTEPS $NAME || exit 1
fi
