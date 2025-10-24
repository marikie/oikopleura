#! /bin/bash

argNum=$#

if [ "$argNum" -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

module use /big/mrk/app/.modulefiles
module load datasets/18.9.0
module load last/1638

script=${HOME}/sbst/scripts/last/trisbst_3spc_fromDwl.sh
outDir=${HOME}/sbst/data/cnidaria/test
logDir=${HOME}/sbst/log

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_009936425.2 GCA_014526335.2 GCA_011763395.2 &> "${logDir}/${Date}_chFus_chQui_chChe.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964304725.1 GCA_964235115.1 GCA_018155075.1 &> "${logDir}/${Date}_caOrn_caXam_caAnd.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_011763375.2 GCA_049996035.1 GCA_011800005.2 &> "${logDir}/${Date}_heMag_stHad_stMer.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_044474045.1 GCA_009858155.3 GCA_044473265.1 &> "${logDir}/${Date}_heVer_phCru_phLol.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCF_000222465.1 GCA_964291705.1 GCF_013753865.1 &> "${logDir}/${Date}_acDig_acHyp_acMil.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCF_000222465.1 GCA_964291705.1 GCA_964261235.1 &> "${logDir}/${Date}_acDig_acHyp_acSpi.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCF_013753865.1 GCA_014634205.1 GCA_014634165.1 &> "${logDir}/${Date}_acMil_acNas_acMic.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964273435.1 GCA_014633955.1 GCA_031770025.1 &> "${logDir}/${Date}_acAus_acTen_acSpa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_949126865.1 GCA_043882275.1 GCA_014634505.1 &> "${logDir}/${Date}_moCap_moGri_moEff.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964258685.1 GCA_024195265.1 GCA_047759845.1 &> "${logDir}/${Date}_duAx_deCr_tuCo.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964035705.1 GCA_022179025.1 GCA_964035525.1 &> "${logDir}/${Date}_poRu_poAu_poCy.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964035705.1 GCA_942486035.1 GCF_958299795.1 &> "${logDir}/${Date}_poRu_poLo_poLu.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964027065.2 GCF_036669915.1 GCF_003704095.1 &> "${logDir}/${Date}_poGr_poVer_poDa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCF_002571385.2 GCF_036669915.1 GCF_003704095.1 &> "${logDir}/${Date}_stPi_poVer_poDa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964199735.2 GCF_002042975.1 GCA_964194085.1 &> "${logDir}/${Date}_ecHo_orFa_cySa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_964194085.1 GCF_002042975.1 GCA_964199315.1 &> "${logDir}/${Date}_cySa_orFa_orFr.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_025448195.2 GCA_025403605.1 GCA_025403585.1 &> "${logDir}/${Date}_paAt_paDa_paSw.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_027574985.2 GCA_025448255.1 GCA_027575125.1 &> "${logDir}/${Date}_umNa_umCh_umPa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_025403525.1 GCA_025448255.1 GCA_027575125.1 &> "${logDir}/${Date}_umKa_umCh_umPa.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_025447995.2 GCA_025331085.1 GCA_027575285.1 &> "${logDir}/${Date}_isTu_zoSo_zoPu.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_042846405.1 GCA_965234985.1 GCA_027575235.1 &> "${logDir}/${Date}_pyMi_pyCa_pyMu.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_965234985.1 GCA_027575235.1 GCA_026546935.1 &> "${logDir}/${Date}_pyCa_pyMu_pyGr.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_026546655.1 GCA_026413505.1 GCA_025388665.1 &> "${logDir}/${Date}_epIl_epRa_epPl.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_025400095.1 GCA_025400075.2 GCA_025434845.1 &> "${logDir}/${Date}_phMa_phSt_phSu.log"

bash "${script}" --out-dir "${outDir}" "${Date}" GCA_035771165.1 GCA_964265095.1 GCA_045791825.1 &> "${logDir}/${Date}_paPa_coRu_heIm.log"
