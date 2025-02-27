#!/bin/bash

module load last/1608
lastal --version

argNum=11
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org1-org3. The top genome of each alignment .maf file will be org1. org1 should be in the outgroup." 1>&2
	echo "- today's date" 1>&2                                           # $1
	echo "- path to the org1 reference fasta file (outgroup)" 1>&2       # $2
	echo "- path to the org2 reference fasta file" 1>&2                  # $3
	echo "- path to the org3 reference fasta file" 1>&2                  # $4
	echo "- org1 full name" 1>&2                                         # $5
	echo "- org1 short name" 1>&2                                        # $6
	echo "- org2 full name" 1>&2                                         # $7
	echo "- org2 short name" 1>&2                                        # $8
	echo "- org3 full name" 1>&2                                         # $9
	echo "- org3 short name" 1>&2                                        # $10
	echo "- path to the dir where you want to place the output dir" 1>&2 # $11
	exit 1
fi

DATE=$1
org1FASTA=$2
org2FASTA=$3
org3FASTA=$4
org1FullName=$5
org1ShortName=$6
org2FullName=$7
org2ShortName=$8
org3FullName=$9
org3ShortName=$10
outDirPath=$11/$org1ShortName"_"$org2ShortName"_"$org3ShortName

gcContent_org2="$org2ShortName""_gcContent_$DATE.out"
gcContent_org3="$org3ShortName""_gcContent_$DATE.out"

o2o12="$org1ShortName""2""$org2ShortName""_one2one_$DATE.maf"
o2o13="$org1ShortName""2""$org3ShortName""_one2one_$DATE.maf"
joinedFile="$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE.maf"

o2o12_maflinked="$org1ShortName""2""$org2ShortName""_one2one_$DATE""_maflinked.maf"
o2o13_maflinked="$org1ShortName""2""$org3ShortName""_one2one_$DATE""_maflinked.maf"
joinedFile_maflinked="$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE""_maflinked.maf"

sbst3File_org2="sbst3_$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE""_$org2ShortName.tsv"
sbst3File_org3="sbst3_$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE""_$org3ShortName.tsv"
sbst3File_org2_maflinked="sbst3_$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE""_$org2ShortName""_maflinked.tsv"
sbst3File_org3_maflinked="sbst3_$org1ShortName""_""$org2ShortName""_""$org3ShortName""_$DATE""_$org3ShortName""_maflinked.tsv"
sbstFile="$org1ShortName""_""$org2ShortName""_""$org3ShortName""_sbst_$DATE.tsv"
sbstFile_org2="sbst_$org2ShortName""_$DATE.bed"
sbstFile_org3="sbst_$org3ShortName""_$DATE.bed"
org2cdsGFF="$org2FullName""_cds.gff"
org3cdsGFF="$org3FullName""_cds.gff"
cdsIntsct_sameStrand_org2="cdsIntsct_sameStrand_$org2ShortName""_$DATE.out"
cdsIntsct_sameStrand_org3="cdsIntsct_sameStrand_$org3ShortName""_$DATE.out"
cdsIntsct_diffStrand_org2="cdsIntsct_diffStrand_$org2ShortName""_$DATE.out"
cdsIntsct_diffStrand_org3="cdsIntsct_diffStrand_$org3ShortName""_$DATE.out"
sbst3Graph_org2="$org2ShortName""_$DATE.pdf"
sbst3Graph_org3="$org3ShortName""_$DATE.pdf"
sbst3Graph_org2_maflinked="$org2ShortName""_$DATE""_maflinked.pdf"
sbst3Graph_org3_maflinked="$org3ShortName""_$DATE""_maflinked.pdf"
sbst3GraphOut_org2="$org2ShortName""_$DATE.out"
sbst3GraphOut_org3="$org3ShortName""_$DATE.out"
sbst3GraphOut_org2_maflinked="$org2ShortName""_$DATE""_maflinked.out"
sbst3GraphOut_org3_maflinked="$org3ShortName""_$DATE""_maflinked.out"
sbstCount_org2="$org2ShortName""_sbstCount_$DATE.pdf"
sbstCount_org3="$org3ShortName""_sbstCount_$DATE.pdf"
oriCount_org2="$org2ShortName""_oriCount_$DATE.pdf"
oriCount_org3="$org3ShortName""_oriCount_$DATE.pdf"

if [ ! -d $outDirPath ]; then
	echo "---making $outDirPath"
	mkdir $outDirPath
fi
cd $outDirPath

# GC content
echo "---calculating GC content"
if [ ! -e $gcContent_org2 ]; then
	time python ~/scripts/analysis/gc_content.py $org2FASTA >$gcContent_org2
else
	echo "$gcContent_org2 already exists"
fi
if [ ! -e $gcContent_org3 ]; then
	time python ~/scripts/analysis/gc_content.py $org3FASTA >$gcContent_org3
