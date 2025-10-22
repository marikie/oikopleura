#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=${HOME}/scripts/last/trisbst_3spc_fromDwl.sh
logDir=${HOME}/log

bash ${script} ${Date} GCA_964200635.2 GCA_037834435.1 GCA_036873665.1 laminariaDigitata laminariaSetchellii laminariaSinclairii &> ${logDir}/${Date}_lamDig_lamSet_lamSin.log

bash ${script} ${Date} GCA_032270885.1 GCA_034768055.1 GCA_048937375.1 saccharinaSessilis saccharinaLatissima saccharinaJaponica &> ${logDir}/${Date}_sacSes_sacLat_sacJap.log

