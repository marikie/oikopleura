#!/bin/bash
if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1
dbName="F-Lanceletdb"
trainFile="EShark2Lanc.train"
maf="eachESharkPart_OnePartInLanc_alignment_$DATE.maf"
sam="eachESharkPart_OnePartInLanc_alignment_$DATE.sam"
pngFile="eachESharkPart_OnePartInLanc_alignment_$DATE.png"

cd ~/oikopleura/lanc_eshark_last

# lastdb
echo "---lastdb"
if [ ! -d /home/mrk/oikopleura/lanc_eshark_last/$dbName ]; then
        echo "making lastdb"
        mkdir $dbName
        cd $dbName
        lastdb -P8 -uMAM8 $dbName ~/oikopleura/lancelets/genome_assemblies_branchiostoma_floridae/ncbi-genomes-2023-06-13/GCF_000003815.2_Bfl_VNyyK_genomic.fna
        cd ..
        # -P8: makes it faster by using 8 threads (This has no effect on the results.)
        # -uMAM8: strives for high sensitivity, but use a lot of memory and run time.

        # Should we use...
        # -c: Soft-mask lowercase letters.  This means that, when we compare
        #     these sequences to some other sequences using lastal, lowercase
        #     letters will be excluded from initial matches.  This will apply
        #     to lowercase letters in both sets of sequences.
else
        echo "$dbName already exists"
fi

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
        echo "doing last-train"
        last-train -P8 --revsym -E0.05 $dbName/$dbName ~/oikopleura/elephantShark/ncbi_dataset/data/GCF_018977255.1/GCF_018977255.1_IMCB_Cmil_1.0_genomic.fna > $trainFile
        # --revsym: Force the substitution scores to have reverse-complement
        #           symmetry, e.g. score(A→G) = score(T→C).  This is often
        #           appropriate, if neither strand is "special".
        # -E0.05: means only get significant alignments that would be
        #         expected to occur by chance at a rate ≤ 0.05 times per pair of random
        #         sequences of length 1 billion each.

        # Should we use...
        # -D1e9 instead of -E0.05?: Report alignments that are expected 
        #                           by chance at most once per
        #                           LENGTH query letters
        # --sample-number=5000: makes last-train use more samples of genome2, 
        #                       for fear that most of genome2 lacks similarity to genome1. 
        #                       For the same reason, -D1e9 is used with last-train,
        #                       to avoid weak chance similarities more strictly.
else
        echo "$trainFile already exists"
fi

# lastal 
echo "---lastal"
if [ ! -e $maf ]; then 
        echo "doing lastal"
        lastal -E0.05 --split-f=MAF+ -p $trainFile $dbName/$dbName ~/oikopleura/elephantShark/ncbi_dataset/data/GCF_018977255.1/GCF_018977255.1_IMCB_Cmil_1.0_genomic.fna | last-postmask > $maf
        # --split-f=MAF+: has the same effect as --split, and also makes
        #                 it show per-base mismap probabilities: the probability that each
        #                 query (chimp) base should be aligned to a different part of the
        #                 reference (human).

        # The result so far is asymmetric: each part of the chimp genome is
        # aligned to at most one part of the human genome, but not vice-versa.
        # (one-to-many alignment)

        # Should we use...
        # -D1e9 instead of -E0.05?
        # -m100: Maximum multiplicity for initial matches.  Each initial match is
        #        lengthened until it occurs at most this many times in the reference.
        #        If the reference was split into volumes by lastdb, then lastal
        #        uses one volume at a time.  The maximum multiplicity then applies
        #        to each volume, not the whole reference.  This is why voluming
        #        changes the results. (How to decide the num of multiplicity??)
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
        last-dotplot $maf $pngFile
else
        echo "$pngFile already exists"
fi
