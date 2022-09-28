#!/bin/bash

PROTDIR=protocol

SOLUTE_MASK=":1-417 \& !@H="
SOLUTE_BACKBONE_MASK="@CA,C,N"
SOLUTE_CA_MASK="@CA"

for prot in $(find "$PROTDIR" -name "*.in"); do
    sed -e "s/SOLUTE_MASK/$SOLUTE_MASK/" \
        -e "s/SOLUTE_BACKBONE_MASK/$SOLUTE_BACKBONE_MASK/" \
        -e "s/SOLUTE_CA_MASK/$SOLUTE_CA_MASK/" "$prot" >"$(basename $prot)"
done

cp $AMBERPROTOCOLS/utils/run.sh ./
