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
readDir_emb="/big/mrk/oikopleura/rna-seq-data/embryos"
read1Path_emb="$readDir_emb/ERR4570985_1_filtered_trimmed_sorted.fastq"
read2Path_emb="$readDir_emb/ERR4570985_2_filtered_trimmed_sorted.fastq"
devStage_emb='embryos'
#outputDir="/big/mrk/oikopleura/trinity/trinity_denovo_${devStage_emb}_$DATE"

#if [ ! -d  $outputDir ]; then
#        mkdir $outputDir
#fi

export SINGULARITY_BIND="$readDir:/big/mrk/oikopleura/rna-seq-data/embryos"
#export SINGULARITY_BIND="$outputDir:/big/mrk/oikopleura/trinity/trinity_denovo_${devStage_emb}_$DATE"

# embryos
singularity exec -e $HOME/.local/src/trinityrnaseq.v2.15.1.simg  Trinity \
--seqType $seqType  \
--left $read1Path_emb --right $read2Path_emb --SS_lib_type $libType \
--CPU 10 --min_contig_length 100 --max_memory 50G \
--verbose
#--output $outputDir
