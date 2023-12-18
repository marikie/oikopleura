#!/bin/bash

argNum=4
if [ $# -ne $argNum ]; then
        echo "You need $argNum argument" 1>&2
        echo "- today's date" 1>&2
        echo "- path to the lanc_oik_last dir" 1>&2
        echo "- path to the lancelet's reference fasta file" 1>&2
        echo "- path to the oik's reference fasta file" 1>&2
        exit 1
fi

DATE=$1
outDirPath=$2
lancFASTA=$3
oikFASTA=$4
dbName="F-Lanceletdb_$DATE"
trainFile="Oik2Lanc_$DATE.train"
maf="oik2lanc_many2one_$DATE.maf"
sam="oik2lanc_many2one_$DATE.sam"
pngFile="oik2lanc_many2one_$DATE.png"

cd $outDirPath

# lastdb
echo "---lastdb"
if [ ! -d $outDirPath/$dbName ]; then
        echo "making lastdb"
        mkdir $dbName
        cd $dbName
        lastdb -P8 -uMAM8 -c $dbName $lancFASTA
        cd ..
else
        echo "$dbName already exists"
fi
        # -P8: makes it faster by using 8 threads (This has no effect on the results.)
        # -uMAM8: strives for high sensitivity, but use a lot of memory and run time.
        # -c: Soft-mask lowercase letters.  This means that, when we compare
        #     these sequences to some other sequences using lastal, lowercase
        #     letters will be excluded from initial matches.  This will apply
        #     to lowercase letters in both sets of sequences.

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
        echo "doing last-train"
        last-train -P8 --revsym -D1e7 --sample-number=5000 $dbName/$dbName $oikFASTA > $trainFile
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
        lastal -P8 -D1e7 -m100 --split-f=MAF+ -p $trainFile $dbName/$dbName $oikFASTA | last-postmask > $maf
else
        echo "$maf already exists"
fi

# maf-convert sam
if [ ! -e $sam ]; then
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam $maf > $sam
else
        echo "$sam already exists"
fi

# last-dotplot
echo "---last-dotplot"
if [ ! -e $pngFile ]; then
        echo "making $pngFile"
        #last-dotplot -a ~/oikdata/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff $maf $pngFile
        last-dotplot $maf $pngFile
else
        echo "$pngFile already exists"
fi
