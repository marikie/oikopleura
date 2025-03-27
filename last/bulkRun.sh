#! /bin/bash

argNum=$#

if [ $argNum -ne 1 ]; then
    echo "Usage: $0 <Today's Date>"
    exit 1
fi

Date=$1

script=/home/mrk/scripts/last/trisbst_3spc.sh
logDir=/home/mrk/log

bash ${script} ${Date} /home/mrk/genomes/archocentrusCentrarchus/GCF_007364275.1_fArcCen1_genomic.fna /home/mrk/genomes/amphilophusZaliosus/GCA_015108585.1_JWE1.scf_genomic.fna /home/mrk/genomes/amphilophusCitrinellus/GCA_013435755.1_ASM1343575v1_genomic.fna &> ${logDir}/${Date}_arcCen_ampZal_ampCit.log &
 
bash ${script} ${Date} /home/mrk/genomes/aspergillusCostiformis/GCA_037044115.1_ASM3704411v1_genomic.fna /home/mrk/genomes/aspergillusChevalieri/GCF_016861735.1_AchevalieriM1_assembly01_genomic.fna /home/mrk/genomes/aspergillusCristatus/GCA_034509305.1_ASM3450930v1_genomic.fna &> ${logDir}/${Date}_aspCos_aspChe_aspCri.log &

bash ${script} ${Date} /home/mrk/genomes/cyanobiumGracile/GCF_000316515.1_ASM31651v1_genomic.fna /home/mrk/genomes/parasynechococcusMarenigrum/GCF_000195975.1_ASM19597v1_genomic.fna /home/mrk/genomes/prochlorococcusMarinus/GCF_000015665.1_ASM1566v1_genomic.fna &> ${logDir}/${Date}_cyaGra_parMar_proMar.log &

bash ${script} ${Date} /home/mrk/genomes/gigantidasPlatifrons/GCA_002080005.1_Bpl_v1.0_genomic.fna /home/mrk/genomes/bathymodiolusSeptemdierum/GCA_963383655.1_xbBatSept2.1_genomic.fna /home/mrk/genomes/bathymodiolusBrooksi/GCA_963680875.1_xbBatBroo1.1_genomic.fna &> ${logDir}/${Date}_gigPla_batSep_batBro.log &
 
bash ${script} ${Date} /home/mrk/genomes/mytilusTrossulus/GCF_036588685.1_PNRI_Mtr1.1.1.hap1_genomic.fna /home/mrk/genomes/mytilusEdulis/GCA_019925275.1_PEIMed_genomic.fna /home/mrk/genomes/mytilusGalloprovincialis/GCA_037788925.1_MytGallo_primary_0.1_genomic.fna &> ${logDir}/${Date}_mytTro_mytEdu_mytGal.log &

bash ${script} ${Date} /home/mrk/genomes/oikopleuraDioica/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna /home/mrk/genomes/oikopleuraAlbicans/GCA_004367875.1_ASM436787v1_genomic.fna /home/mrk/genomes/oikopleuraVanhoeffeni/GCA_004367855.1_ASM436785v1_genomic.fna &> ${logDir}/${Date}_okiDio_okiAlb_okiVan.log &

bash ${script} ${Date} /home/mrk/genomes/ostreococcusMediterraneus/GCA_012295225.1_ASM1229522v1_genomic.fna /home/mrk/genomes/ostreococcusTauri/GCF_000214015.3_version_140606_genomic.fna /home/mrk/genomes/ostreococcusLucimarinus/GCF_000092065.1_ASM9206v1_genomic.fna &> ${logDir}/${Date}_ostMed_ostTau_ostLuc.log &

bash ${script} ${Date} /home/mrk/genomes/protothecaCutis/GCA_002897115.2_JCM_15793_assembly_v001_genomic.fna /home/mrk/genomes/protothecaCiferrii/GCA_003613005.1_ASM361300v1_genomic.fna /home/mrk/genomes/protothecaBovis/GCA_003612995.1_ASM361299v1_genomic.fna &> ${logDir}/${Date}_proCut_proCif_proBov.log &

bash ${script} ${Date} /home/mrk/genomes/protothecaWickerhamii/GCA_031763795.1_ASM3176379v1_genomic.fna /home/mrk/genomes/protothecaBovis/GCA_003612995.1_ASM361299v1_genomic.fna /home/mrk/genomes/protothecaCiferrii/GCA_003613005.1_ASM361300v1_genomic.fna &> ${logDir}/${Date}_proWic_proBov_proCif.log &

bash ${script} ${Date} /home/mrk/genomes/pseudocalidococcusAzoricus/GCF_031729055.1_ASM3172905v1_genomic.fna /home/mrk/genomes/thermosynechococcusVestitus/GCF_000011345.1_ASM1134v1_genomic.fna /home/mrk/genomes/thermosynechococcusSichuanensis/GCF_003555505.1_ASM355550v2_genomic.fna &> ${logDir}/${Date}_pseAzo_theVes_theSic.log &

bash ${script} ${Date} /home/mrk/genomes/ulvaProlifera/GCA_023078555.1_ASM2307855v1_genomic.fna /home/mrk/genomes/ulvaMutabilis/GCA_900538255.1_Ulvmu_WT_fa_genomic.fna /home/mrk/genomes/ulvaCompressa/GCA_024500015.1_ASM2450001v1_genomic.fna &> ${logDir}/${Date}_ulvPro_ulvMut_ulvCom.log &

bash ${script} ${Date} /home/mrk/genomes/wallemiaMellicola/GCF_000263375.1_Wallemia_sebi_v1.0_genomic.fna /home/mrk/genomes/wallemiaIchthyophaga/GCF_000400465.1_Wallemia_ichthyophaga_version_1.0_genomic.fna /home/mrk/genomes/wallemiaHederae/GCA_004918325.1_ASM491832v1_genomic.fna &> ${logDir}/${Date}_walMel_walIch_walHed.log &
