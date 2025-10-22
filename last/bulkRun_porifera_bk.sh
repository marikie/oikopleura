#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=${HOME}/scripts/last/trisbst_3spc_fromDwl.sh
logDir=${HOME}/log

bash ${script} ${Date} GCA_965643675.1 GCA_949841015.1 GCA_964659575.1 aplysinaCauliformis aplysinaAerophoba aplysinaCavernicola &> ${logDir}/${Date}_apCau_apAer_apCav.log

