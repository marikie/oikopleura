#!/bin/bash

argNum=$#
if [ $argNum -ne 6 ]; then
    echo "Usage: $0 <Today's Date> <outDirPath> <org2FASTA> <org3FASTA> <org2ShortName> <org3ShortName>"
    exit 1
fi
# Get arguments
DATE=$1
outDirPath=$2
org2FASTA=$3
org3FASTA=$4
org2ShortName=$5
org3ShortName=$6

dbName="${org2ShortName}db_${DATE}"
trainFile="${org2ShortName}2${org3ShortName}_${DATE}.train"

# lastdb
echo "---lastdb"
if [ ! -d $outDirPath/$dbName ]; then
	echo "making lastdb"
	mkdir $dbName
	cd $dbName
	echo "time lastdb -P8 -c -uRY4 $dbName $org2FASTA"
	time lastdb -P8 -c -uRY4 $dbName $org2FASTA
	cd ..
else
	echo "$dbName already exists"
fi
# -P8: makes it faster by using 8 threads (This has no effect on the results.)
# -c: Soft-mask lowercase letters.  This means that, when we compare
#     these sequences to some other sequences using lastal, lowercase
#     letters will be excluded from initial matches.  This will apply
#     to lowercase letters in both sets of sequences.
# -uRY4: selects a seeding scheme that reduces the run time and memory use, but also reduces sensitivity.

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
	echo "time last-train -P8 --revsym -C2 $dbName/$dbName $org3FASTA >$trainFile"
	time last-train -P8 --revsym -C2 $dbName/$dbName $org3FASTA >$trainFile
else
	echo "$trainFile already exists"
fi
# --revsym: Force the substitution scores to have reverse-complement
#           symmetry, e.g. score(A→G) = score(T→C).  This is often
#           appropriate, if neither strand is "special".
# -C COUNT: Before extending gapped alignments, discard any gapless alignment whose query range lies in COUNT other gapless alignments with higher score-per-length. This aims to reduce run time. -C2 may reduce run time with little effect on accuracy.
