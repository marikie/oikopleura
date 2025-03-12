#!/bin/bash

argNum=4
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "- today's date" 1>&2                              # $1
	echo "- path to the lanc_eshark_last dir" 1>&2          # $2
	echo "- path to the lancelet's lastdb dir" 1>&2         # $3
	echo "- path to the eshark's reference fasta file" 1>&2 # $4
	exit 1
fi

DATE=$1
outDirPath=$2
dbDirPath=$3
# ectract the directory name from dbDirPath
dbName=$(basename $dbDirPath)
eshkFASTA=$4
trainFile="Eshk2Lanc_$DATE.train"
maf="eshk2lanc_many2one_$DATE.maf"
sam="eshk2lanc_many2one_$DATE.sam"
pngFile="eshk2lanc_many2one_$DATE.png"

cd $outDirPath

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
	echo "doing last-train"
	last-train -P8 --revsym -D1e7 --sample-number=5000 $dbDirPath/$dbName $eshkFASTA >$trainFile
else
	echo "$trainFile already exists"
fi
# --revsym: Force the substitution scores to have reverse-complement
#           symmetry, e.g. score(A→G) = score(T→C).  This is often
#           appropriate, if neither strand is "special".
# --sample-number=5000: makes last-train use more samples of genome2,
#                       for fear that most of genome2 lacks similarity to genome1.
# -D1e7: Report alignments that are expected
#        by chance at most once per LENGTH query letters
#        The defalt sample-length is 2000, so the total number of query letters
#        are 10^7. Thus the expected number of alignments by chance is at most one.

# lastal
echo "---lastal"
if [ ! -e $maf ]; then
	echo "doing lastal"
	lastal -P8 -D1e9 -m100 --split-f=MAF+ -p $trainFile $dbDirPath/$dbName $eshkFASTA | last-postmask >$maf
else
	echo "$maf already exists"
fi
# --split-f=MAF+: has the same effect as --split, and also makes
#                 it show per-base mismap probabilities: the probability that each
#                 query (chimp) base should be aligned to a different part of the
#                 reference (human).
# -m100: Maximum multiplicity for initial matches.  Each initial match is
#        lengthened until it occurs at most this many times in the reference.
#        If the reference was split into volumes by lastdb, then lastal
#        uses one volume at a time.  The maximum multiplicity then applies
#        to each volume, not the whole reference.  This is why voluming
#        changes the results. (How to decide the num of multiplicity??)

# The result so far is asymmetric: each part of the chimp genome is
# aligned to at most one part of the human genome, but not vice-versa.
# (one-to-many alignment)

# eshk query length = 10 ^ 9.
# with -D1e9, the expected number of alignments found by chance is at most 1.

# maf-convert sam
if [ ! -e $sam ]; then
	echo "converting maf to sam"
	maf-convert -j1e5 -d sam $maf >$sam
else
	echo "$sam already exists"
fi

# last-dotplot
echo "---last-dotplot"
if [ ! -e $pngFile ]; then
	echo "making $pngFile"
	last-dotplot $maf $pngFile
else
	echo "$pngFile already exists"
fi
