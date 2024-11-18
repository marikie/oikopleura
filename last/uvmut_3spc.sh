#!/bin/bash

module load last/1542
lastal --version

argNum=8
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org1-org3. The top genome of each alignment .maf file will be org1. org1 should be in the outgroup." 1>&2
	echo "- today's date" 1>&2                                           # $1
	echo "- path to the org1 reference fasta file (outgroup)" 1>&2                  # $2
	echo "- path to the org2 reference fasta file" 1>&2                  # $3
	echo "- path to the org3 reference fasta file" 1>&2                  # $4
	echo "- org1 name" 1>&2                                              # $5
	echo "- org2 name" 1>&2                                              # $6
	echo "- org3 name" 1>&2                                              # $7
	echo "- path to the dir where you want to place the output dir" 1>&2 # $8
	exit 1
fi

DATE=$1
org1FASTA=$2
org2FASTA=$3
org3FASTA=$4
org1Name=$5
org2Name=$6
org3Name=$7
outDirPath="$8/$org1Name""_""$org2Name""_""$org3Name"
o2omaf12="$org1Name""2""$org2Name""_one2one_$DATE.maf"
o2omaf13="$org1Name""2""$org3Name""_one2one_$DATE.maf"
o2omaf12_sorted="$org1Name""2""$org2Name""_one2one_$DATE""_sorted.maf"
o2omaf13_sorted="$org1Name""2""$org3Name""_one2one_$DATE""_sorted.maf"
joinedFile="$org1Name""_""$org2Name""_""$org3Name""_$DATE.maf"
sbst3File_org2="sbst3_$org1Name""_""$org2Name""_""$org3Name""_$DATE""_$org2Name.tsv"
sbst3File_org3="sbst3_$org1Name""_""$org2Name""_""$org3Name""_$DATE""_$org3Name.tsv"
sbstFile="$org1Name""_""$org2Name""_""$org3Name""_sbst_$DATE.tsv"
sbstFile_org2="sbst_$org2Name""_$DATE.bed"
sbstFile_org3="sbst_$org3Name""_$DATE.bed"
org2cdsGFF="$org2Name""_cds.gff"
org3cdsGFF="$org3Name""_cds.gff"
cdsIntsct_sameStrand_org2="cdsIntsct_sameStrand_$org2Name""_$DATE.out"
cdsIntsct_sameStrand_org3="cdsIntsct_sameStrand_$org3Name""_$DATE.out"
cdsIntsct_diffStrand_org2="cdsIntsct_diffStrand_$org2Name""_$DATE.out"
cdsIntsct_diffStrand_org3="cdsIntsct_diffStrand_$org3Name""_$DATE.out"
sbst3Graph_org2="$org2Name""_$DATE.pdf"
sbst3Graph_org3="$org3Name""_$DATE.pdf"
sbst3GraphOut_org2="$org2Name""_$DATE.out"
sbst3GraphOut_org3="$org3Name""_$DATE.out"

echo "Date: $DATE"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org3FASTA: $org3FASTA"
echo "org1Name: $org1Name"
echo "org2Name: $org2Name"
echo "org3Name: $org3Name"
echo "outDirPath: $outDirPath"
echo "o2omaf12: $o2omaf12"
echo "o2omaf13: $o2omaf13"
echo "o2omaf12_sorted: $o2omaf12_sorted"
echo "o2omaf13_sorted: $o2omaf13_sorted"
echo "joinedFile: $joinedFile"
echo "sbst3File_org2: $sbst3File_org2"
echo "sbst3File_org3: $sbst3File_org3"
echo "sbstFile: $sbstFile"
echo "sbstFile_org2: $sbstFile_org2"
echo "sbstFile_org3: $sbstFile_org3"
echo "cdsIntsct_org2: $cdsIntsct_org2"
echo "cdsIntsct_org3: $cdsIntsct_org3"
echo "sbst3Graph_org2: $sbst3Graph_org2"
echo "sbst3Graph_org3: $sbst3Graph_org3"
echo "sbst3GraphOut_org2: $sbst3GraphOut_org2"
echo "sbst3GraphOut_org3: $sbst3GraphOut_org3"

if [ ! -d $outDirPath ]; then
	echo "---making $outDirPath"
	mkdir $outDirPath
fi
cd $outDirPath

echo "---running one2one for org1-org2"
echo "bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name"
bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name
echo "---running one2one for org1-org3"
echo "bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name"
bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name

# maf-join the two .maf files
echo "---maf-joining the two .maf files"
if [ ! -e $o2omaf12_sorted ]; then
	maf-sort $o2omaf12 >$o2omaf12_sorted
