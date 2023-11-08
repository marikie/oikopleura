#!/bin/bash

# Separate files under a directory into two different directories
# single: files with only one line
# multiple: files with equal to or more than two lines

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1

for file in $(ls $targetDir); do 
  # echo "$file"
  if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    # echo "$lines"
    if [ "$lines" -gt 1 ]; then
      echo "$file has $lines lines (more than 1 lines)"
      mv "$file" $targetDir"/multiple"
    else
      echo "$file has $lines lines (1 or fewer lines)"
      mv "$file" $targetDir"/single"
    fi
  # else
    # echo "else"
  fi
done
