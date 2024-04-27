#!/bin/bash

module load last/1542
lastal --version

argNum=8
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org1-org3. The top genome of each alignment .maf file will be org1. org1 should be in the outgroup." 1>&2
	echo "- today's date" 1>&2                                           # $1
	echo "- path to the org1 reference fasta file" 1>&2                  # $2
	echo "- path to the org2 reference fasta file" 1>&2                  # $3
	echo "- path to the org3 reference fasta file" 1>&2                  # $4
	echo "- org1 name" 1>&2                                              # $5
	echo "- org2 name" 1>&2                                              # $6
	echo "- org3 name" 1>&2                                              # $7
	echo "- path to the dir where you want to place the output dir" 1>&2 # $8
	exit 1
fi

DATE=$1
org1FASTA=$2
org2FASTA=$3
org3FASTA=$4
org1Name=$5
org2Name=$6
org3Name=$7
outDirPath="$8/$org1Name""_""$org2Name""_""$org3Name"
o2omaf12="$org1Name""2""$org2Name""_one2one_$DATE.maf"
o2omaf13="$org1Name""2""$org3Name""_one2one_$DATE.maf"
o2omaf12_sorted="$org1Name""2""$org2Name""_one2one_$DATE""_sorted.maf"
o2omaf13_sorted="$org1Name""2""$org3Name""_one2one_$DATE""_sorted.maf"
joinedFile="$org1Name""_""$org2Name""_""$org3Name""_$DATE.maf"
mutFile="mut_"$(echo $joinedFile | sed -e "s/.maf//")"_$DATE.tsv"
mut3File="mut3_"$(echo $joinedFile | sed -e "s/.maf//")"_$DATE.tsv"
mut3Graph="$org1Name""_""$org2Name""_""$org3Name""_$DATE.pdf"
mut3GraphOut="$org1Name""_""$org2Name""_""$org3Name""_$DATE.out"

echo "Date: $DATE"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org3FASTA: $org3FASTA"
echo "org1Name: $org1Name"
echo "org2Name: $org2Name"
echo "org3Name: $org3Name"
echo "outDirPath: $outDirPath"
echo "o2omaf12: $o2omaf12"
echo "o2omaf13: $o2omaf13"
echo "o2omaf12_sorted: $o2omaf12_sorted"
echo "o2omaf13_sorted: $o2omaf13_sorted"
echo "joinedFile: $joinedFile"
echo "mutFile: $mutFile"
echo "mut3File: $mut3File"
echo "mut3Graph: $mut3Graph"
echo "mut3GraphOut: $mut3GraphOut"

if [ ! -d $outDirPath ]; then
	echo "---making $outDirPath"
	mkdir $outDirPath
fi
cd $outDirPath

bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name &
bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name &
wait

# maf-join the two .maf files
echo "---maf-joining the two .maf files"
if [ ! -e $o2omaf12_sorted ]; then
	maf-sort $o2omaf12 >$o2omaf12_sorted
else
	echo "$o2omaf12_sorted already exists"
fi
if [ ! -e $o2omaf13_sorted ]; then
	maf-sort $o2omaf13 >$o2omaf13_sorted
else
	echo "$o2omaf13_sorted already exists"
fi
if [ ! -e $joinedFile ]; then
	maf-join $o2omaf12_sorted $o2omaf13_sorted >$joinedFile
else
	echo "$joinedFile already exists"
fi

# make a .tsv file about single-base mutations
# echo "making a .tsv file about single-base mutations"
# if [ ! -e $mutFile ]; then
# 	python ~/scripts/analysis/singleUvMuts.py $o2omaf $mutFile
# else
# 	echo "$mutFile already exists"
# fi

# make a .tsv file about trinucleotide mutations
echo "---making a .tsv trinucleotide mutation file"
if [ ! -e $mut3File ]; then
	python ~/scripts/analysis/triUvMuts_joined.py $joinedFile "./"$mut3File
else
	echo "$mut3File already exists"
fi

# make a graph of the trinucleotide mutations
echo "---making a graph of the trinucleotide mutations"
if [ ! -e $mut3Graph ]; then
	Rscript ~/scripts/analysis/R/uvMutations_3_smallinput.R $mut3File $outDirPath >$mut3GraphOut
else
	echo "$mut3Graph already exists"
fi

bash ~/scripts/last/one2one.sh $DATE $outDirPath $org2FASTA $org3FASTA $org2Name $org3Name