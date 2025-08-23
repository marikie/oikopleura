#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=${HOME}/scripts/last/trisbst_3spc_fromDwl.sh
logDir=${HOME}/log

bash ${script} ${Date} GCA_000739165.1 GCA_015852385.1 GCA_016098005.1 mortierellaVerticillata podilaClonocystis podilaMinutissima &> ${logDir}/${Date}_morVer_podClo_podMin.log

bash ${script} ${Date} GCA_016098005.1 GCA_000739165.1 GCA_025677895.1 podilaMinutissima mortierellaVerticillata podilaHumilis &> ${logDir}/${Date}_podMin_morVer_podHum.log

bash ${script} ${Date} GCA_910591775.1 GCA_003550325.1 GCA_009809945.1 dentiscutataHeterogama gigasporaRosea gigasporaMargarita &> ${logDir}/${Date}_denHet_gigRos_gigMar.log

bash ${script} ${Date} GCA_946474995.1 GCA_910591825.1 GCA_910592005.1 funneliformisGeosporum funneliformisCaledonium funneliformisMosseae &> ${logDir}/${Date}_funGeo_funCal_funMos.log

bash ${script} ${Date} GCA_015698045.1 GCF_026210795.1 GCA_019425655.1 rhizophagusClarus rhizophagusIrregularis rhizophagusProliferans &> ${logDir}/${Date}_rhizCla_rhizIri_rhizPro.log

bash ${script} ${Date} GCA_910592345.1 GCA_910592205.1 GCA_022605545.1 paraglomusBrasilianum paraglomusOccultumIA702 paraglomusOccultumUo1 &> ${logDir}/${Date}_parBra_parOcc_parOcc.log

bash ${script} ${Date} GCA_019425655.1 GCF_026210795.1 GCA_020716745.1 rhizophagusProlifer rhizophagusIrregularis rhizophagusIrregularisC2 &> ${logDir}/${Date}_rhiPro_rhiIrr_rhiIrrC2.log

bash ${script} ${Date} GCA_002749535.1 GCA_000696975.1 GCA_014839865.1 apophysomycesVariabilis apophysomycesTrapeziformis apophysomycesOssiformis &> ${logDir}/${Date}_apoVar_apoTra_apoOss.log

bash ${script} ${Date} GCF_000300575.1 GCA_030246685.1 GCA_022315185.1 agaricusBisporus agaricusBitorquis agaricusSinodeliciosus &> ${logDir}/${Date}_agaBis_agaBit_agaSin.log

bash ${script} ${Date} GCA_018524725.1 GCA_018524465.1 GCA_018524415.1 podaxisMareebaensis podaxisPistillaris podaxisRugospora &> ${logDir}/${Date}_podMar_podPis_podRug.log

bash ${script} ${Date} GCF_021015755.1 GCA_028011325.1 GCA_027921425.1 lentinulaEdodes lentinulaLateritia lentinulaNovaeZelandiae &> ${logDir}/${Date}_lenEdo_lenLat_lenNov.log

bash ${script} ${Date} GCF_014466165.1 GCA_029467805.1 GCA_036872985.1 pleurotusOstreatus pleurotusEryngii pleurotusTuoliensis &> ${logDir}/${Date}_pleOst_pleEry_pleTui.log

bash ${script} ${Date} GCA_000827195.1 GCF_000143565.1 GCA_018417955.1 laccariaAmethystina laccariaBicolor laccariaTrichodermophora &> ${logDir}/${Date}_lacAme_lacBic_lacTri.log

bash ${script} ${Date} GCA_043168805.1 GCA_964248975.1 GCA_043167125.1 inocybeSuecica inocybeTigrina inocybeFlocculosa &> ${logDir}/${Date}_inoSue_inoTig_inoFlo.log

bash ${script} ${Date} GCA_019915135.1 GCA_019915105.1 GCA_019915075.1 strobilurusPachycystidiatus strobilurusLuchuensis strobilurusStephanocystis &> ${logDir}/${Date}_strPah_strLuc_strSte.log

bash ${script} ${Date} GCA_030435635.1 GCA_037576215.1 GCA_022818075.1 armillariaBorealis armillariaGallica armillariaAltimontana &> ${logDir}/${Date}_armBoe_armGal_armAlt.log

bash ${script} ${Date} GCA_038092395.1 GCA_015179015.1 GCA_038088795.1 boletusVariipes boletusEdulis boletusRexVeris &> ${logDir}/${Date}_boVag_boEdu_boRex.log

bash ${script} ${Date} GCA_038088795.1 GCA_018397855.1 GCA_015179015.1 boletusRexVeris boletusReticuloceps boletusEdulis &> ${logDir}/${Date}_boRex_boRet_boEdu.log

bash ${script} ${Date} GCA_038088775.1 GCA_038093535.1 GCA_038088815.1 boletusBarrowsii boletusReticulatus boletusNobilissimus &> ${logDir}/${Date}_boBar_boRet_boNob.log

bash ${script} ${Date} GCA_038090295.1 GCA_038093875.1 GCA_038092835.1 boletusSemigastroideus boletusTylopilopsis boletusPseudoseparans &> ${logDir}/${Date}_boSem_boTyl_boPse.log

bash ${script} ${Date} GCA_038091815.1 GCA_038091875.1 GCA_038091955.1 leccinumObscurum leccinumInsolens leccinumImitatum &> ${logDir}/${Date}_leOb_leIn_leIm.log

bash ${script} ${Date} GCA_038092055.1 GCA_038092035.1 GCA_038091695.1 leccinumGlutinopallens leccinumDisarticulatum leccinumProximum &> ${logDir}/${Date}_leGlu_leDis_lePro.log

bash ${script} ${Date} GCA_038093035.1 GCA_038092475.1 GCA_038093055.1 boletusNancyae boletusTomentosulus boletusMariae &> ${logDir}/${Date}_boNan_boTom_boMar.log

bash ${script} ${Date} GCA_003313715.1 GCA_022884055.1 GCA_003316425.1 russulaAbietina russulaGriseocarnosa russulaLepida &> ${logDir}/${Date}_rusAbe_rusGra_rusLep.log

bash ${script} ${Date} GCA_021524915.1 GCA_021525025.1 GCA_021525015.1 lactariusAkahatsu lactariusHengduanensis lactariusPseudohatsudake &> ${logDir}/${Date}_lacAka_lacHeng_lacPse.log

bash ${script} ${Date} GCA_021527775.1 GCA_021525775.1 GCA_024734325.1 lactariusSanguifluus lactariusDeliciosus lactariusHatsudake &> ${logDir}/${Date}_lacSang_lacDel_lacHat.log

bash ${script} ${Date} GCA_024521645.1 GCF_003444635.1 GCF_020137385.1 morchellaSnyderi morchellaImportuna morchellaSextelata &> ${logDir}/${Date}_morSny_morImp_morSxt.log
