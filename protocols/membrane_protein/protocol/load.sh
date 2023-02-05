#!/bin/bash

PROTDIR=protocol
# Set the restraint groups for various stages of the equilibration
# Add ligands and cofactors to SOLUTE_RES_GROUP and BACKBONE_MASK.
# NOTE: "&" characters must be escaped: use "\&"
BACKBONE_MASK=":1-417 \& @CA,C,N"
SOLUTE_RES_GROUP="1 417"
MEMBRANE_RES_GROUP="418 1428"

for prot in $(find "$PROTDIR" -name "*.in"); do
    sed -e "s/BACKBONE_MASK/$BACKBONE_MASK/" \
        -e "s/SOLUTE_RES_GROUP/$SOLUTE_RES_GROUP/" \
        -e "s/MEMBRANE_RES_GROUP/$MEMBRANE_RES_GROUP/" \
        "$prot" >"$(basename "$prot")"
done
cp "$PROTDIR"/Prod.mdin ./
cp "$AMBERPROTOCOLS"/utils/{run.sh,loop_step,run_steps} ./
