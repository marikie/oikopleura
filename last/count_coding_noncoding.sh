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
	org1GFF_CDS="${org1GFF%.gff}_CDS.gff"
	bed_annot="${bed%.bed}_annot.bed"
	tsv_tmp="${tsv%.tsv}_tmp.tsv"
	tsv_annot="${tsv%.tsv}_annot.tsv"
	awk -F"\t" '$3=="CDS"' $org1GFF > $org1GFF_CDS
	bedtools intersect -c -header -a $bed -b $org1GFF_CDS | awk -F"\t" 'NR==1{$0=$0"\tcount"}1' > $bed_annot
	# add the count of substitutions in the coding region and non-coding region to the tsv file
	awk -F"\t" 'NR==FNR{if($(NF-1)=="."){next} if($NF==0)nonCoding[$(NF-1)]++; else coding[$(NF-1)]++; next}FNR==1{print $0"\ts_cds\ts_ncds"; next}{key=$1; print$0"\t"(coding[key]?coding[key]:0)"\t"(nonCoding[key]?nonCoding[key]:0)}' $bed_annot $tsv > $tsv_tmp
	# add the count of original trinucs in the coding region and non-coding region to the tsv file
	awk -F"\t" 'NR==FNR{if($NF==0)nonCoding[$(NF-2)]++; else coding[$(NF-2)]++; next}FNR==1{print $0"\to_cds\to_ncds"; next}{key=$2; print$0"\t"(coding[key]?coding[key]:0)"\t"(nonCoding[key]?nonCoding[key]:0)}' $bed_annot $tsv_tmp > $tsv_annot

	# Check if mutNum = s_coding + s_non-coding
	awk -F"\t" 'NR!=1 {if($3 != $5 + $6) {print "Error: mutType " $1 " mutNum(" $3 ")!=coding(" $5 ")+non-coding(" $6 ")"; exit 1}}' $tsv_annot
	# Check the exit status of the awk command
	if [ $? -ne 0 ]; then
		echo "An error occurred in the awk command. Stopping the script."
		exit 1  # Exit the script with a non-zero status
	fi
	# Check if totalRootNum = o_coding + o_non-coding
	awk -F"\t" 'NR!=1 {if($4 != $7 + $8) {print "Error: mutType " $1 " totalRootNum(" $4 ")!=coding(" $7 ")+non-coding(" $8 ")"; exit 1}}' $tsv_annot
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
