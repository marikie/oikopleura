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
al_emb1="lastsplitOKI2018_I69_1.0_ERR4570985_1_filtered_trimmed_sorted_postmask_$DATE.maf"
al_emb2="lastsplitOKI2018_I69_1.0_ERR4570985_2_filtered_trimmed_sorted_postmask_$DATE.maf"
al_emb_combined="lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted_postmask_combined_$DATE.maf"
al_imm1="lastsplitOKI2018_I69_1.0_ERR4570986_1_filtered_trimmed_sorted_postmask_$DATE.maf"
al_imm2="lastsplitOKI2018_I69_1.0_ERR4570986_2_filtered_trimmed_sorted_postmask_$DATE.maf"
al_imm_combined="lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted_postmask_combined_$DATE.maf"
al_mat1="lastsplitOKI2018_I69_1.0_ERR4570987_1_filtered_trimmed_sorted_postmask_$DATE.maf"
al_mat2="lastsplitOKI2018_I69_1.0_ERR4570987_2_filtered_trimmed_sorted__postmask_$DATE.maf"
al_mat_combined="lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted_postmask_combined_$DATE.maf"
sam_emb="lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted_postmask_combined_$DATE.sam"
sam_imm="lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted_postmask_combined_$DATE.sam"
sam_mat="lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted_postmask_combined_$DATE.sam"

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
# embryos
if [ ! -e embryos/$al_emb1 ]; then
        echo "doing spliced-alignment on embryos (Read1)"
        lastal -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p embryos/$train_emb $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_1_filtered_trimmed_sorted.fastq | last-postmask > embryos/$al_emb1
else
        echo "embryos/$al_emb1 already exists"
fi
if [ ! -e embryos/$al_emb2 ]; then
        echo "doing spliced-alignment on embryos (Read2)"
        lastal -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p embryos/$train_emb $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_2_filtered_trimmed_sorted.fastq | last-postmask > embryos/$al_emb2
else
        echo "embryos/$al_emb2 already exists"
fi
if [ ! -e embryos/$sam_emb ]; then
        echo "combining two maf files"
        cat $al_emb1 $al_emb2 > $al_emb_combined
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam $al_emb_combined > $sam_emb 
else
        echo "embryos/$sam_emb already exists"
fi

# immature adults
if [ ! -e immatureAdults/$al_imm1 ]; then
        echo "doing spliced-alignment on immature adults (Read1)"
        lastal -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p immatureAdults/$train_imm $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_1_filtered_trimmed_sorted.fastq | last-postmask > immatureAdults/$al_imm1
else
        echo "immatureAdults/$al_imm1 already exists"
fi
if [ ! -e immatureAdults/$al_imm2 ]; then
        echo "doing spliced-alignment on immature adults (Read2)"
        lastal -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p immatureAdults/$train_imm $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_2_filtered_trimmed_sorted.fastq | last-postmask > immatureAdults/$al_imm2
else
        echo "immatureAdults/$al_imm2 already exists"
fi
if [ ! -e immatureAdults/$sam_imm ]; then
        echo "combining two maf files"
        cat $al_imm1 $al_imm2 > $al_imm_combined
        echo "convert maf to sam"
        maf-convert -j1e5 -d sam $al_imm_combined > $sam_imm 
else
        echo "immatureAdults/$sam_imm already exists"
fi

# mature adults
if [ ! -e maturedAdults/$al_mat1 ]; then
        echo "doing spliced-alignment on matured adults (Read1)"
        lastal -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p maturedAdults/$train_mat $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_1_filtered_trimmed_sorted.fastq | last-postmask > maturedAdults/$al_mat1
else
        echo "maturedAdults/$al_mat1 already exists"
fi
if [ ! -e maturedAdults/$al_mat2 ]; then
        echo "doing spliced-alignment on matured adults (Read2)"
        lastal -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p maturedAdults/$train_mat $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_2_filtered_trimmed_sorted.fastq | last-postmask > maturedAdults/$al_mat2
else
        echo "maturedAdults/$al_mat2 already exists"
fi
if [ ! -e matureAdults/$sam_mat ]; then
        echo "combining two maf files"
        cat $al_mat1 $al_mat2 > $al_mat_combined
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam $al_mat_combined > $sam_mat 
else
        echo "matureAdults/$sam_mat already exists"
fi
