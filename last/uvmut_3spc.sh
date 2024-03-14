#!/bin/bash

module load last/1542
lastal --version

argNum=7
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org2-org3.\n The top genome of each alignment .maf file will be org2." 1>&2
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
o2omaf21="$org2Name""2""$org1Name""_one2one_$DATE.maf"
o2omaf23="$org2Name""2""$org3Name""_one2one_$DATE.maf"
o2omaf21_sorted="$org2Name""2""$org1Name""_one2one_$DATE_sorted.maf"
o2omaf23_sorted="$org2Name""2""$org3Name""_one2one_$DATE_sorted.maf"
joinedFile="$org1Name""_""$org2Name""_""$org3Name""_$DATE.maf"
mutFile="mut_"$(echo $joinedFile | sed -e "s/.maf//")".tsv"
mut3File="mut3_"$(echo $joinedFile | sed -e "s/.maf//")".tsv"

bash ~/scripts/one2one.sh $DATE $outDirPath $org2FASTA $org1FASTA $org2Name $org1Name
bash ~/scripts/one2one.sh $DATE $outDirPath $org2FASTA $org3FASTA $org2Name $org3Name

# maf-join the two .maf files
maf-sort $o2oma21 >$o2omaf21
# make a .tsv file about single-base mutations
echo "making a .tsv file about single-base mutations"
if [ ! -e $mutFile ]; then
	python ~/scripts/analysis/singleUvMuts.py $o2omaf $mutFile
else
	echo "$mutFile already exists"
fi

# make a .tsv file about trinucleotide mutations
echo "making a .tsv trinucleotide mutation file"
if [ ! -e $mut3File ]; then
	python ~/scripts/analysis/triUvMuts.py $o2omaf $mut3File
else
	echo "$mut3File already exists"
fi