else
	echo "$gcContent_org3 already exists"
fi

# one2one for org1-org2
echo "---running one2one for org1-org2"
echo "bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name"
bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org2FASTA $org1Name $org2Name

# one2one for org1-org3
echo "---running one2one for org1-org3"
echo "bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name"
bash ~/scripts/last/one2one.sh $DATE $outDirPath $org1FASTA $org3FASTA $org1Name $org3Name

# maf-join the two .maf files (without maf-linked)
bash ~/scripts/last/mafjoin.sh $o2o12 $o2o13 $joinedFile
# maf-join the two .maf files (with maf-linked)
bash ~/scripts/last/mafjoin.sh $o2o12_maflinked $o2o13_maflinked $joinedFile_maflinked

# make .tsv files about trinucleotide substitutions (without maf-linked)
echo "---making .tsv trinucleotide substitution files"
if [ ! -e $sbst3File_org2 ] && [ ! -e $sbst3File_org3 ]; then
	time python ~/scripts/analysis/triUvMuts_2TSVs.py $joinedFile "./"$sbst3File_org2 "./"$sbst3File_org3
else
	echo "$sbst3File_org2 and $sbst3File_org3 already exist"
fi

# make .tsv files about trinucleotide substitutions (with maf-linked)
echo "---making .tsv trinucleotide substitution files (with maf-linked)"
if [ ! -e $sbst3File_org2_maflinked ] && [ ! -e $sbst3File_org3_maflinked ]; then
	time python ~/scripts/analysis/triUvMuts_2TSVs.py $joinedFile_maflinked "./"$sbst3File_org2_maflinked "./"$sbst3File_org3_maflinked
else
	echo "$sbst3File_org2_maflinked and $sbst3File_org3_maflinked already exist"
fi


# make a graph of the trinucleotide substitutions (normalized) (without maf-linked)
echo "---making a graph of the trinucleotide substitutions (normalized) (without maf-linked)"
if [ ! -e $sbst3Graph_org2 ]; then
	time Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org2 $sbst3Graph_org2 0 >$sbst3GraphOut_org2
else
	echo "$sbst3Graph_org2 already exists"
fi
if [ ! -e $sbst3Graph_org3 ]; then
	time Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org3 $sbst3Graph_org3 0 >$sbst3GraphOut_org3
else
	echo "$sbst3Graph_org3 already exists"
fi

# make a graph of the number of trinucleotide substitutions (without maf-linked)
echo "---making a graph of the number of trinucleotide substitutions (without maf-linked)"
if [ ! -e $sbstCount_org2 ]; then
	time Rscript ~/scripts/analysis/R/sbmut_sbstCount.R $sbst3File_org2 $sbstCount_org2 0 
else
	echo "$sbstCount_org2 already exists"
fi
if [ ! -e $sbstCount_org3 ]; then
	time Rscript ~/scripts/analysis/R/sbmut_sbstCount.R $sbst3File_org3 $sbstCount_org3 0 
else
	echo "$sbstCount_org3 already exists"
fi

# make a graph of the number of original trinucleotides (without maf-linked)
echo "---making a graph of the number of original trinucleotides (without maf-linked)"
if [ ! -e $oriCount_org2 ]; then
	time Rscript ~/scripts/analysis/R/sbmut_oriCount.R $sbst3File_org2 $oriCount_org2 0 
else
	echo "$oriCount_org2 already exists"
fi
if [ ! -e $oriCount_org3 ]; then
	time Rscript ~/scripts/analysis/R/sbmut_oriCount.R $sbst3File_org3 $oriCount_org3 0
else
	echo "$oriCount_org3 already exists"
fi

