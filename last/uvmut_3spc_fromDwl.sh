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

cd ~/genomes
mkdir $org1FullName
mkdir $org2FullName
mkdir $org3FullName

# make short names
org1ShortName="${org1FullName:0:3}$(echo $org1FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org2ShortName="${org2FullName:0:3}$(echo $org2FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"
org3ShortName="${org3FullName:0:3}$(echo $org3FullName | sed -n 's/.*\([A-Z][a-z]\{2\}\).*/\1/p' | head -n 1)"

# download from NCBIdataset
cd ~/genomes/$org1FullName
# Mytilus trossulus (common blue mussel)
datasets download genome accession $org1ID --include gff3,rna,cds,protein,genome,seq-report &   
cd ~/genomes/$org2FullName
# Mytilus edulis (edible mussel)
datasets download genome accession $org2ID --include gff3,rna,cds,protein,genome,seq-report &
cd ~/genomes/$org3FullName
# Mytilus galloprovincialis (Mediterranean mussel)
datasets download genome accession $org3ID --include gff3,rna,cds,protein,genome,seq-report &
wait

# move files and delete unnecessary directories
cd ~/genomes/$org1FullName
unzip ncbi_dataset.zip
cd ncbi_dataset/data
mv $(ls -p | grep -v /) ~/genomes/$org1FullName 
cd $org1ID
mv * ~/genomes/$org1FullName
cd ~/genomes/$org1FullName
rm -r ncbi_dataset


bash ~/scripts/last/one2one.sh $DATE $org1ShortName $org2ShortName $org1FASTA $org2FASTA $org1Name $org2Name &
bash ~/scripts/last/one2one.sh $DATE $org1ShortName $org3ShortName $org1FASTA $org3FASTA $org1Name $org3Name &
wait
