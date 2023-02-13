#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1

dbNAME="OKI2018_I69_1.0db_${DATE}"
train_emb="train_OKI2018_I69_1.0_ERR4570985_$DATE.out"
train_imm="train_OKI2018_I69_1.0_ERR4570986_$DATE.out"
train_mat="train_OKI2018_I69_1.0_ERR4570987_$DATE.out"
al_emb="lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted_interleaved_postmask_$DATE.maf"
al_imm="lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted_interleaved_postmask_$DATE.maf"
al_mat="lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted_interleaved_postmask_$DATE.maf"

cd ~/big_oiks/last
echo "dbName: $dbNAME"

# lastdb
if [ ! -d $dbNAME ]; then
        echo "making lastdb"
        mkdir $dbNAME
        cd $dbNAME
        lastdb -P8 -uNEAR $dbNAME ../OKI2018_I69_1.0.fa
        cd ..
else
        echo "$dbNAME already exists"
fi

# last-train
if [ ! -e embryos/$train_emb ]; then
        echo "doing last-train on embryos"
        pwd
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_filtered_trimmed_sorted_interleaved.fastq > embryos/$train_emb
else
        echo "embryos/$train_emb already exists"
fi

if [ ! -e immatureAdults/$train_imm ]; then
        echo "doing last-train on immature adults"
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_filtered_trimmed_sorted_interleaved.fastq > immatureAdults/$train_imm
else
        echo "immatureAdults/$train_imm already exists"
fi

if [ ! -e maturedAdults/$train_mat ]; then
        echo "doing last-train on matured adults"
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_filtered_trimmed_sorted_interleaved.fastq > maturedAdults/$train_mat
else
        echo "maturedAdults/$train_mat already exists"
fi

# lastal
if [ ! -e embryos/$al_emb ]; then
        echo "doing spliced-alignment on embryos"
        lastal -D10 --split-d 2 --split-M 3.78 --split-S 0.065 -p --split-m 0.5 embryos/$train_emb $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_filtered_trimmed_sorted_interleaved.fastq | last-postmask > embryos/$al_emb
else
        echo "embryos/$al_emb already exists"
fi

if [ ! -e immatureAdults/$al_imm ]; then
        echo "doing spliced-alignment on immature adults"
        lastal -D10 --split-d 2 --split-M 3.78 --split-S 0.065 -p --split-m 0.5 immatureAdults/$train_imm $dbName/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_filtered_trimmed_sorted_interleaved.fastq | last-postmask > immatureAdults/$al_imm
else
        echo "immatureAdults/$al_imm already exists"
fi

if [ ! -e maturedAdults/$al_mat ]; then
        echo "doing spliced-alignment on matured adults"
        lastal -D10 --split-d 2 --split-M 3.78 --split-S 0.065 -p --split-m 0.5 maturedAdults/$train_mat $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_filtered_trimmed_sorted_interleaved.fastq | last-postmask > maturedAdults/$al_mat
else
        echo "maturedAdults/$al_mat already exists"
fi

