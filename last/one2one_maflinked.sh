#!/bin/bash
# one-to-one alignment with maf-linked

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
	time lastdb -P8 -c $dbName $org1FASTA
	cd ..
else
	echo "$dbName already exists"
fi
# -P8: makes it faster by using 8 threads (This has no effect on the results.)
# -c: Soft-mask lowercase letters.  This means that, when we compare
#     these sequences to some other sequences using lastal, lowercase
#     letters will be excluded from initial matches.  This will apply
#     to lowercase letters in both sets of sequences.

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
	echo "doing last-train"
	time last-train -P8 --revsym -C2 $dbName/$dbName $org2FASTA >$trainFile
else
	echo "$trainFile already exists"
fi
# --revsym: Force the substitution scores to have reverse-complement
#           symmetry, e.g. score(A→G) = score(T→C).  This is often
#           appropriate, if neither strand is "special".
# -C COUNT: Before extending gapped alignments, discard any gapless alignment whose query range lies in COUNT other gapless alignments with higher score-per-length. This aims to reduce run time. -C2 may reduce run time with little effect on accuracy.

# lastal
echo "---lastal"
if [ ! -e $m2omaf ]; then
	echo "doing lastal"
	time lastal -P8 -j4 -H1 -C2 --split-f=MAF+ -p $trainFile $dbName/$dbName $org2FASTA >$m2omaf
else
	echo "$m2omaf already exists"
fi
# -j4: show the confidence of each alignment column
# -H EXPECT: report alignments that are expected by chance at most EXPECT times, in all the sequences. This option requires reading the queries twice (to get their lengths before finding alignments), so it doesn't allow piped-in queries.

# last-split
echo "---last-split"
if [ ! -e $o2omaf ]; then
	echo "doing last-split"
	time last-split -r $m2omaf | maf-linked >$o2omaf
else
	echo "$o2omaf already exists"
fi
# -r: reverse the roles of the two sequences in each alignment: use the 1st(top) sequence as the query and the 2nd(bottom) sequence as the reference.

# maf-linked: maf-linked reads pair-wise sequence alignments in MAF format, and omits isolated alignments. It keeps groups of alignments that are nearby in both sequences. It may be useful for genome-to-genome alignments: It removes alignments between non-homologous insertions of homologous transposons