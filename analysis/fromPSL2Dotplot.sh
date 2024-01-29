#!/bin/bash
argNum=4

if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments." 1>&2
	echo "- path to the target directory" 1>&2          # $1
	echo "- path to the reference annotation file" 1>&2 # $2
	echo "- path to the query annotation file" 1>&2     # $3
	echo "- path to my dotplot python code" 1>&2        # $4
	exit 1
fi

targetDir=$1
refAnnoFile=$2
qryAnnoFile=$3
myDotplot=$4

cd $targetDir

for file in $(ls $targetDir); do
	# echo "$file"
	if [ -f "$file" ]; then
		basename="$(basename "$file" ".psl")"
		ziPngFile=$basename"_zi.png"
		ziIDPngFile=$basename"_ziID.png"
		# zoPngFile="$(basename)_zo.png"

		# echo "$pslFile"
		python $myDotplot --sort1=3 --strands1=1 --border-color=silver --rot1=v --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile $file ../PNG/$ziPngFile

		last-dotplot --sort1=3 --strands1=1 --border-color=silver --rot1=v --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile $file ../PNG/$ziIDPngFile
	fi
done
