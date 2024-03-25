#!/bin/bash

module load last/1542
lastal --version

argNum=7
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org1-org3.\n The top genome of each alignment .maf file will be org1." 1>&2
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
outDirPath=$6"/$org1Name_$org2Name_$org3Name"
o2omaf12="$org1Name""2""$org2Name""_one2one_$DATE.maf"
o2omaf13="$org1Name""2""$org3Name""_one2one_$DATE.maf"
o2omaf12_sorted="$org1Name""2""$org2Name""_one2one_$DATE_sorted.maf"
o2omaf13_sorted="$org1Name""2""$org3Name""_one2one_$DATE_sorted.maf"
joinedFile="$org1Name""_""$org2Name""_""$org3Name""_$DATE.maf"
mutFile="mut_"$(echo $joinedFile | sed -e "s/.maf//")".tsv"
mut3File="mut3_"$(echo $joinedFile | sed -e "s/.maf//")".tsv"
mut3Graph="$org1Name""_""$org2Name""_""$org3Name"".pdf"

bash ~/scripts/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name
bash ~/scripts/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name

# maf-join the two .maf files
maf-sort $o2oma12 >$o2omaf12_sorted
maf-sort $o2oma13 >$o2omaf13_sorted
maf-join $o2omaf12_sorted $o2omaf13_sorted >$joinedFile

# make a .tsv file about single-base mutations
# echo "making a .tsv file about single-base mutations"
# if [ ! -e $mutFile ]; then
# 	python ~/scripts/analysis/singleUvMuts.py $o2omaf $mutFile
# else
# 	echo "$mutFile already exists"
# fi

# make a .tsv file about trinucleotide mutations
echo "making a .tsv trinucleotide mutation file"
if [ ! -e $mut3File ]; then
	python ~/scripts/analysis/triUvMuts_joined.py $o2omaf $mut3File
else
	echo "$mut3File already exists"
fi

# make a graph of the trinucleotide mutations
echo "making a graph of the trinucleotide mutations"
if [ ! -e $mut3Graph ]; then
	Rscript ~/scripts/analysis/R/uvmut3spc.R $mut3File $outDirPath
else
	echo "$mut3Graph already exists"
fi
