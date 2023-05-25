#!/bin/bash

if [ $# -ne 5 ]; then
        echo "You need 5 argument" 1>&2
        echo "- today's date" 1>&2
        echo "- library type (paired: RF or FR, single: F or R)" 1>&2
        echo "- path of alignment.bam file" 1>&2
        exit 1
fi
# --CPU, --max_memory, --min_contig_length, genome_guided_max_intron

DATE=$1
libType=$2
alignmentBamFile=$3
outputDir="$HOME/big_oiks/trinity_gguided_${alignmentBamFile:0:-4}_$DATE"

if [ ! -d  $outputDir ]; then
        mkdir $outputDir
fi

singularity exec -e $HOME/.local/src/trinityrnaseq.v2.15.1.simg  Trinity \
        --genome_guided_bam $alignmentBamFile \
        --genome_guided_max_intron 100000 \
        --SS_lib_type $libType \
        --max_memory 50G --CPU 10
