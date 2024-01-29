#!/bin/bash
argNum=3

if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments." 1>&2
	echo "- path to the target directory" 1>&2          # $1
	echo "- path to the reference annotation file" 1>&2 # $2
	echo "- path to the query annotation file" 1>&2     # $3
	exit 1
fi

targetDir=$1
refAnnoFile=$2
qryAnnoFile=$3

cd $targetDir

for file in $(ls $targetDir); do
	# echo "$file"
	if [ -f "$file" ]; then
		basename="$(basename "$file" ".psl")"
		outFile=$basename".out"
		zoPngFile=$basename"_zo.png"

		refRange=$(awk -F'\t' '{print $15, $16, $17}' ../OUT/$outFile | sort -u | awk '{printf "-1 %s:%s-%s ", $1, $2, $3} END{print ""}')

		qryRange=$(awk -F'\t' '{print $10, $11, $12}' ../OUT/$outFile | sort -u | awk '{printf "-2 %s:%s-%s ", $1, $2, $3} END{print ""}')

		python ~/biohazard/oikopleura/last/last-dotplot_mariko_1513.py --max-gap2=100 --max-gap1=100 --sort1=3 --strands1=1 --border-color=silver --border-pixels=5 --rot1=v --rot2=h --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile $refRange $qryRange $file ../PNG/$zoPngFile
	fi
done
