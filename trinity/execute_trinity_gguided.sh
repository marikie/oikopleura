#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi
# --CPU, --max_memory, --min_contig_length, genome_guided_max_intron

DATE=$1
libType='FR'
alignmentBamFileDir="/big/mrk/oikopleura/last/embryos"
alignmentBamFile="$alignmentBamFileDir/lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted_postmask_pairprob_20230525.sort.bam"
devStage_emb='embryos'
outputDir="/big/mrk/oikopleura/trinity/trinity_gguided_${devStage_emb}_$DATE"

if [ ! -d  $outputDir ]; then
        echo "making output dir"
        mkdir $outputDir
else
        echo "$outputDir already exists."
fi

export SINGULARITY_BIND="$alignmentBamFileDir:$alignmentBamFileDir,$outputDir:$outputDir"
echo "$SINGULARITY_BIND"

singularity exec -e $HOME/.local/src/trinityrnaseq.v2.15.1.simg  Trinity \
        --genome_guided_bam $alignmentBamFile \
        --genome_guided_max_intron 100000 \
        --SS_lib_type $libType \
        --max_memory 50G --CPU 10 \
        --verbose \
        --output $outputDir
