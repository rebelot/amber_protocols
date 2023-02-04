#!/bin/bash

PROTDIR=protocol

PROTEIN_MASK=":1-417"
LIGAND_MASK=""
SOLUTE_RES_GROUP="1 417"
MEMBRANE_RES_GROUP="418 1428"

for prot in $(find "$PROTDIR" -name "*.in"); do
    sed -e "s/PROTEIN_MASK/$PROTEIN_MASK/" \
        -e "s/LIGAND_MASK/$LIGAND_MASK/" \
        -e "s/SOLUTE_RES_GROUP/$SOLUTE_RES_GROUP/" \
        -e "s/MEMBRANE_RES_GROUP/$MEMBRANE_RES_GROUP/" \
        "$prot" >"$(basename "$prot")"
done
cp "$PROTDIR"/Prod.mdin ./
cp "$AMBERPROTOCOLS"/utils/{run.sh,loop_step,run_steps} ./
