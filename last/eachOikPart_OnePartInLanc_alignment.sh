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

cd ~/big_oiks/lanc_oik_last

# lastdb
echo "---lastdb"
if [ ! -d /home/mrk/big_oiks/lanc_oik_last/$dbName ]; then
        echo "making lastdb"
        mkdir $dbName
        cd $dbName
        lastdb -P8 -uMAM8 $dbName ~/big_oiks/lancelets/genome_assemblies_branchiostoma_floridae/ncbi-genomes-2023-06-13/GCF_000003815.2_Bfl_VNyyK_genomic.fna 
        cd ..
else
        echo "$dbName already exists"
fi

# last-train
echo "--last-train"
if [ ! -e $trainFile ]; then
        echo "doing last-train"
        last-train -P8 --revsym -E0.05 $dbName/$dbName ~/big_oiks/last/OKI2018_I69_1.0.removed_chrUn.fa > $trainFile
else
        echo "$trainFile already exists"
fi

# lastal 1
echo "---lastal 1"
if [ ! -e $maf1 ]; then 
        echo "doing lastal phase 1"
        lastal -E0.05 --split-f=MAF+ -p $trainFile $dbName/$dbName ~/big_oiks/last/OKI2018_I69_1.0.removed_chrUn.fa > $maf1
else
        echo "$maf1 already exists"
fi

# lastal 2
echo "---lastal 2"
if [ ! -e $maf2 ]; then
        echo "doing lastal phase 2"
        last-split -r -m1e-5 $maf1 | last-postmask > $maf2
else
        echo "$maf2 already exists"
fi

# maf-convert sam
if [ ! -e $sam2 ]; then
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam $maf2 > $sam2
else
        echo "$sam2 already exists"
fi

# last-dotplot
echo "---last-dotplot"
if [ ! -e $pngFile ]; then
        echo "making $pngFile"
        last-dotplot $maf2 $pngFile
else
        echo "$pngFile already exists"
fi
