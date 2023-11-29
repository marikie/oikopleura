#!/bin/bash

# reorder to show the coord of query at left

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

cd $targetDir
for file in $(ls rgene*); do 
  if [ -f "$file" ]; then
    awk -v OFS="\t" '{print $4, $5, $6, $7, $1, $2, $3, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22}' $file > $targetDir"/qry.$file"
  fi
done
