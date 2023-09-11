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
        lastdb -P8 -uMAM8 $dbName ~/oikopleura/elephantShark/ # Start modifying from here!
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
        #last-dotplot -a ~/oikdata/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff $maf $pngFile
        last-dotplot $maf $pngFile
else
        echo "$pngFile already exists"
fi
