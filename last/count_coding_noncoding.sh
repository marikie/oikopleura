#!/bin/bash

# Get arguments
org1GFF=$1

org2tsv=$2
org2bed=$3
org3tsv=$4
org3bed=$5

org2tsv_maflinked=$6
org3tsv_maflinked=$7
org2bed_maflinked=$8
org3bed_maflinked=$9

# Function to count the number of substitutions in coding and non-coding region
count_coding_noncoding() {
	local org1GFF=$1
	local tsv=$2
	local bed=$3
	tsv_annot="${tsv%.tsv}_annot.tsv"
	org1GFF_CDS="${org1GFF%.gff}_CDS.gff"
	bed_annot="${bed%.bed}_annot.bed"
	awk -F"\t" '$3=="CDS"' $org1GFF > $org1GFF_CDS
	bedtools intersect -c -header -a $bed -b $org1GFF_CDS | awk -F"\t" 'NR==1{$0=$0"\tcount"}1' > $bed_annot
	awk -F"\t" 'NR==FNR{if($NF==0)zero[$(NF-1)]++; else nonzero[$(NF-1)]++; next}FNR==1{print $0"\tcoding\tnon-coding"; next}{key=$1; print$0"\t"(nonzero[key]?nonzero[key]:0)"\t"(zero[key]?zero[key]:0)}' $bed_annot $tsv > $tsv_annot

	# Check if mutNum = coding + non-coding
	awk -F"\t" 'NR!=1 {if($2 != $4 + $5) {print "Error: mutType " $1 " mutNum(" $2 ")!=coding(" $4 ")+non-coding(" $5 ")"; exit 1}}' $tsv_annot
	# Check the exit status of the awk command
	if [ $? -ne 0 ]; then
		echo "An error occurred in the awk command. Stopping the script."
		exit 1  # Exit the script with a non-zero status
	fi
}

# Regular files
echo "Counting the number of substitutions in coding and non-coding regions for regular files"
count_coding_noncoding "$org1GFF" "$org2tsv" "$org2bed"
count_coding_noncoding "$org1GFF" "$org3tsv" "$org3bed"

# Maf-linked files
echo "Counting the number of substitutions in coding and non-coding regions for maf-linked files"
count_coding_noncoding "$org1GFF" "$org2tsv_maflinked" "$org2bed_maflinked"
count_coding_noncoding "$org1GFF" "$org3tsv_maflinked" "$org3bed_maflinked"