# make a graph of the trinucleotide substitutions (normalized) (with maf-linked)
echo "---making a graph of the trinucleotide substitutions (normalized) (with maf-linked)"
if [ ! -e $sbst3Graph_org2_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org2_maflinked $sbst3Graph_org2_maflinked 0 >$sbst3GraphOut_org2_maflinked
else
	echo "$sbst3Graph_org2_maflinked already exists"
fi
if [ ! -e $sbst3Graph_org3_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut.R $sbst3File_org3_maflinked $sbst3Graph_org3_maflinked 0 >$sbst3GraphOut_org3_maflinked
else
	echo "$sbst3Graph_org3_maflinked already exists"
fi

# make a graph of the number of trinucleotide substitutions (with maf-linked)
echo "---making a graph of the number of trinucleotide substitutions (with maf-linked)"
if [ ! -e $sbstCount_org2_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut_sbstCount.R $sbst3File_org2_maflinked $sbstCount_org2_maflinked 0 
else
	echo "$sbstCount_org2_maflinked already exists"
fi
if [ ! -e $sbstCount_org3_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut_sbstCount.R $sbst3File_org3_maflinked $sbstCount_org3_maflinked 0 
else
	echo "$sbstCount_org3_maflinked already exists"
fi

# make a graph of the number of original trinucleotides (with maf-linked)
echo "---making a graph of the number of original trinucleotides (with maf-linked)"
if [ ! -e $oriCount_org2_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut_oriCount.R $sbst3File_org2_maflinked $oriCount_org2_maflinked 0 
else
	echo "$oriCount_org2_maflinked already exists"
fi
if [ ! -e $oriCount_org3_maflinked ]; then
	time Rscript ~/scripts/analysis/R/sbmut_oriCount.R $sbst3File_org3_maflinked $oriCount_org3_maflinked 0
else
	echo "$oriCount_org3_maflinked already exists"
fi


# # make another .tsv file of the trinucleotide mutations
# # which contains all the substitutions in org2 and org3 with org1's trinucleotide info
# echo "---making another .tsv file of all the trinucleotide substitutions in org2 and org3 with org1's trinucleotide info"
# if [ ! -e $sbstFile ]; then
# 	python ~/scripts/analysis/triSbstTSV.py $joinedFile "./"$sbstFile
# else
# 	echo "$sbstFile already exists"
# fi

# # split the $sbstFile into $sbstFile_org2 and $sbstFile_org3
# echo "---splitting the $sbstFile into $sbstFile_org2 and $sbstFile_org3"
# if [ ! -e $sbstFile_org2 ] && [ ! -e $sbstFile_org3 ]; then
# 	python ~/scripts/analysis/split2twoFiles.py $sbstFile "./"$sbstFile_org2 "./"$sbstFile_org3
# else
# 	echo "$sbstFile_org2 and $sbstFile_org3 already exist"
# fi

# # assert $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other
# echo "---asserting $sbst3File_org2 and $sbstFile_org2 doesn't contradict each other"
# # Extract and count sbstSig occurrences in sbstFile_org2
# awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org2" > sbst_counts2.txt
# # Compare with mutNum in sbst3File_org2
# awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org2" sbst_counts2.txt
# if [ $? -eq 0 ]; then
#     echo "Assertion passed: Files match"
# else
#     echo "Assertion failed: Files do not match"
#     exit 1
# fi

# # assert $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other
# echo "---asserting $sbst3File_org3 and $sbstFile_org3 doesn't contradict each other"
# awk '{count[$7]++} END {for (sig in count) print sig, count[sig]}' "$sbstFile_org3" > sbst_counts3.txt
# awk 'NR==FNR {mutNum[$1]=$2; next} {if (mutNum[$1] != $2) {print "Mismatch for", $1, ": expected", mutNum[$1], "found", $2; exit 1}}' "$sbst3File_org3" sbst_counts3.txt
# if [ $? -eq 0 ]; then
#     echo "Assertion passed: Files match"
# else
#     echo "Assertion failed: Files do not match"
#     exit 1
# fi

# # make gff files for the CDSs
# echo "---making gff files for the CDSs"
# awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org2gff > $org2cdsGFF
# awk 'BEGIN {OFS="\t"} $3 == "CDS"' $org3gff > $org3cdsGFF

# # bedtools intersect to get the trinucleotide substitutions in the CDSs
# # all
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (all)"
# if [ ! -e $cdsIntsct_all_org2 ]; then
# 	bedtools intersect -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_all_org2
# else
# 	echo "$cdsIntsct_all_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_all_org3 ]; then
# 	bedtools intersect -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_all_org3
# else
# 	echo "$cdsIntsct_all_org3 already exists"
# fi
# # same strand
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (same strand)"
# if [ ! -e $cdsIntsct_sameStrand_org2 ]; then
# 	bedtools intersect -s -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_sameStrand_org2
# else
# 	echo "$cdsIntsct_sameStrand_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_sameStrand_org3 ]; then
# 	bedtools intersect -s -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_sameStrand_org3
# else
# 	echo "$cdsIntsct_sameStrand_org3 already exists"
# fi
# # different strand
# echo "---bedtools intersect to get the trinucleotide substitutions in the CDSs (different strand)"
# if [ ! -e $cdsIntsct_diffStrand_org2 ]; then
# 	bedtools intersect -S -wb -a $org2cdsGFF -b $sbstFile_org2 >$cdsIntsct_diffStrand_org2
# else
# 	echo "$cdsIntsct_diffStrand_org2 already exists"
# fi
# if [ ! -e $cdsIntsct_diffStrand_org3 ]; then
# 	bedtools intersect -S -wb -a $org3cdsGFF -b $sbstFile_org3 >$cdsIntsct_diffStrand_org3
# else
# 	echo "$cdsIntsct_diffStrand_org3 already exists"
# fi