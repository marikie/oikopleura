#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1
dbName="F-Lanceletdb"
trainFile="Oik2Lanc.train"
maf="eachOikPart_OnePartInLanc_alignment_$DATE.maf"
sam="eachOikPart_OnePartInLanc_alignment_$DATE.sam"
pngFile="eachOikPart_OnePartInLanc_alignment_$DATE.png"

cd ~/oikdata/lanc_oik_last

# lastdb
echo "---lastdb"
if [ ! -d /home/mrk/oikdata/lanc_oik_last/$dbName ]; then
        echo "making lastdb"
        mkdir $dbName
        cd $dbName
        lastdb -P8 -uMAM8 $dbName ~/oikdata/lancelets/genome_assemblies_branchiostoma_floridae/ncbi-genomes-2023-06-13/GCF_000003815.2_Bfl_VNyyK_genomic.fna 
        cd ..
else
        echo "$dbName already exists"
fi

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
        echo "doing last-train"
        last-train -P8 --revsym -E0.05 $dbName/$dbName ~/oikdata/last/OKI2018_I69_1.0.removed_chrUn.fa > $trainFile
else
        echo "$trainFile already exists"
fi

# lastal 
echo "---lastal"
if [ ! -e $maf ]; then 
        echo "doing lastal phase 1"
        lastal -E0.05 --split-f=MAF+ -p $trainFile $dbName/$dbName ~/oikdata/last/OKI2018_I69_1.0.removed_chrUn.fa | last-postmask > $maf
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
        last-dotplot -a ~/oikdata/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff $maf $pngFile
else
        echo "$pngFile already exists"
fi
