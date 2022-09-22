#!/bin/bash

if [ $# -ne 2 ]; then
        echo "You need 2 arguments." 1>&2
        echo "- .maf file" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

MAF_FILE=$1
DATE=$2
SAM_FILE="${MAF_FILE:0:-4}_$DATE.sam"
BAM_FILE="${MAF_FILE:0:-4}_$DATE.bam"
SORT_BAM_FILE="${MAF_FILE:0:-4}_$DATE.sort.bam"

echo "MAF -> SAM"
maf-convert sam $MAF_FILE > $SAM_FILE
echo "SAM -> BAM"
samtools view -bt /home/mrk/data/last/OKI2018_I69_1.0.removed_chrUn.fa.fai $SAM_FILE > $BAM_FILE
echo "BAM -> SORT.BAM"
samtools sort $BAM_FILE -o $SORT_BAM_FILE
echo "INDEX"
samtools index $SORT_BAM_FILE
