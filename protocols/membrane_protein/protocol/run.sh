#!/bin/bash
#SBATCH -A eberini
#SBATCH -p normal
#SBATCH --gres=gpu:1
#SBATCH --job-name equil
#SBATCH -o %j.out
#SBATCH -e %j.err

export CUDA_VISIBLE_DEVICES=0,1

module load amber/21_omp

PROTDIR=protocol

NAME=md
PRMTOP=system.prmtop
INPCRD=system.inpcrd

LIPID_MASK=":OL,PA,PC,PE,PGR"
SOLUTE_HEAVY_MASK=":1-417 \& !@H="
SOLUTE_BACKBONE_MASK="@CA,C,N"
SOLUTE_CA_MASK="@CA"

for prot in $(find "$PROTDIR" -name "*.in"); do
    sed -e "s/LIPID_MASK/$LIPID_MASK/" \
        -e "s/SOLUTE_HEAVY_MASK/$SOLUTE_HEAVY_MASK/" \
        -e "s/SOLUTE_BACKBONE_MASK/$SOLUTE_BACKBONE_MASK/" \
        -e "s/SOLUTE_CA_MASK/$SOLUTE_CA_MASK/" "$prot" >"$(basename $prot)"
done

echo Starting minimization/relaxation protocol
date
echo

istep=1
inpcrd=$INPCRD
for inp in $(find . -maxdepth 1 -name "*.in" | sort); do
	istep=$(printf "%02d" $istep)
	if [[ -f "step_${istep}.ok" ]]; then
		istep=$((istep + 1))
		continue
	fi
	echo "Stage $istep: $inp - $(head -n 1 "$inp")"
	grep -q 'imin\s*=\s*1' "$inp" && prog="$AMBERHOME/bin/pmemd.cuda_DPFP" || prog="$AMBERHOME/bin/pmemd.cuda"
	$prog -O -i "$inp" -o "${NAME}_${istep}.mdout" -p $PRMTOP -c $inpcrd -r "${NAME}_${istep}.rst7" -ref "$inpcrd" -inf "${NAME}_${istep}.mdinfo" -x "${NAME}_${istep}.nc" || exit 1
	touch "step_${istep}.ok"
	echo "done: $(date)"
	echo
	inpcrd="${NAME}_${istep}.rst7"
	istep=$((istep + 1))
done
