#!/bin/bash

# Separate files under a directory to different directories
# sameGeneRef: files with the same gene annotation on the reference
# diffGeneRef: files wit˙ the different gene annotations on the reference

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

cd $targetDir
mkdir sameRefGene
mkdir diffRefGene

for file in $(ls $targetDir); do 
  # echo "$file"
  if [ -f "$file" ]; then
    numOfGenes=$(cat $file | awk '{print $13}' | sort -u | wc -l)

    if [ "$numOfGenes" -gt 1 ]; then
      echo "$file has $numOfGenes different genes"
      mv "$file" $targetDir"/diffRefGene"
    else
      echo "$file has $numOfGenes gene"
      mv "$file" $targetDir"/sameRefGene"
    fi
  # else
    # echo "else"
  fi
done
