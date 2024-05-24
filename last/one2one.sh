#!/bin/bash

# module load last/1542
# lastal --version

argNum=6
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "- today's date" 1>&2                                                   # $1
	echo "- path to the output dir" 1>&2                                         # $2
	echo "- path to the org1 reference fasta file (the top genome in .maf)" 1>&2 # $3
	echo "- path to the org2 reference fasta file" 1>&2                          # $4
	echo "- org1 name" 1>&2                                                      # $5
	echo "- org2 name" 1>&2                                                      # $6
	exit 1
fi

DATE=$1
outDirPath=$2
org1FASTA=$3
org2FASTA=$4
org1Name=$5
org2Name=$6
dbName="$org1Name""db_$DATE"
trainFile="$org1Name""2""$org2Name""_one2one_$DATE.train"
m2omaf="$org1Name""2""$org2Name""_many2one_$DATE.maf"
o2omaf="$org1Name""2""$org2Name""_one2one_$DATE.maf"
# sam="$org1Name""2""$org2Name""_one2one_$DATE.sam"
pngFile="$org1Name""2""$org2Name""_one2one_$DATE.png"

# get the approximate length of the query sequence
# and set Dopt
# result=$(grep -v "^>" $org2FASTA | wc -c)
# power=$(echo "scale=10; l($result) / l(10)" | bc -l)
# num=$(echo "scale=0; $power/1" | bc)
# Dopt="1e$num"

# set the Dopt based on the query sequence length
Dopt=$(grep -v "^>" $org2FASTA | tr -d acgtACGT | wc -c)

echo "Date: $DATE"
echo "outDirPath: $outDirPath"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org1Name: $org1Name"
echo "org2Name: $org2Name"
echo "dbName: $dbName"
echo "trainFile: $trainFile"
echo "m2omaf: $m2omaf"
echo "o2omaf: $o2omaf"
echo "pngFile: $pngFile"
echo "result: $result"
echo "power: $power"
echo "num: $num"
echo "Dopt: $Dopt"

if [ ! -d $outDirPath ]; then
	echo "making $outDirPath"
	mkdir $outDirPath
fi
cd $outDirPath

# lastdb
echo "---lastdb"
if [ ! -d $outDirPath/$dbName ]; then
	echo "making lastdb"
	mkdir $dbName
	cd $dbName
	lastdb -P8 -c $dbName $org1FASTA
	cd ..
else
	echo "$dbName already exists"
fi

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
	echo "doing last-train"
	last-train -P8 --revsym -C2 $dbName/$dbName $org2FASTA >$trainFile
else
	echo "$trainFile already exists"
fi

# lastal
echo "---lastal"
if [ ! -e $m2omaf ]; then
	echo "doing lastal"
	lastal -P8 -D$Dopt -C2 --split-f=MAF+ -p $trainFile $dbName/$dbName $org2FASTA >$m2omaf
else
	echo "$m2omaf already exists"
fi

# last-split
echo "---last-split"
if [ ! -e $o2omaf ]; then
	echo "doing last-split"
	last-split -r $m2omaf >$o2omaf
else
	echo "$o2omaf already exists"
fi

# maf-convert sam
# if [ ! -e $sam ]; then
# 	echo "converting maf to sam"
# 	maf-convert -j1e5 -d sam $o2omaf >$sam
# else
# 	echo "$sam already exists"
# fi

# last-dotplot
# echo "---last-dotplot"
# if [ ! -e $pngFile ]; then
# 	echo "making $pngFile"
# 	last-dotplot $o2omaf $pngFile
# else
# 	echo "$pngFile already exists"
# fi
