#!/bin/bash
argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

cd $targetDir

for file in $(ls ranno*\.out); do 
  # echo "$file"
  if [ -f "$file" ]; then
    basename="$(basename "$file" ".out")"
    pslFile="$basename.psl"
    
    # echo "$pslFile"
    awk 'NR == FNR {a[$4, $5, $6, $1, $2, $3]; next} ("chr_"$10, $12, $13, "chr_"$14, $16, $17) in a' $file ../../../eachOikPart_OnePartInLanc_alignment_20230706_sortedByQuery.psl > $pslFile
  fi
done
