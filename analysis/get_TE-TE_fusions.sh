#!/bin/bash

if [ $# -ne 2 ]; then
        echo "You need 2 arguments." 1>&2
        echo "- thresold read number" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

THRESHOLD=$1
DATE=$2

cd ~/data/te-te-splits

# ---- embryos ----
echo "embryos: getting TE-TE fusions"
python ~/oikopleura/analysis/get_TE_TE_splits_faster.py ~/data/last/OKI2018_I69.RepMask.out ~/data/last/embryos/lastsplitOKI2018_I69_1.0_whole_ERR4570985_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-te-splits/embryos_te-te_fusions_$DATE

echo "embryos: making intronFile"
python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-te-splits/embryos_te-te_fusions_$DATE.maf ~/data/te-te-splits/intronFile_embryos_te-te_fusions_$DATE.json

echo "embryos: extracting introns withe more than $THRESHOLD reads"
python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-te-splits/intronFile_embryos_te-te_fusions_$DATE.json ~/data/te-te-splits/intronFile_embryos_te-te_fusions_ME_$THRESHOLD\_reads_$DATE.json $THRESHOLD

# ---- immature adults -----
echo "immature adults: getting TE-TE fusions"
python ~/oikopleura/analysis/get_TE_TE_splits_faster.py ~/data/last/OKI2018_I69.RepMask.out ~/data/last/immatureAdults/lastsplitOKI2018_I69_1.0_whole_ERR4570986_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-te-splits/immatureAdults_te-te_fusions_$DATE

echo "immature adults: making intronFile"
python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-te-splits/immatureAdults_te-te_fusions_$DATE.maf ~/data/te-te-splits/intronFile_immatureAdults_te-te_fusions_$DATE.json

echo "immature adults: extracting introns withe more than $THRESHOLD reads"
python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-te-splits/intronFile_immatureAdults_te-te_fusions_$DATE.json ~/data/te-te-splits/intronFile_immatureAdults_te-te_fusions_ME_$THRESHOLD\_reads_$DATE.json $THRESHOLD

# ---- matured adults ----
echo "matured adults: getting TE-TE fusions"
python ~/oikopleura/analysis/get_TE_TE_splits_faster.py ~/data/last/OKI2018_I69.RepMask.out ~/data/last/immatureAdults/lastsplitOKI2018_I69_1.0_whole_ERR4570986_filtered_trimmed_sorted_interleaved_postmask_removed.chrUn_onlysplits.maf ~/data/te-te-splits/maturedAdults_te-te_fusions_$DATE

echo "matured adults: making intronFile"
python ~/oikopleura/analysis/makeOneIntronJsonFile.py ~/data/te-te-splits/maturedAdults_te-te_fusions_$DATE.maf ~/data/te-te-splits/intronFile_maturedAdults_te-te_fusions_$DATE.json

echo "matured adults: extracting introns withe more than $THRESHOLD reads"
python ~/oikopleura/analysis/extractIntronsWithManyReads.py ~/data/te-te-splits/intronFile_maturedAdults_te-te_fusions_$DATE.json ~/data/te-te-splits/intronFile_maturedAdults_te-te_fusions_ME_$THRESHOLD\_reads_$DATE.json $THRESHOLD
