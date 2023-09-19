#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1
dbName="F-Lanceletdb"
trainFile="EShark2Lanc.train"
maf="eachESharkPart_OnePartInLanc_alignment_$DATE.maf"
sam="eachESharkPart_OnePartInLanc_alignment_$DATE.sam"
pngFile="eachESharkPart_OnePartInLanc_alignment_$DATE.png"

cd ~/oikopleura/lanc_eshark_last

# lastdb
echo "---lastdb"
if [ ! -d /home/mrk/oikopleura/lanc_eshark_last/$dbName ]; then
        echo "making lastdb"
        mkdir $dbName
        cd $dbName
        lastdb -P8 -uMAM8 $dbName ~/oikopleura/lancelets/genome_assemblies_branchiostoma_floridae/ncbi-genomes-2023-06-13/GCF_000003815.2_Bfl_VNyyK_genomic.fna
        cd ..
else
        echo "$dbName already exists"
fi

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
        echo "doing last-train"
        last-train -P8 --revsym -E0.05 $dbName/$dbName ~/oikopleura/elephantShark/ncbi_dataset/data/GCF_018977255.1/GCF_018977255.1_IMCB_Cmil_1.0_genomic.fna > $trainFile
else
        echo "$trainFile already exists"
fi

# lastal 
echo "---lastal"
if [ ! -e $maf ]; then 
        echo "doing lastal"
        lastal -E0.05 --split-f=MAF+ -p $trainFile $dbName/$dbName ~/oikopleura/elephantShark/ncbi_dataset/data/GCF_018977255.1/GCF_018977255.1_IMCB_Cmil_1.0_genomic.fna | last-postmask > $maf
else
        echo "$maf already exists"
fi

# maf-convert sam
if [ ! -e $sam ]; then
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam $maf > $sam
else
        echo "$sam already exists"
fi

# last-dotplot
echo "---last-dotplot"
if [ ! -e $pngFile ]; then
        echo "making $pngFile"
        last-dotplot $maf $pngFile
else
        echo "$pngFile already exists"
fi
