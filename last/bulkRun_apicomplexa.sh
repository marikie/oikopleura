#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=${HOME}/sbst/scripts/last/trisbst_3spc_fromDwl.sh
outDir=${HOME}/sbst/data/apicomplexa
logDir=${HOME}/sbst/log

bash ${script} --out-dir ${outDir} ${Date} GCF_001602025.1 GCF_000002765.6 GCF_001601855.1 &> ${logDir}/${Date}_plGab_plFal_plRei.log

bash ${script} --out-dir ${outDir} ${Date} GCF_900002335.3 GCF_900002375.2 GCF_900002385.2 &> ${logDir}/${Date}_plCha_plBer_plYo.log

bash ${script} --out-dir ${outDir} ${Date} GCF_001680005.1 GCF_000321355.1 GCF_000524495.1 &> ${logDir}/${Date}_plCoa_plCyo_plInu.log

bash ${script} --out-dir ${outDir} ${Date} GCF_000165345.1 GCF_000006425.1 GCA_004337835.1 &> ${logDir}/${Date}_crPar_crHom_crCun.log