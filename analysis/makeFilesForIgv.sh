#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need an argument." 1>&2
        echo "- a maf file path" 1>&2
        exit 1
fi

DIR="$(dirname "$1")"
MAF_FILE="$(basename "$1")"

echo "DIR: $DIR"
echo "MAF_FILE: $MAF_FILE"
cd $DIR
pwd

# divideMAFIntoInexactAndOthers.py
InexactRemoved=${MAF_FILE%.*}"_inexactSplitsRemoved.maf"
if [ ! -e $InexactRemoved ]; then
        echo "getting _inexactSplitsRemoved.maf"
        python ~/oikopleura/analysis/divideMAFIntoInexactAndOthers.py $MAF_FILE
fi

# maf-convert
SAM_FILE=${MAF_FILE%.*}".sam"
echo "converting to SAM"
maf-convert -j1e6 -d sam $InexactRemoved > $SAM_FILE

# extractNonSplicedAlignment.py
echo "extracting non-spliced alignments only"
python ~/oikopleura/analysis/extractNonSplicedAlignments.py $MAF_FILE

# makeTransSplicingJsonFile.py
TransFile=${MAF_FILE%.*}"_trans_splicings_sorted.json"
echo "making trans-splicing JSON file"
python ~/oikopleura/analysis/makeTransSplicingJsonFile.py $MAF_FILE $TransFile

# makeOneIntronJsonFile.py
IntronFile=${MAF_FILE%.*}"_all_introns_sorted.json"
echo "making all-intron file"
python ~/oikopleura/analysis/makeOneIntronJsonFile.py $MAF_FILE $IntronFile
