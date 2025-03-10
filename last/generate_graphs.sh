#!/bin/bash

# Function to generate a graph if it doesn't exist
generate_graph() {
    local input_file=$1
    local output_file=$2
    local script=$3
    local output_log=$4
    local height=${5:-0}  # Default to 0 if not provided

    if [ ! -e "$output_file" ]; then
        if [ -n "$output_log" ]; then
            echo "time Rscript $script $input_file $output_file $height > $output_log"
            time Rscript "$script" "$input_file" "$output_file" "$height" > "$output_log"
        else
            echo "time Rscript $script $input_file $output_file $height"
            time Rscript "$script" "$input_file" "$output_file" "$height"
        fi
    else
        echo "$output_file already exists"
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

org2Graph=$9
org3Graph=$10
org2_out=$11
org3_out=$12
org2Graph_sbstCount=$13
org3Graph_sbstCount=$14
org2Graph_oriCount=$15
org3Graph_oriCount=$16

org2Graph_maflinked=$17
org3Graph_maflinked=$18
org2_maflinked_out=$19
org3_maflinked_out=$20
org2Graph_maflinked_sbstCount=$21
org3Graph_maflinked_sbstCount=$22
org2Graph_maflinked_oriCount=$23
org3Graph_maflinked_oriCount=$24

org2Graph_errprb=$25
org3Graph_errprb=$26
org2_errprb_out=$27
org3_errprb_out=$28
org2Graph_errprb_sbstCount=$29
org3Graph_errprb_sbstCount=$30
org2Graph_errprb_oriCount=$31
org3Graph_errprb_oriCount=$32

org2Graph_maflinked_errprb=$33
org3Graph_maflinked_errprb=$34
org2_maflinked_errprb_out=$35
org3_maflinked_errprb_out=$36
org2Graph_maflinked_errprb_sbstCount=$37
org3Graph_maflinked_errprb_sbstCount=$38
org2Graph_maflinked_errprb_oriCount=$39
org3Graph_maflinked_errprb_oriCount=$40

r_scripts_path=${41}

# Trinucleotide substitutions graphs
echo "---making graphs of the trinucleotide substitutions"
generate_graph "$org2tsv" "$org2Graph" "$r_scripts_path/sbmut.R" "$org2_out"
generate_graph "$org3tsv" "$org3Graph" "$r_scripts_path/sbmut.R" "$org3_out"
generate_graph "$org2tsv"  "$org2Graph_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org2_out"
generate_graph "$org3tsv"  "$org3Graph_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org3_out"
generate_graph "$org2tsv"  "$org2Graph_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org2_out"
generate_graph "$org3tsv"  "$org3Graph_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org3_out"

# Trinucleotide substitutions graphs (with maf-linked)
echo "---making graphs of the trinucleotide substitutions (with maf-linked)"
generate_graph "$org2tsv_maflinked" "$org2Graph_maflinked" "$r_scripts_path/sbmut.R" "$org2_maflinked_out"
generate_graph "$org3tsv_maflinked" "$org3Graph_maflinked" "$r_scripts_path/sbmut.R" "$org3_maflinked_out"
generate_graph "$org2tsv_maflinked"  "$org2Graph_maflinked_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org2_maflinked_out"
generate_graph "$org3tsv_maflinked"  "$org3Graph_maflinked_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org3_maflinked_out"
generate_graph "$org2tsv_maflinked"  "$org2Graph_maflinked_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org2_maflinked_out"
generate_graph "$org3tsv_maflinked"  "$org3Graph_maflinked_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org3_maflinked_out"

# Trinucleotide substitutions graphs (with error probability)
echo "---making graphs of the trinucleotide substitutions (with error probability)"
generate_graph "$org2tsv_errprb" "$org2Graph_errprb" "$r_scripts_path/sbmut.R" "$org2_errprb_out"
generate_graph "$org3tsv_errprb" "$org3Graph_errprb" "$r_scripts_path/sbmut.R" "$org3_errprb_out"
generate_graph "$org2tsv_errprb"  "$org2Graph_errprb_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org2_errprb_out"
generate_graph "$org3tsv_errprb"  "$org3Graph_errprb_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org3_errprb_out"
generate_graph "$org2tsv_errprb"  "$org2Graph_errprb_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org2_errprb_out"
generate_graph "$org3tsv_errprb"  "$org3Graph_errprb_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org3_errprb_out"

# Trinucleotide substitutions graphs (with error probability and maf-linked)
echo "---making graphs of the trinucleotide substitutions (with error probability and maf-linked)"
generate_graph "$org2tsv_maflinked_errprb" "$org2Graph_maflinked_errprb" "$r_scripts_path/sbmut.R" "$org2_maflinked_errprb_out"
generate_graph "$org3tsv_maflinked_errprb" "$org3Graph_maflinked_errprb" "$r_scripts_path/sbmut.R" "$org3_maflinked_errprb_out"
generate_graph "$org2tsv_maflinked_errprb"  "$org2Graph_maflinked_errprb_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org2_maflinked_errprb_out"
generate_graph "$org3tsv_maflinked_errprb"  "$org3Graph_maflinked_errprb_sbstCount" "$r_scripts_path/sbmut_sbstCount.R" "$org3_maflinked_errprb_out"
generate_graph "$org2tsv_maflinked_errprb"  "$org2Graph_maflinked_errprb_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org2_maflinked_errprb_out"
generate_graph "$org3tsv_maflinked_errprb"  "$org3Graph_maflinked_errprb_oriCount" "$r_scripts_path/sbmut_oriCount.R" "$org3_maflinked_errprb_out"









