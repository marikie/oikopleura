#!/bin/bash

# Get arguments
scripts_analysis_path=$1
joinedFile=$2
org2tsv=$3
org3tsv=$4
org2bed=$5
org3bed=$6

joinedFile_maflinked=$7
org2tsv_maflinked=$8
org3tsv_maflinked=$9
org2bed_maflinked=${10}
org3bed_maflinked=${11}

# Function to generate TSV and BED files
generate_tsv_bed() {
    local scripts_analysis_path=$1
    local joinedFile=$2
    local org2tsv=$3
    local org3tsv=$4
    local org2bed=$5
    local org3bed=$6

    if [ ! -e "$org2tsv" ] || [ ! -e "$org3tsv" ] || [ ! -e "$org2bed" ] || [ ! -e "$org3bed" ]; then
        echo "time python $scripts_analysis_path/trisbst_tsv_bed.py $joinedFile -ot2 $org2tsv -ot3 $org3tsv -ob2 $org2bed -ob3 $org3bed"
        time python $scripts_analysis_path/trisbst_tsv_bed.py \
            "$joinedFile" \
            -ot2 "$org2tsv" \
            -ot3 "$org3tsv" \
			-ob2 "$org2bed" \
			-ob3 "$org3bed"
    else
        echo "All files ($org2tsv, $org3tsv, $org2bed, and $org3bed) already exist"
    fi
}

# Regular TSV and BED files
echo "---making .tsv and .bed trinucleotide substitution files"
generate_tsv_bed "$scripts_analysis_path" "$joinedFile" "$org2tsv" "$org3tsv" "$org2bed" "$org3bed"

# Maf-linked TSV and BED files
echo "---making .tsv and .bed trinucleotide substitution files (with maf-linked)"
generate_tsv_bed "$scripts_analysis_path" "$joinedFile_maflinked" "$org2tsv_maflinked" "$org3tsv_maflinked" "$org2bed_maflinked" "$org3bed_maflinked"