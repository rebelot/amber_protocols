#!/bin/bash

PROTDIR=protocol

BACKBONE_MASK=":1-417 & @CA,C,N" # This may include ligands and cofactors
SOLUTE_RES_GROUP="1 417"           # This may include ligands and cofactors
MEMBRANE_RES_GROUP="418 1428"

for prot in $(find "$PROTDIR" -name "*.in"); do
    sed -e "s/BACKBONE_MASK/$BACKBONE_MASK/" \
        -e "s/SOLUTE_RES_GROUP/$SOLUTE_RES_GROUP/" \
        -e "s/MEMBRANE_RES_GROUP/$MEMBRANE_RES_GROUP/" \
        "$prot" >"$(basename "$prot")"
done
cp "$PROTDIR"/Prod.mdin ./
cp "$AMBERPROTOCOLS"/utils/{run.sh,loop_step,run_steps} ./
