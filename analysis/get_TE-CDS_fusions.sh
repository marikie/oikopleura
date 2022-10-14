#!/bin/bash

if [ $# -ne 2 ]; then
        echo "You need 2 arguments." 1>&2
        echo "- thresold read number" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

THRESHOLD=$1
DATE=$2

cd ~/data/te-cds-splits

# ---- embryos ----
Embryos_TE_CDS_Fusions="embryos_te-cds_fusions_$DATE"
IntronFile_Embryos="intronFile_embryos_te-cds_fusions_$DATE.json"
IntronFile_Embryos_ME_Threshold="intronFile_embryos_te-cds_fusions_ME_$THRESHOLD""_reads_$DATE.json"
IntronFile_Embryos_ME_Threshold_MajorSS="intronFile_embryos_te-cds_fusions_ME_$THRESHOLD""_reads_majorSS_$DATE.json"

if [ ! -e $Embryos_TE_CDS_Fusions.out ]; then
        echo "embryos: getting TE-CDS fusions"
        python ~/oikopleura/analysis/get_TE_cds_spilts_faster.py ~/data/te-cds-splits/te-cds-table_20221011.out ~/data/last/embryos/lastsplitOKI2018_I69_1.0_whole_ERR4570985_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-cds-splits/$Embryos_TE_CDS_Fusions
fi

if [ ! -e $IntronFile_Embryos ]; then
        echo "embryos: making intronFile"
        python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-cds-splits/$Embryos_TE_CDS_Fusions.maf ~/data/te-cds-splits/$IntronFile_Embryos
fi

if [ ! -e $IntronFile_Embryos_ME_Threshold ]; then
        echo "embryos: extracting introns with more than $THRESHOLD reads"
        python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-cds-splits/$IntronFile_Embryos ~/data/te-cds-splits/$IntronFile_Embryos_ME_Threshold $THRESHOLD
fi

if [ ! -e $IntronFile_Embryos_ME_Threshold_MajorSS ]; then
        echo "embryos: extracting introns with major splicing signals"
        python ~/oikopleura/analysis/extractIntronsGTAG_someNonCanonicals.py ~/data/te-cds-splits/$IntronFile_Embryos_ME_Threshold ~/data/te-cds-splits/$IntronFile_Embryos_ME_Threshold_MajorSS
fi

echo "embryos: dividing into linear and trans splits"
python ~/oikopleura/analysis/divideIntoLinearANDTransSplicings.py $IntronFile_Embryos_ME_Threshold_MajorSS

# ---- immature adults ----
ImmatureAdults_TE_CDS_Fusions="immatureAdults_te-cds_fusions_$DATE"
IntronFile_ImmatureAdults="intronFile_immatureAdults_te-cds_fusions_$DATE.json"
IntronFile_ImmatureAdults_ME_Threshold="intronFile_immatureAdults_te-cds_fusions_ME_$THRESHOLD""_reads_$DATE.json"
IntronFile_ImmatureAdults_ME_Threshold_MajorSS="intronFile_immatureAdults_te-cds_fusions_ME_$THRESHOLD""_reads_majorSS_$DATE.json"

if [ ! -e $ImmatureAdults_TE_CDS_Fusions.out ]; then
        echo "immature adults: getting TE-CDS fusions"
        python ~/oikopleura/analysis/get_TE_cds_spilts_faster.py ~/data/te-cds-splits/te-cds-table_20221011.out ~/data/last/immatureAdults/lastsplitOKI2018_I69_1.0_whole_ERR4570986_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-cds-splits/$ImmatureAdults_TE_CDS_Fusions
fi

echo $IntronFile_ImmatureAdults

if [ ! -e $IntronFile_ImmatureAdults ]; then
        echo "immature adults: making intronFile"
        python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-cds-splits/$ImmatureAdults_TE_CDS_Fusions.maf ~/data/te-cds-splits/$IntronFile_ImmatureAdults
fi

if [ ! -e $IntronFile_ImmatureAdults_ME_Threshold ]; then
        echo "immature adults: extracting introns with more than $THRESHOLD reads"
        python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-cds-splits/$IntronFile_ImmatureAdults ~/data/te-cds-splits/$IntronFile_ImmatureAdults_ME_Threshold $THRESHOLD
fi

if [ ! -e $IntronFile_ImmatureAdults_ME_Threshold_MajorSS ]; then
        echo "immature adults: extracting introns with major splicing signals"
        python ~/oikopleura/analysis/extractIntronsGTAG_someNonCanonicals.py ~/data/te-cds-splits/$IntronFile_ImmatureAdults_ME_Threshold ~/data/te-cds-splits/$IntronFile_ImmatureAdults_ME_Threshold_MajorSS
fi

echo "immature adults: dividing into linear and trans splits"
python ~/oikopleura/analysis/divideIntoLinearANDTransSplicings.py $IntronFile_ImmatureAdults_ME_Threshold_MajorSS

# ---- matured adults ----
MaturedAdults_TE_CDS_Fusions="maturedAdults_te-cds_fusions_$DATE"
IntronFile_MaturedAdults="intronFile_maturedAdults_te-cds_fusions_$DATE.json"
IntronFile_MaturedAdults_ME_Threshold="intronFile_maturedAdults_te-cds_fusions_ME_$THRESHOLD""_reads_$DATE.json"
IntronFile_MaturedAdults_ME_Threshold_MajorSS="intronFile_maturedAdults_te-cds_fusions_ME_$THRESHOLD""_reads_majorSS_$DATE.json"

if [ ! -e $MaturedAdults_TE_CDS_Fusions.out ]; then
        echo "matured adults: getting TE-CDS fusions"
        python ~/oikopleura/analysis/get_TE_cds_spilts_faster.py ~/data/te-cds-splits/te-cds-table_20221011.out ~/data/last/maturedAdults/lastsplitOKI2018_I69_1.0_whole_ERR4570987_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-cds-splits/$MaturedAdults_TE_CDS_Fusions
fi

if [ ! -e $IntronFile_MaturedAdults ]; then
        echo "matured adults: making intronFile"
        python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-cds-splits/$MaturedAdults_TE_CDS_Fusions.maf ~/data/te-cds-splits/$IntronFile_MaturedAdults
fi

if [ ! -e $IntronFile_MaturedAdults_ME_Threshold ]; then
        echo "matured adults: extracting introns with more than $THRESHOLD reads"
        python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-cds-splits/$IntronFile_MaturedAdults ~/data/te-cds-splits/$IntronFile_MaturedAdults_ME_Threshold $THRESHOLD
fi

if [ ! -e $IntronFile_MaturedAdults_ME_Threshold_MajorSS ]; then
        echo "matured adults: extracting introns with major splicing signals"
        python ~/oikopleura/analysis/extractIntronsGTAG_someNonCanonicals.py ~/data/te-cds-splits/$IntronFile_MaturedAdults_ME_Threshold ~/data/te-cds-splits/$IntronFile_MaturedAdults_ME_Threshold_MajorSS
fi

echo "matured adults: dividing into linear and trans splits"
python ~/oikopleura/analysis/divideIntoLinearANDTransSplicings.py $IntronFile_MaturedAdults_ME_Threshold_MajorSS