else
	echo "$o2omaf12_sorted already exists"
fi
if [ ! -e $o2omaf13_sorted ]; then
	maf-sort $o2omaf13 >$o2omaf13_sorted
else
	echo "$o2omaf13_sorted already exists"
fi
if [ ! -e $joinedFile ]; then
	maf-join $o2omaf12_sorted $o2omaf13_sorted >$joinedFile
else
	echo "$joinedFile already exists"
fi

# make .tsv files about trinucleotide mutations
echo "---making .tsv trinucleotide mutation files"
if [ ! -e $sbst3File_org2 ] && [ ! -e $sbst3File_org3 ]; then
	python ~/scripts/analysis/triUvMuts_2TSVs.py $joinedFile "./"$sbst3File_org2 "./"$sbst3File_org3
else
	echo "$sbst3File_org2 and $sbst3File_org3 already exist"
fi

# make another .tsv file of the trinucleotide mutations
# which contains all the substitutions in org2 and org3 with org1's trinucleotide info
echo "---making another .tsv file of all the trinucleotide substitutions in org2 and org3 with org1's trinucleotide info"
if [ ! -e $sbstFile ]; then
	python ~/scripts/analysis/triSbstTSV.py $joinedFile "./"$sbstFile
else
	echo "$sbstFile already exists"
fi

# split the $sbstFile into $sbstFile_org2 and $sbstFile_org3
echo "---splitting the $sbstFile into $sbstFile_org2 and $sbstFile_org3"
if [ ! -e $sbstFile_org2 ] && [ ! -e $sbstFile_org3 ]; then
	python ~/scripts/analysis/split2twoFiles.py $sbstFile "./"$sbstFile_org2 "./"$sbstFile_org3
else
	echo "$sbstFile_org2 and $sbstFile_org3 already exist"
fi

# assert $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other
echo "---asserting $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other"
# Extract and count sbstSig occurrences in sbstFile_org2
awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org2" > sbst_counts2.txt
# Compare with mutNum in sbst3File_org2
awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org2" sbst_counts2.txt
if [ $? -eq 0 ]; then
    echo "Assertion passed: Files match"
else
    echo "Assertion failed: Files do not match"
    exit 1
fi

# assert $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other
echo "---asserting $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other"
awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org3" > sbst_counts3.txt
awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org3" sbst_counts3.txt
if [ $? -eq 0 ]; then
    echo "Assertion passed: Files match"
else
    echo "Assertion failed: Files do not match"
    exit 1
fi

# make gff files for the CDSs
echo "---making gff files for the CDSs"
awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org2gff > $org2cdsGFF
awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org3gff > $org3cdsGFF

# bedtools intersect to get the trinucleotide substitutions in the CDSs
# all
echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (all)"
if [ ! -e $cdsIntsct_all_org2 ]; then
	bedtools intersect -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_all_org2
else
	echo "$cdsIntsct_all_org2 already exists"
fi
if [ ! -e $cdsIntsct_all_org3 ]; then
	bedtools intersect -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_all_org3
else
	echo "$cdsIntsct_all_org3 already exists"
fi
# same strand
echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (same strand)"
if [ ! -e $cdsIntsct_sameStrand_org2 ]; then
	bedtools intersect -s -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_sameStrand_org2
else
	echo "$cdsIntsct_sameStrand_org2 already exists"
fi
if [ ! -e $cdsIntsct_sameStrand_org3 ]; then
	bedtools intersect -s -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_sameStrand_org3
else
	echo "$cdsIntsct_sameStrand_org3 already exists"
fi
# different strand
echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (different strand)"
if [ ! -e $cdsIntsct_diffStrand_org2 ]; then
	bedtools intersect -S -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_diffStrand_org2
else
	echo "$cdsIntsct_diffStrand_org2 already exists"
fi
if [ ! -e $cdsIntsct_diffStrand_org3 ]; then
	bedtools intersect -S -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_diffStrand_org3
else
	echo "$cdsIntsct_diffStrand_org3 already exists"
fi

# make a graph of the trinucleotide mutations
echo "---making a graph of the trinucleotide mutations"
if [ ! -e $sbst3Graph_org2 ]; then
	Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org2 $sbst3Graph_org2 0 >$sbst3GraphOut_org2
else
	echo "$sbst3Graph_org2 already exists"
fi
if [ ! -e $sbst3Graph_org3 ]; then
	Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org3 $sbst3Graph_org3 0 >$sbst3GraphOut_org3
else
	echo "$sbst3Graph_org3 already exists"
fi

# GC content
echo "---calculating GC content"