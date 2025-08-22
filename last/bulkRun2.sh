#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=/home/mrk/scripts/last/trisbst_3spc_fromDwl.sh
logDir=/home/mrk/log

bash ${script} ${Date} GCA_036418095.1 GCA_002775205.2 GCA_001444195.3 xiphophorusBirchmanni xiphophorusMaculatus xiphophorusCouchianus &> ${logDir}/${Date}_xipBir_xipMac_xipCou.log &

bash  ${script} ${Date} GCA_033032245.1 GCA_013036135.2 GCA_904066995.1  poeciliaPicta poeciliaFormosa poeciliaReticulata &> ${logDir}/${Date}_poePic_poeFor_poeRet.log &

# use reference genomes for poeFor and poeRet instead of different breeds
# bash  ${script} ${Date} GCA_033032245.1 GCF_000485575.1 GCF_000633615.1 poeciliaPicta po2ciliaFormosa po2ciliaReticulata &> ${logDir}/${Date}_poePic_po2For_po2Ret.log &

bash ${script} ${Date} GCA_030533445.1 GCA_037039145.1 GCA_011125445.2 cyprinodonDiabolis fundulusDiaphanus fundulusHeteroclitus &>${logDir}/${Date}_cypDia_funDia_funHet.log &
