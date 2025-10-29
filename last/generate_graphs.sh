#!/bin/bash

# Function to generate a graph log alongside the input TSV
generate_graph() {
    local input_file=$1
    local script=$2
    local output_log="${input_file%.*}.out"

    echo "time Rscript $script $input_file > $output_log"
    time Rscript "$script" "$input_file" > "$output_log"
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

org2tsv_ncds=$9
org3tsv_ncds=${10}
org2tsv_maflinked_ncds=${11}
org3tsv_maflinked_ncds=${12}

org2_dinuc_tsv=${13}
org3_dinuc_tsv=${14}
org2_dinuc_tsv_maflinked=${15}
org3_dinuc_tsv_maflinked=${16}

org2_dinuc_tsv_ncds=${17}
org3_dinuc_tsv_ncds=${18}
org2_dinuc_tsv_maflinked_ncds=${19}
org3_dinuc_tsv_maflinked_ncds=${20}

r_scripts_path=${21}


# Trinucleotide substitutions graphs
echo "---making graphs of the trinucleotide substitutions"
generate_graph "$org2tsv" "$r_scripts_path/sbmut.R"
generate_graph "$org3tsv" "$r_scripts_path/sbmut.R"
echo "time Rscript $r_scripts_path/logRatioPlot.R $org2tsv"
time Rscript "$r_scripts_path/logRatioPlot.R" "$org2tsv"
echo "time Rscript $r_scripts_path/logRatioPlot.R $org3tsv"
time Rscript "$r_scripts_path/logRatioPlot.R" "$org3tsv"

# Trinucleotide substitutions graphs (of ncds)
if [ -e "$org2tsv_ncds" ] && [ -e "$org3tsv_ncds" ]; then
    echo "---making graphs of the trinucleotide substitutions (of ncds)"
    generate_graph "$org2tsv_ncds" "$r_scripts_path/sbmut.R"
    generate_graph "$org3tsv_ncds" "$r_scripts_path/sbmut.R"
    echo "time Rscript $r_scripts_path/logRatioPlot.R $org2tsv_ncds"
    time Rscript "$r_scripts_path/logRatioPlot.R" "$org2tsv_ncds"
    echo "time Rscript $r_scripts_path/logRatioPlot.R $org3tsv_ncds"
    time Rscript "$r_scripts_path/logRatioPlot.R" "$org3tsv_ncds"
fi

# Trinucleotide substitutions graphs (with maf-linked)
echo "---making graphs of the trinucleotide substitutions (with maf-linked)"
generate_graph "$org2tsv_maflinked" "$r_scripts_path/sbmut.R"
generate_graph "$org3tsv_maflinked" "$r_scripts_path/sbmut.R"
echo "time Rscript $r_scripts_path/logRatioPlot.R $org2tsv_maflinked"
time Rscript "$r_scripts_path/logRatioPlot.R" "$org2tsv_maflinked"
echo "time Rscript $r_scripts_path/logRatioPlot.R $org3tsv_maflinked"
time Rscript "$r_scripts_path/logRatioPlot.R" "$org3tsv_maflinked"

# Trinucleotide substitutions graphs (of ncds and maf-linked)
if [ -e "$org2tsv_maflinked_ncds" ] && [ -e "$org3tsv_maflinked_ncds" ]; then
    echo "---making graphs of the trinucleotide substitutions (of maf-linked_ncds)"
    generate_graph "$org2tsv_maflinked_ncds" "$r_scripts_path/sbmut.R"
    generate_graph "$org3tsv_maflinked_ncds" "$r_scripts_path/sbmut.R"
    echo "time Rscript $r_scripts_path/logRatioPlot.R $org2tsv_maflinked_ncds"
    time Rscript "$r_scripts_path/logRatioPlot.R" "$org2tsv_maflinked_ncds"
    echo "time Rscript $r_scripts_path/logRatioPlot.R $org3tsv_maflinked_ncds"
    time Rscript "$r_scripts_path/logRatioPlot.R" "$org3tsv_maflinked_ncds"
fi

# Dinucleotide substitutions graphs
echo "---making graphs of the dinucleotide substitutions"
time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org2_dinuc_tsv"
time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org3_dinuc_tsv"

# Dinucleotide substitutions graphs (of ncds)
if [ -e "$org2_dinuc_tsv_ncds" ] && [ -e "$org3_dinuc_tsv_ncds" ]; then
    echo "---making graphs of the dinucleotide substitutions (of ncds)"
    time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org2_dinuc_tsv_ncds"
    time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org3_dinuc_tsv_ncds"
fi

# Dinucleotide substitutions graphs (with maf-linked)
echo "---making graphs of the dinucleotide substitutions (with maf-linked)"
time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org2_dinuc_tsv_maflinked"
time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org3_dinuc_tsv_maflinked"

# Dinucleotide substitutions graphs (of ncds and maf-linked)
if [ -e "$org2_dinuc_tsv_maflinked_ncds" ] && [ -e "$org3_dinuc_tsv_maflinked_ncds" ]; then
    echo "---making graphs of the dinucleotide substitutions (of ncds and maf-linked)"
    time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org2_dinuc_tsv_maflinked_ncds"
    time Rscript "$r_scripts_path/dinucleotide-plot.R" "$org3_dinuc_tsv_maflinked_ncds"
fi

# Trinucleotide substitutions graphs (with error probability)
# echo "---making graphs of the trinucleotide substitutions (with error probability)"
# generate_graph "$org2tsv_errprb" "$r_scripts_path/sbmut.R"
# generate_graph "$org3tsv_errprb" "$r_scripts_path/sbmut.R"

# Trinucleotide substitutions graphs (with error probability and maf-linked)
# echo "---making graphs of the trinucleotide substitutions (with error probability and maf-linked)"
# generate_graph "$org2tsv_maflinked_errprb" "$r_scripts_path/sbmut.R"
# generate_graph "$org3tsv_maflinked_errprb" "$r_scripts_path/sbmut.R"
