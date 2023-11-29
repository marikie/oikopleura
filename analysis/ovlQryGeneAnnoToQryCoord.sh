#!/bin/bash

# bedtool intersect qry coord & qry gene annotation

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1
gene_anno_bed_file="/Users/nakagawamariko/biohazard/data/lanc_oik_last/oik_anno_gene_20231129.bed"

cd $targetDir
for file in $(ls qry*); do 
  # echo "$file"
  if [ -f "$file" ]; then
    # echo "$name"
    bedtools intersect -wa -wb -a $file -b $gene_anno_bed_file > "qgene."$file
  fi
done
