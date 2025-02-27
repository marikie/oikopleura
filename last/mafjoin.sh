#!/bin/bash

argNum=2
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get a joined .maf file from two .maf files" 1>&2
	echo "- path to the org1-org2 .maf file" 1>&2 # $1
	echo "- path to the org1-org3 .maf file" 1>&2 # $2
	echo "- path to the output joined .maf file" 1>&2 # $3
	exit 1
fi

org1_org2=$1
org1_org3=$2
org1_org2_sorted="$org1_org2""_sorted.maf"
org1_org3_sorted="$org1_org3""_sorted.maf"
joinedFile=$3

echo "---maf-joining the two .maf files"
if [ ! -e $org1_org2_sorted ]; then
	time maf-sort $org1_org2 >$org1_org2_sorted
else
	echo "$org1_org2_sorted already exists"
fi
if [ ! -e $org1_org3_sorted ]; then
	time maf-sort $org1_org3 >$org1_org3_sorted
else
	echo "$org1_org3_sorted already exists"
fi
if [ ! -e $joinedFile ]; then
	time maf-join $org1_org2_sorted $org1_org3_sorted >$joinedFile
else
	echo "$joinedFile already exists"
fi