#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 arguments." 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1
trainFile="b_floridae_transcript_$DATE.train"
mafFile="b_floridae_transcript_to_genome_$DATE.maf"
samFile="b_floridae_transcript_to_genome_$DATE.sam"

# CHANGE DIRECTORY
cd ~/big_oiks/lanc_oik_last/

#last-train B.floridae transcriptome 
# -P8: "makes it faster by using 8 parallel threads: adjust as suitable for your computer.
#         this has no effect on the result"
# -X1: "tells it to treat Ns in the reference sequences as unknown bases" 
# -m100: Maximum multiplicity for initial matches.  Each initial match is
#        lengthened until it occurs at most this many times in the reference. "makes it more slow-and-sensitive than the default"
echo "doing last-train"
last-train -P8 --revsym -X1 -m100 F-Lanceletdb/F-Lanceletdb ../lancelets/transcriptome/GETA01.1.fsa_nt > $trainFile

# lastal --split OKI2018_I69.transcriptonme.fa 
# -D10: Report alignments that are expected by chance at most once per LENGTH query letters.
############################################## 
# CAVEAT: unknown intron length distribution #
##############################################
echo "doing alignment"
lastal -P8 -D10 --split-d 2 -p $trainFile F-Lanceletdb/F-Lanceletdb ../lancelets/transcriptome/GETA01.1.fsa_nt | last-postmask > $mafFile 
# maf-convert
echo "maf-converting"
maf-convert -j1e6 -d sam $mafFile > $samFile
