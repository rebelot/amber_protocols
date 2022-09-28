#!/bin/bash

PROTDIR=protocol

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
cp $PROTDIR/Prod.mdin ./
cp $AMBERPROTOCOLS/utils/run.sh ./
