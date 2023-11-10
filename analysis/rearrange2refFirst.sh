#!/bin/bash

# rearrange to show the coord of ref at left

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

for file in $(ls $targetDir); do 
  if [ -f "$file" ]; then
    awk -v OFS="\t" '{print $5, $6, $7, $1, $2, $3, $4, $8, $9, $10, $11, $13}' $file > $targetDir"/ref.$file"
  fi
done
