#!/bin/bash

lastal --version

# Resolve config path relative to this script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$SCRIPT_DIR/sbst_config.yaml"

# Load YAML configuration using yq
if [ ! -f $config_file ]; then
    echo "Configuration file not found!" 1>&2
    exit 1
fi

# Function to get config values using yq
get_config() {
    yq eval "$1" $config_file
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
org1FullName=$(basename $(dirname $org1FASTA))
org2FullName=$(basename $(dirname $org2FASTA))
org3FullName=$(basename $(dirname $org3FASTA))

# make short names
org1ShortName="${org1FullName:0:3}$(echo $org1FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org2ShortName="${org2FullName:0:3}$(echo $org2FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org3ShortName="${org3FullName:0:3}$(echo $org3FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"

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

org2tsv=$(get_config '.patterns.tsv' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3tsv=$(get_config '.patterns.tsv' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2tsv_maflinked=$(get_config '.patterns.tsv_maflinked' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3tsv_maflinked=$(get_config '.patterns.tsv_maflinked' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2tsv_errprb=$(get_config '.patterns.tsv_errprb' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3tsv_errprb=$(get_config '.patterns.tsv_errprb' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2tsv_maflinked_errprb=$(get_config '.patterns.tsv_maflinked_errprb' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3tsv_maflinked_errprb=$(get_config '.patterns.tsv_maflinked_errprb' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

org2_dinuc_tsv=$(get_config '.patterns.dinuc_tsv' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_dinuc_tsv=$(get_config '.patterns.dinuc_tsv' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")
org2_dinuc_tsv_maflinked=$(get_config '.patterns.dinuc_maflinked_tsv' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
org3_dinuc_tsv_maflinked=$(get_config '.patterns.dinuc_maflinked_tsv' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

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
	echo "time bash $(get_config '.paths.scripts.last')/gc_content.sh $org2FASTA >$gcContent_org2"
	time bash $(get_config '.paths.scripts.last')/gc_content.sh "$org2FASTA" >"$gcContent_org2"
else
	echo "$gcContent_org2 already exists"
fi
if [ ! -e "$gcContent_org3" ]; then
	echo "time bash $(get_config '.paths.scripts.last')/gc_content.sh $org3FASTA >$gcContent_org3"
	time bash $(get_config '.paths.scripts.last')/gc_content.sh "$org3FASTA" >"$gcContent_org3"
else
	echo "$gcContent_org3 already exists"
fi


# Run last-train to check substitution percent identity between org2 and org3 (inner group)
echo "$(get_config '.options.checkInnerGroupIdt.enabled_message')"
time bash $(get_config '.paths.scripts.last')/last_train.sh "$DATE" "$outDirPath" "$org2FASTA" "$org3FASTA" "$org2ShortName" "$org3ShortName"

# one2one for org1-org2
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g")"
echo "bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $dbName $train12 $m2o12 $o2o12 $o2o12_maflinked"
bash $(get_config '.paths.scripts.last')/one2one.sh "$DATE" "$outDirPath" "$org1FASTA" "$org2FASTA" "$dbName" "$train12" "$m2o12" "$o2o12" "$o2o12_maflinked"

# one2one for org1-org3
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g")"
echo "bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $dbName $train13 $m2o13 $o2o13 $o2o13_maflinked"
bash $(get_config '.paths.scripts.last')/one2one.sh "$DATE" "$outDirPath" "$org1FASTA" "$org3FASTA" "$dbName" "$train13" "$m2o13" "$o2o13" "$o2o13_maflinked"

# maf-join the two .maf files (without maf-linked)
echo "$(get_config '.messages.maf_join')"
echo "bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12 $o2o13 $joinedFile"
bash $(get_config '.paths.scripts.last')/mafjoin.sh "$o2o12" "$o2o13" "$joinedFile"

# maf-join the two .maf files (with maf-linked)
echo "$(get_config '.messages.maf_join') with maf-linked"
echo "bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12_maflinked $o2o13_maflinked $joinedFile_maflinked"
bash $(get_config '.paths.scripts.last')/mafjoin.sh "$o2o12_maflinked" "$o2o13_maflinked" "$joinedFile_maflinked"

# Calculate the substitution ratio without considering neighboring bases
echo "$(get_config '.messages.sbst_ratio')"
if [ ! -e "$sbstRatio" ]; then
	echo "time python $(get_config '.paths.scripts.analysis')/subRatio.py $joinedFile >$sbstRatio"
	time python $(get_config '.paths.scripts.analysis')/subRatio.py "$joinedFile" >"$sbstRatio"
else
    echo "$sbstRatio already exists"
fi

# Calculate the substitution ratio without considering neighboring bases for maf-linked
echo "$(get_config '.messages.sbst_ratio') with maf-linked"
if [ ! -e "$sbstRatio_maflinked" ]; then
	echo "time python $(get_config '.paths.scripts.analysis')/subRatio.py $joinedFile_maflinked >$sbstRatio_maflinked"
	time python $(get_config '.paths.scripts.analysis')/subRatio.py "$joinedFile_maflinked" >"$sbstRatio_maflinked"
else
    echo "$sbstRatio_maflinked already exists"
fi

# Generate dinuc .tsv files
if [ ! -e "$org2_dinuc_tsv" ] || [ ! -e "$org3_dinuc_tsv" ]; then
	echo "$(get_config '.messages.dinuc_tsv')"
	echo "time python $(get_config '.paths.scripts.analysis')/disbst_2TSVs.py $joinedFile -o2 $org2_dinuc_tsv -o3 $org3_dinuc_tsv"
	time python $(get_config '.paths.scripts.analysis')/disbst_2TSVs.py "$joinedFile" -o2 "$org2_dinuc_tsv" -o3 "$org3_dinuc_tsv"
else
	echo "$org2_dinuc_tsv and $org3_dinuc_tsv already exists"
fi

# Generate dinuc .tsv files (with maf-linked)
if [ ! -e "$org2_dinuc_tsv_maflinked" ] || [ ! -e "$org3_dinuc_tsv_maflinked" ]; then
	echo "$(get_config '.messages.dinuc_tsv') with maf-linked"
	echo "time python $(get_config '.paths.scripts.analysis')/disbst_2TSVs.py $joinedFile_maflinked -o2 $org2_dinuc_tsv_maflinked -o3 $org3_dinuc_tsv_maflinked"
	time python $(get_config '.paths.scripts.analysis')/disbst_2TSVs.py "$joinedFile_maflinked" -o2 "$org2_dinuc_tsv_maflinked" -o3 "$org3_dinuc_tsv_maflinked"
else
	echo "$org2_dinuc_tsv_maflinked and $org3_dinuc_tsv_maflinked already exists"
fi

# If there is a gff file of org1, generate .tsv file and .bed file
# and count the number of substitutions in coding and non-coding regions
if [ "$org1GFF" != "NO_GFF_FILE" ]; then
	echo "There is a gff file of org1"
	echo "Making .tsv and .bed files"
	bash $(get_config '.paths.scripts.last')/generate_tsv_bed_files.sh \
		"$(get_config '.paths.scripts.analysis')" \
		"$joinedFile" \
		"$org2tsv" \
		"$org3tsv" \
		"$org2bed" \
		"$org3bed" \
		"$joinedFile_maflinked" \
		"$org2tsv_maflinked" \
		"$org3tsv_maflinked" \
		"$org2bed_maflinked" \
		"$org3bed_maflinked"

	echo "Counting the number of substitutions in coding and non-coding regions"
	bash $(get_config '.paths.scripts.last')/count_coding_noncoding.sh \
		"$org1GFF" \
		"$org2tsv" \
		"$org2bed" \
		"$org3tsv" \
		"$org3bed" \
		"$org2tsv_maflinked" \
		"$org3tsv_maflinked" \
		"$org2bed_maflinked" \
		"$org3bed_maflinked"
else
	echo "There is no gff file of org1"
	# Generate all TSV files
	bash $(get_config '.paths.scripts.last')/generate_tsv_files.sh \
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
		"$(get_config '.paths.scripts.analysis')" \
		"$org2_dinuc_tsv" \
		"$org3_dinuc_tsv" \
		"$org2_dinuc_tsv_maflinked" \
		"$org3_dinuc_tsv_maflinked"
fi

# Generate all graphs
bash $(get_config '.paths.scripts.last')/generate_graphs.sh \
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
	"$(get_config '.paths.scripts.r')"
