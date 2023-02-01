#!/bin/bash
#SBATCH -A eberini
#SBATCH -p normal
#SBATCH --gres=gpu:1
#SBATCH --job-name amber
#SBATCH -o slurm_%j.out
#SBATCH -e slurm_%j.err

# export CUDA_VISIBLE_DEVICES=0

module load amber    # sets AMBERHOME and AMBERPROTOCOLS

PRMTOP=system.prmtop # Input topology

# EQUILIBRATION SETTINGS
if true; then            # Set to true to run this section

    NAME=MD_equil        # The basename for MD files
    INPCRD=system.inpcrd # Input coordinates
    PROTDIR=.            # Directory containing protocol *.in files
    PROTGLOB='*.in'      # Glob pattern matching MD input files (mdin)

    ./run_steps "$PRMTOP" "$INPCRD" "$PROTDIR" "$PROTGLOB" "$NAME" || exit 1
fi

# PRODUCTION SETTINGS
if false; then                     # Set to true to run this section

    NAME=MD_prod                   # The basename for MD files
    INPCRD=MD_equil_last_step.rst7 # The input coordinates for the production run (usually the rst7 from the last equilibration step)
    STEP_IN=Prod.mdin              # The name of the production step
    NSTEPS=010                     # The number of times to repeat the production step

    ./loop_step "$PRMTOP" "$INPCRD" "$STEP_IN" "$NSTEPS" "$NAME" || exit 1
fi
