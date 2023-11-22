#!/bin/bash

# bedtool intersect ref coord & ref annotation

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

cd $targetDir
for file in $(ls ref*); do 
  # echo "$file"
  if [ -f "$file" ]; then
    # echo "$name"
    bedtools intersect -wa -wb -a $file -b ../../lanc_anno_CDS_20231121.bed > "ranno."$file
  fi
done
