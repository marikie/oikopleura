#!/bin/bash

argNum=7
if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments" 1>&2
	echo "You'll get one-to-one alignments of org1-org2 and org1-org3.\nThe top genome of each alignment .maf file will be org1. org1 should be in the outgroup." 1>&2
	echo "- today's date" 1>&2                                           # $1
    echo "- org1 accession ID" 1>&2                                      # $2
    echo "- org2 accession ID" 1>&2                                      # $3
    echo "- org3 accession ID" 1>&2                                      # $4
	echo "- org1 full name" 1>&2                                         # $5
	echo "- org2 full name" 1>&2                                         # $6
	echo "- org3 full name" 1>&2                                         # $7
	exit 1
fi

DATE=$1
org1ID=$2
org2ID=$3
org3ID=$4
org1FullName=$5
org2FullName=$6
org3FullName=$7

echo "Date: $DATE"
echo "org1ID: $org1ID"
echo "org2ID: $org2ID"
echo "org3ID: $org3ID"
echo "org1FullName: $org1FullName"
echo "org2FullName: $org2FullName"
echo "org3FullName: $org3FullName"

cd ~/genomes
mkdir $org1FullName
mkdir $org2FullName
mkdir $org3FullName

# make short names
org1ShortName="${org1FullName:0:3}$(echo $org1FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org2ShortName="${org2FullName:0:3}$(echo $org2FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org3ShortName="${org3FullName:0:3}$(echo $org3FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"

echo "org1ShortName: $org1ShortName"
echo "org2ShortName: $org2ShortName"
echo "org3ShortName: $org3ShortName"


# download from NCBIdatase
if [ ! -e ~/genomes/$org1FullName/ncbi_dataset.zip ]; then
    echo "Downloading $org1FullName from NCBIdataset"
    cd ~/genomes/$org1FullName
    datasets download genome accession $org1ID --include gff3,rna,cds,protein,genome,seq-report &   
else
    echo "$org1FullName already downloaded"
fi
if [ ! -e ~/genomes/$org2FullName/ncbi_dataset.zip ]; then
    echo "Downloading $org2FullName from NCBIdataset"
    cd ~/genomes/$org2FullName
    datasets download genome accession $org2ID --include gff3,rna,cds,protein,genome,seq-report &
else
    echo "$org2FullName already downloaded"
fi
if [ ! -e ~/genomes/$org3FullName/ncbi_dataset.zip ]; then
    echo "Downloading $org3FullName from NCBIdataset"
    cd ~/genomes/$org3FullName
    datasets download genome accession $org3ID --include gff3,rna,cds,protein,genome,seq-report &
else
    echo "$org3FullName already downloaded"
fi
wait

# move files and delete unnecessary directories
echo "move files and delete unnecessary directories"
function processGenomeData() {
    local orgFullName=$1
    local orgID=$2

    cd ~/genomes/"$orgFullName"
    if [ ! -e *.fna ]; then
        unzip ncbi_dataset.zip
        cd ncbi_dataset/data
        mv $(ls -p | grep -v /) ~/genomes/"$orgFullName"
        cd "$orgID"
        mv * ~/genomes/"$orgFullName"
        cd ~/genomes/"$orgFullName"
        rm -r ncbi_dataset
    fi
}
processGenomeData $org1FullName $org1ID &
processGenomeData $org2FullName $org2ID &
processGenomeData $org3FullName $org3ID &
wait

org1FASTA="~/genomes/$org1FullName/$(ls ~/genomes/$org1FullName | grep $org1ID)"
org2FASTA="~/genomes/$org2FullName/$(ls ~/genomes/$org2FullName | grep $org2ID)"
org3FASTA="~/genomes/$org3FullName/$(ls ~/genomes/$org3FullName | grep $org3ID)"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org3FASTA: $org3FASTA"

echo "Running uvmut_3spc.sh"
bash ~/scripts/last/uvmut_3spc.sh $DATE $org1FASTA $org2FASTA $org3FASTA $org1ShortName $org2ShortName $org3ShortName ~/data