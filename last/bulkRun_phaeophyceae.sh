#! /bin/bash

argNum=$#

if [ "$argNum" -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi
module use /big/mrk/app/.modulefiles
module load datasets/18.9.0
module load last/1638

Date=$1

script=${HOME}/sbst/scripts/last/trisbst_3spc_fromDwl.sh
outDir=${HOME}/sbst/data/phaeophyceae/test
logDir=${HOME}/sbst/log

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964200635.2 GCA_037834435.1 GCA_036873665.1 &> "${logDir}/${Date}_lamDig_lamSet_lamSin.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_032270885.1 GCA_034768055.1 GCA_048937375.1 &> "${logDir}/${Date}_sacSes_sacLat_sacJap.log"
