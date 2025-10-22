#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=${HOME}/sbst/scripts/last/trisbst_3spc_fromDwl.sh
logDir=${HOME}/sbst/log

bash ${script} ${Date} GCA_000739165.1 GCA_015852385.1 GCA_016098005.1 &> ${logDir}/${Date}_morVer_podClo_podMin.log

bash ${script} ${Date} GCA_016098005.1 GCA_000739165.1 GCA_025677895.1 &> ${logDir}/${Date}_podMin_morVer_podHum.log

bash ${script} ${Date} GCA_910591775.1 GCA_003550325.1 GCA_009809945.1 &> ${logDir}/${Date}_denHet_gigRos_gigMar.log

bash ${script} ${Date} GCA_946474995.1 GCA_910591825.1 GCA_910592005.1 &> ${logDir}/${Date}_funGeo_funCal_funMos.log

bash ${script} ${Date} GCA_000827195.1 GCF_000143565.1 GCA_018417955.1 &> ${logDir}/${Date}_lacAme_lacBic_lacTri.log

bash ${script} ${Date} GCA_043168805.1 GCA_964248975.1 GCA_043167125.1 &> ${logDir}/${Date}_inoSue_inoTig_inoFlo.log

bash ${script} ${Date} GCA_019915135.1 GCA_019915105.1 GCA_019915075.1 &> ${logDir}/${Date}_strPah_strLuc_strSte.log

bash ${script} ${Date} GCA_030435635.1 GCA_037576215.1 GCA_022818075.1 &> ${logDir}/${Date}_armBoe_armGal_armAlt.log

bash ${script} ${Date} GCA_038092395.1 GCA_015179015.1 GCA_038088795.1 &> ${logDir}/${Date}_boVag_boEdu_boRex.log

bash ${script} ${Date} GCA_038088795.1 GCA_018397855.1 GCA_015179015.1 &> ${logDir}/${Date}_boRex_boRet_boEdu.log

bash ${script} ${Date} GCA_038088775.1 GCA_038093535.1 GCA_038088815.1 &> ${logDir}/${Date}_boBar_boRet_boNob.log

bash ${script} ${Date} GCA_038090295.1 GCA_038093875.1 GCA_038092835.1 &> ${logDir}/${Date}_boSem_boTyl_boPse.log

bash ${script} ${Date} GCA_038091815.1 GCA_038091875.1 GCA_038091955.1 &> ${logDir}/${Date}_leOb_leIn_leIm.log

bash ${script} ${Date} GCA_038092055.1 GCA_038092035.1 GCA_038091695.1 &> ${logDir}/${Date}_leGlu_leDis_lePro.log

bash ${script} ${Date} GCA_038093035.1 GCA_038092475.1 GCA_038093055.1 &> ${logDir}/${Date}_boNan_boTom_boMar.log

bash ${script} ${Date} GCA_003313715.1 GCA_022884055.1 GCA_003316425.1 &> ${logDir}/${Date}_rusAbe_rusGra_rusLep.log

bash ${script} ${Date} GCA_021524915.1 GCA_021525025.1 GCA_021525015.1 &> ${logDir}/${Date}_lacAka_lacHeng_lacPse.log

bash ${script} ${Date} GCA_021527775.1 GCA_021525775.1 GCA_024734325.1 &> ${logDir}/${Date}_lacSang_lacDel_lacHat.log

bash ${script} ${Date} GCA_024521645.1 GCF_003444635.1 GCF_020137385.1 &> ${logDir}/${Date}_morSny_morImp_morSxt.log
