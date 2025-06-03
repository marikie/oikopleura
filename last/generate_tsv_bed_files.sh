#!/bin/bash

# Get arguments
joinedFile=$1
org2tsv=$2
org3tsv=$3
org2bed=$4
org3bed=$5

joinedFile_maflinked=$6
org2tsv_maflinked=$7
org3tsv_maflinked=$8
org2bed_maflinked=$9
org3bed_maflinked=${10}

# Function to generate TSV and BED files
generate_tsv_bed() {
    local joinedFile=$1
    local org2tsv=$2
    local org3tsv=$3
    local org2bed=$4
    local org3bed=$5

    if [ ! -e "$org2tsv" ] || [ ! -e "$org3tsv" ] || [ ! -e "$org2bed" ] || [ ! -e "$org3bed" ]; then
        echo "time python $(get_config '.paths.scripts.analysis')/trisbst_tsv_bed.py $joinedFile -ot2 $org2tsv -ot3 $org3tsv -ob2 $org2bed -ob3 $org3bed"
        time python $(get_config '.paths.scripts.analysis')/trisbst_tsv_bed.py \
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
generate_tsv_bed "$joinedFile" "$org2tsv" "$org3tsv" "$org2bed" "$org3bed"

# Maf-linked TSV and BED files
echo "---making .tsv and .bed trinucleotide substitution files (with maf-linked)"
generate_tsv_bed "$joinedFile_maflinked" "$org2tsv_maflinked" "$org3tsv_maflinked" "$org2bed_maflinked" "$org3bed_maflinked"