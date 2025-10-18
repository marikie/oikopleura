#!/bin/bash

lastal --version

# Resolve script locations and configuration relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAST_DIR="$SCRIPT_DIR"
ANALYSIS_DIR="$ROOT_DIR/analysis"
R_DIR="$ANALYSIS_DIR/R"

# Allow callers to override directories, otherwise rely on inferred paths
LAST_DIR="${LAST_DIR_OVERRIDE:-$LAST_DIR}"
ANALYSIS_DIR="${ANALYSIS_DIR_OVERRIDE:-$ANALYSIS_DIR}"
R_DIR="${R_DIR_OVERRIDE:-$R_DIR}"

# Ensure helper scripts are discoverable without absolute paths
PATH="$LAST_DIR:$PATH"

config_file="$SCRIPT_DIR/sbst_config.yaml"

# Load YAML configuration using yq
if [ ! -f "$config_file" ]; then
    echo "Configuration file not found!" 1>&2
    exit 1
fi

# Function to get config values using yq
get_config() {
    yq eval "$1" "$config_file"
}

extract_accession_from_path() {
    local input_path=$1
    local base
    base=$(basename "$input_path")

    if [[ $base =~ ^(G[CF]A_[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    if [[ $base =~ ^(G[CF]A_[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    echo ""
}

# Get required arguments count from config
argNum=$(get_config '.settings.required_args')
if [ $# -ne "$argNum" ]; then
    echo "$(get_config '.errors.arg_count' | sed "s/{arg_num}/$argNum/g")" 1>&2
    echo "$(get_config '.errors.usage')" 1>&2
    exit 1
fi

DATE=$1
org1FASTA=$2
org2FASTA=$3
org3FASTA=$4
org1GFF=$5

# Extract the name of the parent directory of $org1FASTA
org1DirName="$(basename $(dirname $org1FASTA))"
org2DirName="$(basename $(dirname $org2FASTA))"
org3DirName="$(basename $(dirname $org3FASTA))"

org1FullName="${org1DirName}_1"
org2FullName="${org2DirName}_2"
org3FullName="${org3DirName}_3"

# make short names
org1ShortName="${org1FullName:0:3}$(echo $org1FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)1"
org2ShortName="${org2FullName:0:3}$(echo $org2FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)2"
org3ShortName="${org3FullName:0:3}$(echo $org3FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)3"

org1ID=$(extract_accession_from_path "$org1FASTA")
org2ID=$(extract_accession_from_path "$org2FASTA")
org3ID=$(extract_accession_from_path "$org3FASTA")

if [ -z "$org1ID" ] || [ -z "$org2ID" ] || [ -z "$org3ID" ]; then
    echo "Error: Could not extract accession IDs from FASTA paths." 1>&2
    exit 1
fi

# Use config patterns to generate filenames
outDirPath="$(get_config '.paths.out_dir')/""$org1ShortName""_""$org2ShortName""_""$org3ShortName"

gcContent_org2=$(get_config '.patterns.gc_content' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
gcContent_org3=$(get_config '.patterns.gc_content' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

sbstRatio=$(get_config '.patterns.sbst_ratio' | sed "s/{date}/$DATE/g")
sbstRatio_maflinked=$(get_config '.patterns.sbst_ratio_maflinked' | sed "s/{date}/$DATE/g")

dbName="$org1ShortName""db_$DATE"
m2o12=$(get_config '.patterns.many2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
m2o13=$(get_config '.patterns.many2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
o2o12=$(get_config '.patterns.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
o2o13=$(get_config '.patterns.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
train12=$(get_config '.patterns.train' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
train13=$(get_config '.patterns.train' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

joinedFile=$(get_config '.patterns.joined' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{org3_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

o2o12_maflinked=$(get_config '.patterns.maflinked' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
o2o13_maflinked=$(get_config '.patterns.maflinked' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
joinedFile_maflinked=$(get_config '.patterns.joined_maflinked' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{org3_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

joinedFile_ncds=$(get_config '.patterns.joined_ncds' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{org3_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
joinedFile_maflinked_ncds=$(get_config '.patterns.joined_maflinked_ncds' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g" | sed "s/{org3_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

org2tsv="${org2ID}_${org2ShortName}_${DATE}.tsv"
org3tsv="${org3ID}_${org3ShortName}_${DATE}.tsv"
org2tsv_maflinked="${org2ID}_${org2ShortName}_${DATE}_maflinked.tsv"
org3tsv_maflinked="${org3ID}_${org3ShortName}_${DATE}_maflinked.tsv"
org2tsv_errprb="${org2ID}_${org2ShortName}_${DATE}_errprb.tsv"
org3tsv_errprb="${org3ID}_${org3ShortName}_${DATE}_errprb.tsv"
org2tsv_maflinked_errprb="${org2ID}_${org2ShortName}_${DATE}_maflinked_errprb.tsv"
org3tsv_maflinked_errprb="${org3ID}_${org3ShortName}_${DATE}_maflinked_errprb.tsv"

org2_dinuc_tsv="${org2ID}_${org2ShortName}_${DATE}_dinuc.tsv"
org3_dinuc_tsv="${org3ID}_${org3ShortName}_${DATE}_dinuc.tsv"
org2_dinuc_tsv_maflinked="${org2ID}_${org2ShortName}_${DATE}_maflinked_dinuc.tsv"
org3_dinuc_tsv_maflinked="${org3ID}_${org3ShortName}_${DATE}_maflinked_dinuc.tsv"

org2tsv_ncds="${org2ID}_${org2ShortName}_${DATE}_ncds.tsv"
org3tsv_ncds="${org3ID}_${org3ShortName}_${DATE}_ncds.tsv"
org2tsv_maflinked_ncds="${org2ID}_${org2ShortName}_${DATE}_maflinked_ncds.tsv"
org3tsv_maflinked_ncds="${org3ID}_${org3ShortName}_${DATE}_maflinked_ncds.tsv"
org2_dinuc_tsv_ncds="${org2ID}_${org2ShortName}_${DATE}_dinuc_ncds.tsv"
org3_dinuc_tsv_ncds="${org3ID}_${org3ShortName}_${DATE}_dinuc_ncds.tsv"
org2_dinuc_tsv_maflinked_ncds="${org2ID}_${org2ShortName}_${DATE}_maflinked_dinuc_ncds.tsv"
org3_dinuc_tsv_maflinked_ncds="${org3ID}_${org3ShortName}_${DATE}_maflinked_dinuc_ncds.tsv"

org2bed=$(get_config '.patterns.bed' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3bed=$(get_config '.patterns.bed' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2bed_maflinked=$(get_config '.patterns.bed_maflinked' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3bed_maflinked=$(get_config '.patterns.bed_maflinked' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

org2_out=$(get_config '.patterns.graph.out' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_out=$(get_config '.patterns.graph.out' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_out_sbstCount=$(get_config '.patterns.graph.sbst' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_out_sbstCount=$(get_config '.patterns.graph.sbst' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_out_oriCount=$(get_config '.patterns.graph.ori' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_out_oriCount=$(get_config '.patterns.graph.ori' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_out=$(get_config '.patterns.graph_maflinked.out' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_out=$(get_config '.patterns.graph_maflinked.out' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_out_sbstCount=$(get_config '.patterns.graph_maflinked.sbst' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_out_sbstCount=$(get_config '.patterns.graph_maflinked.sbst' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_out_oriCount=$(get_config '.patterns.graph_maflinked.ori' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_out_oriCount=$(get_config '.patterns.graph_maflinked.ori' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_errprb_out=$(get_config '.patterns.graph_errprb.out' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_errprb_out=$(get_config '.patterns.graph_errprb.out' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_errprb_out_sbstCount=$(get_config '.patterns.graph_errprb.sbst' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_errprb_out_sbstCount=$(get_config '.patterns.graph_errprb.sbst' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_errprb_out_oriCount=$(get_config '.patterns.graph_errprb.ori' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_errprb_out_oriCount=$(get_config '.patterns.graph_errprb.ori' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_errprb_out=$(get_config '.patterns.graph_maflinked_errprb.out' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_errprb_out=$(get_config '.patterns.graph_maflinked_errprb.out' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_errprb_out_sbstCount=$(get_config '.patterns.graph_maflinked_errprb.sbst' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_errprb_out_sbstCount=$(get_config '.patterns.graph_maflinked_errprb.sbst' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_maflinked_errprb_out_oriCount=$(get_config '.patterns.graph_maflinked_errprb.ori' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_maflinked_errprb_out_oriCount=$(get_config '.patterns.graph_maflinked_errprb.ori' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")


if [ ! -d "$outDirPath" ]; then
	echo "---making $outDirPath"
	mkdir "$outDirPath"
fi
cd "$outDirPath"
if [ ! -d "$DATE" ]; then
	echo "---making $DATE"
	mkdir "$DATE"
fi
cd "$DATE"
outDirPath=$(pwd)
echo "pwd: $(pwd)"

# GC content
echo "$(get_config '.messages.gc_content')"
if [ ! -e "$gcContent_org2" ]; then
echo "time bash $LAST_DIR/gc_content.sh $org2FASTA >$gcContent_org2"
time bash "$LAST_DIR/gc_content.sh" "$org2FASTA" >"$gcContent_org2"
else
	echo "$gcContent_org2 already exists"
fi
if [ ! -e "$gcContent_org3" ]; then
echo "time bash $LAST_DIR/gc_content.sh $org3FASTA >$gcContent_org3"
time bash "$LAST_DIR/gc_content.sh" "$org3FASTA" >"$gcContent_org3"
else
	echo "$gcContent_org3 already exists"
fi


# Run last-train to check substitution percent identity between org2 and org3 (inner group)
echo "$(get_config '.options.checkInnerGroupIdt.enabled_message')"
time bash "$LAST_DIR/last_train.sh" "$DATE" "$org2FASTA" "$org3FASTA" "$org2ShortName" "$org3ShortName"

# one2one for org1-org2
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g")"
echo "bash $LAST_DIR/one2one.sh $DATE $org1FASTA $org2FASTA $dbName $train12 $m2o12 $o2o12 $o2o12_maflinked"
bash "$LAST_DIR/one2one.sh" "$DATE" "$org1FASTA" "$org2FASTA" "$dbName" "$train12" "$m2o12" "$o2o12" "$o2o12_maflinked"

# one2one for org1-org3
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g")"
echo "bash $LAST_DIR/one2one.sh $DATE $org1FASTA $org3FASTA $dbName $train13 $m2o13 $o2o13 $o2o13_maflinked"
bash "$LAST_DIR/one2one.sh" "$DATE" "$org1FASTA" "$org3FASTA" "$dbName" "$train13" "$m2o13" "$o2o13" "$o2o13_maflinked"

# maf-join the two .maf files (without maf-linked)
echo "$(get_config '.messages.maf_join')"
echo "bash $LAST_DIR/mafjoin.sh $o2o12 $o2o13 $joinedFile"
bash "$LAST_DIR/mafjoin.sh" "$o2o12" "$o2o13" "$joinedFile"

# maf-join the two .maf files (with maf-linked)
echo "$(get_config '.messages.maf_join') with maf-linked"
echo "bash $LAST_DIR/mafjoin.sh $o2o12_maflinked $o2o13_maflinked $joinedFile_maflinked"
bash "$LAST_DIR/mafjoin.sh" "$o2o12_maflinked" "$o2o13_maflinked" "$joinedFile_maflinked"

# Calculate the substitution ratio without considering neighboring bases
echo "$(get_config '.messages.sbst_ratio')"
if [ ! -e "$sbstRatio" ]; then
echo "time python $ANALYSIS_DIR/subRatio.py $joinedFile >$sbstRatio"
time python "$ANALYSIS_DIR/subRatio.py" "$joinedFile" >"$sbstRatio"
else
    echo "$sbstRatio already exists"
fi

# Calculate the substitution ratio without considering neighboring bases for maf-linked
echo "$(get_config '.messages.sbst_ratio') with maf-linked"
if [ ! -e "$sbstRatio_maflinked" ]; then
echo "time python $ANALYSIS_DIR/subRatio.py $joinedFile_maflinked >$sbstRatio_maflinked"
time python "$ANALYSIS_DIR/subRatio.py" "$joinedFile_maflinked" >"$sbstRatio_maflinked"
else
    echo "$sbstRatio_maflinked already exists"
fi

# Generate dinuc .tsv files
if [ ! -e "$org2_dinuc_tsv" ] || [ ! -e "$org3_dinuc_tsv" ]; then
	echo "$(get_config '.messages.dinuc_tsv')"
echo "time python $ANALYSIS_DIR/disbst_2TSVs.py $joinedFile -o2 $org2_dinuc_tsv -o3 $org3_dinuc_tsv"
time python "$ANALYSIS_DIR/disbst_2TSVs.py" "$joinedFile" -o2 "$org2_dinuc_tsv" -o3 "$org3_dinuc_tsv"
else
	echo "$org2_dinuc_tsv and $org3_dinuc_tsv already exists"
fi

# Generate dinuc .tsv files (with maf-linked)
if [ ! -e "$org2_dinuc_tsv_maflinked" ] || [ ! -e "$org3_dinuc_tsv_maflinked" ]; then
	echo "$(get_config '.messages.dinuc_tsv') with maf-linked"
echo "time python $ANALYSIS_DIR/disbst_2TSVs.py $joinedFile_maflinked -o2 $org2_dinuc_tsv_maflinked -o3 $org3_dinuc_tsv_maflinked"
time python "$ANALYSIS_DIR/disbst_2TSVs.py" "$joinedFile_maflinked" -o2 "$org2_dinuc_tsv_maflinked" -o3 "$org3_dinuc_tsv_maflinked"
else
	echo "$org2_dinuc_tsv_maflinked and $org3_dinuc_tsv_maflinked already exists"
fi

# If there is a gff file of org1, cut off the CDS regions
# and count the number of substitutions in non-coding regions
if [ "$org1GFF" != "NO_GFF_FILE" ]; then
	echo "There is a gff file of org1"
	echo "maf-cut (cut off the CDS regions)"
	"$ANALYSIS_DIR/maf-cut-cds_uglier.py" \
		"$org1GFF" \
		"$joinedFile" >"$joinedFile_ncds"
	"$ANALYSIS_DIR/maf-cut-cds_uglier.py" \
		"$org1GFF" \
		"$joinedFile_maflinked" >"$joinedFile_maflinked_ncds"

	# Generate all TSV files including ncds files
	bash "$LAST_DIR/generate_tsv_files.sh" \
		"$joinedFile" \
		"$joinedFile_maflinked" \
		"$org2tsv" \
		"$org3tsv" \
		"$org2tsv_maflinked" \
		"$org3tsv_maflinked" \
		"$org2tsv_errprb" \
		"$org3tsv_errprb" \
		"$org2tsv_maflinked_errprb" \
		"$org3tsv_maflinked_errprb" \
		"$ANALYSIS_DIR" \
		"$org2_dinuc_tsv" \
		"$org3_dinuc_tsv" \
		"$org2_dinuc_tsv_maflinked" \
		"$org3_dinuc_tsv_maflinked" \
		"$joinedFile_ncds" \
		"$joinedFile_maflinked_ncds" \
		"$org2tsv_ncds" \
		"$org3tsv_ncds" \
		"$org2tsv_maflinked_ncds" \
		"$org3tsv_maflinked_ncds" \
		"$org2_dinuc_tsv_ncds" \
		"$org3_dinuc_tsv_ncds" \
		"$org2_dinuc_tsv_maflinked_ncds" \
		"$org3_dinuc_tsv_maflinked_ncds"
else
	echo "There is no gff file of org1"
	# Generate all TSV files (no ncds files)
	bash "$LAST_DIR/generate_tsv_files.sh" \
		"$joinedFile" \
		"$joinedFile_maflinked" \
		"$org2tsv" \
		"$org3tsv" \
		"$org2tsv_maflinked" \
		"$org3tsv_maflinked" \
		"$org2tsv_errprb" \
		"$org3tsv_errprb" \
		"$org2tsv_maflinked_errprb" \
		"$org3tsv_maflinked_errprb" \
		"$ANALYSIS_DIR" \
		"$org2_dinuc_tsv" \
		"$org3_dinuc_tsv" \
		"$org2_dinuc_tsv_maflinked" \
		"$org3_dinuc_tsv_maflinked"
fi

# Generate all graphs
bash "$LAST_DIR/generate_graphs.sh" \
    "$org2tsv" \
    "$org3tsv" \
    "$org2tsv_maflinked" \
    "$org3tsv_maflinked" \
    "$org2tsv_errprb" \
    "$org3tsv_errprb" \
    "$org2tsv_maflinked_errprb" \
    "$org3tsv_maflinked_errprb" \
	"$org2_out" \
	"$org3_out" \
	"$org2_out_sbstCount" \
	"$org3_out_sbstCount" \
	"$org2_out_oriCount" \
	"$org3_out_oriCount" \
	"$org2_maflinked_out" \
	"$org3_maflinked_out" \
	"$org2_maflinked_out_sbstCount" \
	"$org3_maflinked_out_sbstCount" \
	"$org2_maflinked_out_oriCount" \
	"$org3_maflinked_out_oriCount" \
	"$org2_errprb_out" \
	"$org3_errprb_out" \
	"$org2_errprb_out_sbstCount" \
	"$org3_errprb_out_sbstCount" \
	"$org2_errprb_out_oriCount" \
	"$org3_errprb_out_oriCount" \
	"$org2_maflinked_errprb_out" \
	"$org3_maflinked_errprb_out" \
	"$org2_maflinked_errprb_out_sbstCount" \
	"$org3_maflinked_errprb_out_sbstCount" \
	"$org2_maflinked_errprb_out_oriCount" \
	"$org3_maflinked_errprb_out_oriCount" \
	"$org2_dinuc_tsv" \
	"$org3_dinuc_tsv" \
	"$org2_dinuc_tsv_maflinked" \
	"$org3_dinuc_tsv_maflinked" \
	"$R_DIR"

collect_pca_script="$LAST_DIR/collect_for_pca.sh"
if [ -x "$collect_pca_script" ]; then
    bash "$collect_pca_script" \
        "$DATE" \
        "$org1ID" "$org2ID" "$org3ID" \
        "$org1ShortName" "$org2ShortName" "$org3ShortName" \
        "$org1DirName" "$org2DirName" "$org3DirName" \
        "$outDirPath"
else
    echo "Warning: collect_for_pca.sh not found or not executable at $collect_pca_script" >&2
fi
