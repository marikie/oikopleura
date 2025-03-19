#!/bin/bash

module load last/1608
lastal --version
module load yq/4.45.1

config_file="/home/mrk/scripts/last/sbst_config.yaml"

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
if [ $# -ne $argNum ]; then
    echo "$(get_config '.errors.arg_count' | sed "s/{arg_num}/$argNum/g")" 1>&2
    echo "$(get_config '.errors.usage')" 1>&2
    exit 1
fi

DATE=$1
org1FASTA=$2
org2FASTA=$3
org3FASTA=$4
org1FullName=$5
org2FullName=$6
org3FullName=$7

# make short names
org1ShortName="${org1FullName:0:3}$(echo $org1FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org2ShortName="${org2FullName:0:3}$(echo $org2FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org3ShortName="${org3FullName:0:3}$(echo $org3FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"

outDirPath=$8/$org1ShortName"_"$org2ShortName"_"$org3ShortName

# Use config patterns to generate filenames
gcContent_org2=$(get_config '.patterns.gc_content' | sed "s/{org_short}/$org2ShortName/g" | sed "s/{date}/$DATE/g")
gcContent_org3=$(get_config '.patterns.gc_content' | sed "s/{org_short}/$org3ShortName/g" | sed "s/{date}/$DATE/g")

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


if [ ! -d $outDirPath ]; then
	echo "---making $outDirPath"
	mkdir $outDirPath
fi
cd $outDirPath

# GC content
echo "$(get_config '.messages.gc_content')"
if [ ! -e $gcContent_org2 ]; then
	echo "time python $(get_config '.paths.scripts.analysis')/gc_content.py $org2FASTA >$gcContent_org2"
	time python $(get_config '.paths.scripts.analysis')/gc_content.py $org2FASTA >$gcContent_org2
else
	echo "$gcContent_org2 already exists"
fi
if [ ! -e $gcContent_org3 ]; then
	echo "time python $(get_config '.paths.scripts.analysis')/gc_content.py $org3FASTA >$gcContent_org3"
	time python $(get_config '.paths.scripts.analysis')/gc_content.py $org3FASTA >$gcContent_org3
else
	echo "$gcContent_org3 already exists"
fi

# one2one for org1-org2
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org2ShortName/g")"
echo "bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $dbName $train12 $m2o12 $o2o12 $o2o12_maflinked"
bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $dbName $train12 $m2o12 $o2o12 $o2o12_maflinked

# one2one for org1-org3
echo "$(get_config '.messages.one2one' | sed "s/{org1_short}/$org1ShortName/g" | sed "s/{org2_short}/$org3ShortName/g")"
echo "bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $dbName $train13 $m2o13 $o2o13 $o2o13_maflinked"
bash $(get_config '.paths.scripts.last')/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $dbName $train13 $m2o13 $o2o13 $o2o13_maflinked

# maf-join the two .maf files (without maf-linked)
echo "$(get_config '.messages.maf_join')"
echo "bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12 $o2o13 $joinedFile"
bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12 $o2o13 $joinedFile

# maf-join the two .maf files (with maf-linked)
echo "$(get_config '.messages.maf_join') with maf-linked"
echo "bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12_maflinked $o2o13_maflinked $joinedFile_maflinked"
bash $(get_config '.paths.scripts.last')/mafjoin.sh $o2o12_maflinked $o2o13_maflinked $joinedFile_maflinked

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
    "$(get_config '.paths.scripts.analysis')"

echo "org2tsv: $org2tsv"
echo "org3tsv: $org3tsv"
echo "org2tsv_maflinked: $org2tsv_maflinked"
echo "org3tsv_maflinked: $org3tsv_maflinked"
echo "org2tsv_errprb: $org2tsv_errprb"
echo "org3tsv_errprb: $org3tsv_errprb"
echo "org2tsv_maflinked_errprb: $org2tsv_maflinked_errprb"
echo "org3tsv_maflinked_errprb: $org3tsv_maflinked_errprb"
echo "org2_out: $org2_out"
echo "org3_out: $org3_out"
echo "org2_out_sbstCount: $org2_out_sbstCount"
echo "org3_out_sbstCount: $org3_out_sbstCount"
echo "org2_out_oriCount: $org2_out_oriCount"
echo "org3_out_oriCount: $org3_out_oriCount"
echo "org2_maflinked_out: $org2_maflinked_out"
echo "org3_maflinked_out: $org3_maflinked_out"
echo "org2_maflinked_out_sbstCount: $org2_maflinked_out_sbstCount"
echo "org3_maflinked_out_sbstCount: $org3_maflinked_out_sbstCount"
echo "org2_maflinked_out_oriCount: $org2_maflinked_out_oriCount"
echo "org3_maflinked_out_oriCount: $org3_maflinked_out_oriCount"
echo "org2_errprb_out: $org2_errprb_out"
echo "org3_errprb_out: $org3_errprb_out"
echo "org2_errprb_out_sbstCount: $org2_errprb_out_sbstCount"
echo "org3_errprb_out_sbstCount: $org3_errprb_out_sbstCount"
echo "org2_errprb_out_oriCount: $org2_errprb_out_oriCount"
echo "org3_errprb_out_oriCount: $org3_errprb_out_oriCount"
echo "org2_maflinked_errprb_out: $org2_maflinked_errprb_out"
echo "org3_maflinked_errprb_out: $org3_maflinked_errprb_out"
echo "org2_maflinked_errprb_out_sbstCount: $org2_maflinked_errprb_out_sbstCount"
echo "org3_maflinked_errprb_out_sbstCount: $org3_maflinked_errprb_out_sbstCount"
echo "org2_maflinked_errprb_out_oriCount: $org2_maflinked_errprb_out_oriCount"
echo "org3_maflinked_errprb_out_oriCount: $org3_maflinked_errprb_out_oriCount"

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

# # make another .tsv file of the trinucleotide mutations
# # which contains all the substitutions in org2 and org3 with org1's trinucleotide info
# echo "---making another .tsv file of all the trinucleotide substitutions in org2 and org3 with org1's trinucleotide info"
# if [ ! -e $sbstFile ]; then
# 	python ~/scripts/analysis/triSbstTSV.py $joinedFile "./"$sbstFile
# else
# 	echo "$sbstFile already exists"
# fi

# # split the $sbstFile into $sbstFile_org2 and $sbstFile_org3
# echo "---splitting the $sbstFile into $sbstFile_org2 and $sbstFile_org3"
# if [ ! -e $sbstFile_org2 ] && [ ! -e $sbstFile_org3 ]; then
# 	python ~/scripts/analysis/split2twoFiles.py $sbstFile "./"$sbstFile_org2 "./"$sbstFile_org3
# else
# 	echo "$sbstFile_org2 and $sbstFile_org3 already exist"
# fi

# # assert $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other
# echo "---asserting $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other"
# # Extract and count sbstSig occurrences in sbstFile_org2
# awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org2" > sbst_counts2.txt
# # Compare with mutNum in sbst3File_org2
# awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org2" sbst_counts2.txt
# if [ $? -eq 0 ]; then
#     echo "Assertion passed: Files match"
# else
#     echo "Assertion failed: Files do not match"
#     exit 1
# fi

# # assert $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other
# echo "---asserting $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other"
# awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org3" > sbst_counts3.txt
# awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org3" sbst_counts3.txt
# if [ $? -eq 0 ]; then
#     echo "Assertion passed: Files match"
# else
#     echo "Assertion failed: Files do not match"
#     exit 1
# fi

# # make gff files for the CDSs
# echo "---making gff files for the CDSs"
# awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org2gff > $org2cdsGFF
# awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org3gff > $org3cdsGFF

# # bedtools intersect to get the trinucleotide substitutions in the CDSs
# # all
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (all)"
# if [ ! -e $cdsIntsct_all_org2 ]; then
# 	bedtools intersect -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_all_org2
# else
# 	echo "$cdsIntsct_all_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_all_org3 ]; then
# 	bedtools intersect -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_all_org3
# else
# 	echo "$cdsIntsct_all_org3 already exists"
# fi
# # same strand
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (same strand)"
# if [ ! -e $cdsIntsct_sameStrand_org2 ]; then
# 	bedtools intersect -s -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_sameStrand_org2
# else
# 	echo "$cdsIntsct_sameStrand_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_sameStrand_org3 ]; then
# 	bedtools intersect -s -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_sameStrand_org3
# else
# 	echo "$cdsIntsct_sameStrand_org3 already exists"
# fi
# # different strand
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (different strand)"
# if [ ! -e $cdsIntsct_diffStrand_org2 ]; then
# 	bedtools intersect -S -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_diffStrand_org2
# else
# 	echo "$cdsIntsct_diffStrand_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_diffStrand_org3 ]; then
# 	bedtools intersect -S -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_diffStrand_org3
# else
# 	echo "$cdsIntsct_diffStrand_org3 already exists"
# fi