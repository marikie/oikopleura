#!/bin/bash

# Function to generate TSV files
generate_tsv() {
    local input_file=$1
    local output2=$2
    local output3=$3
    local script=$4

    if [ ! -e "$output2" ] || [ ! -e "$output3" ]; then
        echo "time python $script $input_file -o2 ./$output2 -o3 ./$output3"
        time python "$script" "$input_file" -o2 "./$output2" -o3 "./$output3"
    else
        echo "$output2 and $output3 already exist"
    fi
}

# Get arguments
joinedFile=$1
joinedFile_maflinked=$2
org2tsv=$3
org3tsv=$4
org2tsv_maflinked=$5
org3tsv_maflinked=$6
org2tsv_errprb=$7
org3tsv_errprb=$8
org2tsv_maflinked_errprb=$9
org3tsv_maflinked_errprb=${10}
scripts_analysis_path=${11}

org2_dinuc_tsv=${12}
org3_dinuc_tsv=${13}
org2_dinuc_tsv_maflinked=${14}
org3_dinuc_tsv_maflinked=${15}
# org2_dinuc_tsv_errprb=${16}
# org3_dinuc_tsv_errprb=${17}
# org2_dinuc_tsv_maflinked_errprb=${18}
# org3_dinuc_tsv_maflinked_errprb=${19}

# Regular TSV files
echo "---making .tsv trinucleotide substitution files"
generate_tsv "$joinedFile" "$org2tsv" "$org3tsv" "$scripts_analysis_path/trisbst_2TSVs.py"

# Maf-linked TSV files
echo "---making .tsv trinucleotide substitution files (with maf-linked)"
generate_tsv "$joinedFile_maflinked" "$org2tsv_maflinked" "$org3tsv_maflinked" "$scripts_analysis_path/trisbst_2TSVs.py"

# Dinucleotide substitution TSV files for regular files
echo "---making .tsv dinucleotide substitution files"
generate_tsv "$joinedFile" "$org2_dinuc_tsv" "$org3_dinuc_tsv" "$scripts_analysis_path/disbst_2TSVs.py"

# Dinucleotide substitution TSV files for maf-linked files
echo "---making .tsv dinucleotide substitution files (with maf-linked)"
generate_tsv "$joinedFile_maflinked" "$org2_dinuc_tsv_maflinked" "$org3_dinuc_tsv_maflinked" "$scripts_analysis_path/disbst_2TSVs.py"

# Error probability TSV files
# echo "---making .tsv trinucleotide substitution files (with errprb)"
# generate_tsv "$joinedFile" "$org2tsv_errprb" "$org3tsv_errprb" "$scripts_analysis_path/trisbst_2TSVs_errprb.py"

# Error probability with maf-linked TSV files
# echo "---making .tsv trinucleotide substitution files (with errprb and maf-linked)"
# generate_tsv "$joinedFile_maflinked" "$org2tsv_maflinked_errprb" "$org3tsv_maflinked_errprb" "$scripts_analysis_path/trisbst_2TSVs_errprb.py"