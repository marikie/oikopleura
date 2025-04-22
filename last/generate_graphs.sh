#!/bin/bash

# Function to generate a graph if it doesn't exist
generate_graph() {
    local input_file=$1
    local script=$2
    local output_log=$3

    if [ -n "$output_log" ]; then
        echo "time Rscript $script $input_file > $output_log"
        time Rscript "$script" "$input_file" > "$output_log"
    else
        echo "time Rscript $script $input_file"
        time Rscript "$script" "$input_file"
    fi
}

# Get arguments
org2tsv=$1
org3tsv=$2
org2tsv_maflinked=$3
org3tsv_maflinked=$4
org2tsv_errprb=$5
org3tsv_errprb=$6
org2tsv_maflinked_errprb=$7
org3tsv_maflinked_errprb=$8

org2_out=$9
org3_out=${10}
org2_out_sbstCount=${11}
org3_out_sbstCount=${12}
org2_out_oriCount=${13}
org3_out_oriCount=${14}

org2_maflinked_out=${15}
org3_maflinked_out=${16}
org2_maflinked_out_sbstCount=${17}
org3_maflinked_out_sbstCount=${18}
org2_maflinked_out_oriCount=${19}
org3_maflinked_out_oriCount=${20}

org2_errprb_out=${21}
org3_errprb_out=${22}
org2_errprb_out_sbstCount=${23}
org3_errprb_out_sbstCount=${24}
org2_errprb_out_oriCount=${25}
org3_errprb_out_oriCount=${26}

org2_maflinked_errprb_out=${27}
org3_maflinked_errprb_out=${28}
org2_maflinked_errprb_out_sbstCount=${29}
org3_maflinked_errprb_out_sbstCount=${30}
org2_maflinked_errprb_out_oriCount=${31}
org3_maflinked_errprb_out_oriCount=${32}

r_scripts_path=${33}

# echo "org2tsv: $org2tsv"
# echo "org3tsv: $org3tsv"
# echo "org2tsv_maflinked: $org2tsv_maflinked"
# echo "org3tsv_maflinked: $org3tsv_maflinked"
# echo "org2tsv_errprb: $org2tsv_errprb"
# echo "org3tsv_errprb: $org3tsv_errprb"
# echo "org2tsv_maflinked_errprb: $org2tsv_maflinked_errprb"
# echo "org3tsv_maflinked_errprb: $org3tsv_maflinked_errprb"
# echo "org2_out: $org2_out"
# echo "org3_out: $org3_out"
# echo "org2_out_sbstCount: $org2_out_sbstCount"
# echo "org3_out_sbstCount: $org3_out_sbstCount"
# echo "org2_out_oriCount: $org2_out_oriCount"
# echo "org3_out_oriCount: $org3_out_oriCount"
# echo "org2_maflinked_out: $org2_maflinked_out"
# echo "org3_maflinked_out: $org3_maflinked_out"
# echo "org2_maflinked_out_sbstCount: $org2_maflinked_out_sbstCount"
# echo "org3_maflinked_out_sbstCount: $org3_maflinked_out_sbstCount"
# echo "org2_maflinked_out_oriCount: $org2_maflinked_out_oriCount"
# echo "org3_maflinked_out_oriCount: $org3_maflinked_out_oriCount"
# echo "org2_errprb_out: $org2_errprb_out"
# echo "org3_errprb_out: $org3_errprb_out"
# echo "org2_errprb_out_sbstCount: $org2_errprb_out_sbstCount"
# echo "org3_errprb_out_sbstCount: $org3_errprb_out_sbstCount"
# echo "org2_errprb_out_oriCount: $org2_errprb_out_oriCount"
# echo "org3_errprb_out_oriCount: $org3_errprb_out_oriCount"
# echo "org2_maflinked_errprb_out: $org2_maflinked_errprb_out"
# echo "org3_maflinked_errprb_out: $org3_maflinked_errprb_out"
# echo "org2_maflinked_errprb_out_sbstCount: $org2_maflinked_errprb_out_sbstCount"
# echo "org3_maflinked_errprb_out_sbstCount: $org3_maflinked_errprb_out_sbstCount"
# echo "org2_maflinked_errprb_out_oriCount: $org2_maflinked_errprb_out_oriCount"
# echo "org3_maflinked_errprb_out_oriCount: $org3_maflinked_errprb_out_oriCount"
# echo "r_scripts_path: $r_scripts_path"


