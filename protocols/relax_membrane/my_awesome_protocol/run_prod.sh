#!/bin/bash
#SBATCH --nodes 1
#SBATCH -A eberini
#SBATCH --gres=gpu:1
#SBATCH --job-name equil
#SBATCH -o %j.out
#SBATCH -e %j.err

module load amber/21_omp

NAME=md
PRMTOP=system.prmtop
INPCRD=md_07.rst7
STEP_IN=Prod.in

NSTEPS=10

inpcrd=$INPCRD
for ((istep=1; istep <= NSTEPS; istep++)); do
	istep=$(printf "%0${#NSTEPS}d" $istep)
	if [[ -f "step_${istep}.ok" ]]; then
		istep=$((istep + 1))
		continue
	fi
	echo "Step $istep"
	grep -q 'imin\s*=\s*1' $STEP_IN && prog="$AMBERHOME/bin/pmemd.cuda_DPFP" || prog="$AMBERHOME/bin/pmemd.cuda"
	$prog -O -i "$STEP_IN" -o "${NAME}_${istep}.mdout" -p $PRMTOP -c $inpcrd -r "${NAME}_${istep}.rst7" -ref "$inpcrd" -inf "${NAME}_${istep}.mdinfo" -x "${NAME}_${istep}.nc" || exit 1
	touch "step_${istep}.ok"
	echo "done: $(date)"
	echo
	inpcrd="${NAME}_${istep}.rst7"
	istep=$((istep + 1))
done
