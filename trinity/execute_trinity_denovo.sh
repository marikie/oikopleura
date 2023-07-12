#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi
# --CPU, --max_memory, --min_contig_length

DATE=$1
seqType='fq'
libType='FR'
readDir="/big/mrk/oikopleura/rna-seq-data/maturedAdults"
read1Path="$readDir/ERR4570987_1_filtered_trimmed_sorted.fastq"
read2Path="$readDir/ERR4570987_2_filtered_trimmed_sorted.fastq"
devStage='maturedAdults'
outputDir="/big/mrk/oikopleura/trinity/trinity_denovo_${devStage}_$DATE"

if [ ! -d  $outputDir ]; then
        echo "making output dir"
        mkdir $outputDir
else
        echo "$outputDir already exists."
fi

export SINGULARITY_BIND="$readDir:$readDir,$outputDir:$outputDir"

# Trinity
singularity exec -e $HOME/.local/src/trinityrnaseq.v2.15.1.simg  Trinity \
--seqType $seqType  \
--left $read1Path --right $read2Path --SS_lib_type $libType \
--CPU 10 --min_contig_length 100 --max_memory 50G \
--verbose \
--output $outputDir