# Trinucleotide substitutions graphs
echo "---making graphs of the trinucleotide substitutions"
generate_graph "$org2tsv" "$r_scripts_path/sbmut.R" "$org2_out"
generate_graph "$org3tsv" "$r_scripts_path/sbmut.R" "$org3_out"
# generate_graph "$org2tsv" "$r_scripts_path/sbmut_sbstCount.R" "$org2_out_sbstCount"
# generate_graph "$org3tsv" "$r_scripts_path/sbmut_sbstCount.R" "$org3_out_sbstCount"
# generate_graph "$org2tsv" "$r_scripts_path/sbmut_oriCount.R" "$org2_out_oriCount"
# generate_graph "$org3tsv" "$r_scripts_path/sbmut_oriCount.R" "$org3_out_oriCount"

# Trinucleotide substitutions graphs (with maf-linked)
echo "---making graphs of the trinucleotide substitutions (with maf-linked)"
generate_graph "$org2tsv_maflinked" "$r_scripts_path/sbmut.R" "$org2_maflinked_out"
generate_graph "$org3tsv_maflinked" "$r_scripts_path/sbmut.R" "$org3_maflinked_out"
# generate_graph "$org2tsv_maflinked" "$r_scripts_path/sbmut_sbstCount.R" "$org2_maflinked_out_sbstCount"
# generate_graph "$org3tsv_maflinked" "$r_scripts_path/sbmut_sbstCount.R" "$org3_maflinked_out_sbstCount"
# generate_graph "$org2tsv_maflinked" "$r_scripts_path/sbmut_oriCount.R" "$org2_maflinked_out_oriCount"
# generate_graph "$org3tsv_maflinked" "$r_scripts_path/sbmut_oriCount.R" "$org3_maflinked_out_oriCount"

# Trinucleotide substitutions graphs (with error probability)
# echo "---making graphs of the trinucleotide substitutions (with error probability)"
# generate_graph "$org2tsv_errprb" "$r_scripts_path/sbmut.R" "$org2_errprb_out"
# generate_graph "$org3tsv_errprb" "$r_scripts_path/sbmut.R" "$org3_errprb_out"
# generate_graph "$org2tsv_errprb" "$r_scripts_path/sbmut_sbstCount.R" "$org2_errprb_out_sbstCount"
# generate_graph "$org3tsv_errprb" "$r_scripts_path/sbmut_sbstCount.R" "$org3_errprb_out_sbstCount"
# generate_graph "$org2tsv_errprb" "$r_scripts_path/sbmut_oriCount.R" "$org2_errprb_out_oriCount"
# generate_graph "$org3tsv_errprb" "$r_scripts_path/sbmut_oriCount.R" "$org3_errprb_out_oriCount"

# Trinucleotide substitutions graphs (with error probability and maf-linked)
# echo "---making graphs of the trinucleotide substitutions (with error probability and maf-linked)"
# generate_graph "$org2tsv_maflinked_errprb" "$r_scripts_path/sbmut.R" "$org2_maflinked_errprb_out"
# generate_graph "$org3tsv_maflinked_errprb" "$r_scripts_path/sbmut.R" "$org3_maflinked_errprb_out"
# generate_graph "$org2tsv_maflinked_errprb" "$r_scripts_path/sbmut_sbstCount.R" "$org2_maflinked_errprb_out_sbstCount"
# generate_graph "$org3tsv_maflinked_errprb" "$r_scripts_path/sbmut_sbstCount.R" "$org3_maflinked_errprb_out_sbstCount"
# generate_graph "$org2tsv_maflinked_errprb" "$r_scripts_path/sbmut_oriCount.R" "$org2_maflinked_errprb_out_oriCount"
# generate_graph "$org3tsv_maflinked_errprb" "$r_scripts_path/sbmut_oriCount.R" "$org3_maflinked_errprb_out_oriCount"
