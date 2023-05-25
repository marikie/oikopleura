#!/bin/bash

if [ $# -ne 6 ]; then
        echo "You need 6 argument" 1>&2
        echo "- today's date" 1>&2
        echo "- seqType (fa or fq)" 1>&2
        echo "- library type (paired: RF or FR, single: F or R)" 1>&2
        echo "- path of Read1 file" 1>&2
        echo "- path of Read2 file" 1>&2
        echo "- developping stage of oiks (embryo, immature, or matured)" 1>&2
        exit 1
fi
# --CPU, --max_memory, --min_contig_length

DATE=$1
seqType=$2
libType=$3
read1Path=$4
read2Path=$5
devStage=$6
outputDir="trinity_denovo_${devStage}_$DATE"

#if [ ! -d  $outputDir ]; then
#        mkdir $outputDir
#fi

singularity exec -e $HOME/.local/src/trinityrnaseq.v2.15.1.simg  Trinity \
--seqType $seqType  \
--left $read1Path --right $read2Path --SS_lib_type $libType \
--CPU 10 --min_contig_length 100 --max_memory 50G \
--verbose --output $outputDir
