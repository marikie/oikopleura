#!/bin/bash

if [ $# -ne 1 ]; then
        echo "You need 1 argument" 1>&2
        echo "- today's date" 1>&2
        exit 1
fi

DATE=$1

dbNAME="OKI2018_I69_1.0db"
train_emb="train_OKI2018_I69_1.0_ERR4570985.out"
train_imm="train_OKI2018_I69_1.0_ERR4570986.out"
train_mat="train_OKI2018_I69_1.0_ERR4570987.out"
al_emb1="lastsplitOKI2018_I69_1.0_ERR4570985_1_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_emb2="lastsplitOKI2018_I69_1.0_ERR4570985_2_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_emb_pairprob="lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted_numbered_postmask_pairprob_$DATE.maf"
al_imm1="lastsplitOKI2018_I69_1.0_ERR4570986_1_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_imm2="lastsplitOKI2018_I69_1.0_ERR4570986_2_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_imm_pairprob="lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted_numbered_postmask_pairprob_$DATE.maf"
al_mat1="lastsplitOKI2018_I69_1.0_ERR4570987_1_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_mat2="lastsplitOKI2018_I69_1.0_ERR4570987_2_filtered_trimmed_sorted_numbered_postmask_$DATE.maf"
al_mat_pairprob="lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted_numbered_postmask_pairprob_$DATE.maf"
sam_emb="${al_emb_pairprob:0:-4}.sam"
sam_imm="${al_imm_pairprob:0:-4}.sam"
sam_mat="${al_mat_pairprob:0:-4}.sam"
fai_FILE="~/big_oiks/last/OKI2018_I69_1.0.removed_chrUn.fa.fai"
SORT_BAM_emb="${sam_emb:0:-4}.sort.bam"
SORT_BAM_imm="${sam_imm:0:-4}.sort.bam"
SORT_BAM_mat="${sam_mat:0:-4}.sort.bam"

cd ~/oikopleura/last
echo "dbName: $dbNAME"

############################
# lastdb
############################
echo "---lastdb"
if [ ! -d $dbNAME ]; then
        echo "making lastdb"
        mkdir $dbNAME
        cd $dbNAME
        lastdb -P8 -uNEAR $dbNAME ../OKI2018_I69_1.0.fa
        cd ..
else
        echo "$dbNAME already exists"
fi

###########################
# last-train
###########################
echo "---last-train"
# embryos
if [ ! -e embryos/$train_emb ]; then
        echo "doing last-train on embryos"
        pwd
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_filtered_trimmed_sorted_interleaved.fastq > embryos/$train_emb
else
        echo "embryos/$train_emb already exists"
fi

# immature adults
if [ ! -e immatureAdults/$train_imm ]; then
        echo "doing last-train on immature adults"
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_filtered_trimmed_sorted_interleaved.fastq > immatureAdults/$train_imm
else
        echo "immatureAdults/$train_imm already exists"
fi

# matured adults
if [ ! -e maturedAdults/$train_mat ]; then
        echo "doing last-train on matured adults"
        last-train -P8 -Q0 $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_filtered_trimmed_sorted_interleaved.fastq > maturedAdults/$train_mat
else
        echo "maturedAdults/$train_mat already exists"
fi

##########################
# lastal
##########################
echo "---lastal"
# embryos
# - spliced alignment of Read1
if [ ! -e embryos/$al_emb1 ]; then
        echo "doing spliced-alignment on embryos (Read1)"
        lastal -i1 -P8 -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p embryos/$train_emb $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_1_filtered_trimmed_sorted_numbered.fastq | last-postmask > embryos/$al_emb1
else
        echo "embryos/$al_emb1 already exists"
fi
# - spliced alignment of Read2
if [ ! -e embryos/$al_emb2 ]; then
        echo "doing spliced-alignment on embryos (Read2)"
        lastal -i1 -P8 -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p embryos/$train_emb $dbNAME/$dbNAME ../rna-seq-data/embryos/ERR4570985_2_filtered_trimmed_sorted_numbered.fastq | last-postmask > embryos/$al_emb2
else
        echo "embryos/$al_emb2 already exists"
fi
# - last-pair-probs Read1, Read2
if [ ! -e embryos/$al_emb_pairprob ]; then
        echo "running last-pair-probs"
        last-pair-probs -r embryos/$al_emb1 embryos/$al_emb2 > embryos/$al_emb_pairprob 
else
        echo "embryos/$al_emb_pairprob already exists"
fi
# - maf-convert sam
if [ ! -e embryos/$sam_emb ]; then
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam embryos/$al_emb_pairprob > embryos/$sam_emb 
else
        echo "embryos/$sam_emb already exists"
fi
# - convert SAM -> BAM, sort, index
if [ ! -e embryos/$SORT_BAM_emb ]; then
        echo "converting sam to bam and sort"
        samtools view -bt $fai_FILE $sam_emb | samtools sort -o $SORT_BAM_emb  
        echo "index $SORT_BAM_emb"
        samtools index $SORT_BAM_emb
else
        echo "embryos/$SORT_BAM_emb already exists"
fi

# immature adults
# - spliced alignment of Read1
if [ ! -e immatureAdults/$al_imm1 ]; then
        echo "doing spliced-alignment on immature adults (Read1)"
        lastal -i1 -P8 -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p immatureAdults/$train_imm $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_1_filtered_trimmed_sorted_numbered.fastq | last-postmask > immatureAdults/$al_imm1
else
        echo "immatureAdults/$al_imm1 already exists"
fi
# - spliced alignment of Read2
if [ ! -e immatureAdults/$al_imm2 ]; then
        echo "doing spliced-alignment on immature adults (Read2)"
        lastal -i1 -P8 -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p immatureAdults/$train_imm $dbNAME/$dbNAME ../rna-seq-data/immatureAdults/ERR4570986_2_filtered_trimmed_sorted_numbered.fastq | last-postmask > immatureAdults/$al_imm2
else
        echo "immatureAdults/$al_imm2 already exists"
fi
# - last-pair-probs Read1, Read2
if [ ! -e immatureAdults/$al_imm_pairprob ]; then
        echo "running last-pair-probs"
        last-pair-probs -r immatureAdults/$al_imm1 immatureAdults/$al_imm2 > immatureAdults/$al_imm_pairprob 
else
        echo "immatureAdults/$al_imm_pairprob already exists"
fi
# - maf-convert sam
if [ ! -e immatureAdults/$sam_imm ]; then
        echo "convert maf to sam"
        maf-convert -j1e5 -d sam immatureAdults/$al_imm_pairprob > immatureAdults/$sam_imm 
else
        echo "immatureAdults/$sam_imm already exists"
fi
# - convert SAM -> BAM, sort, index
if [ ! -e immatureAdults/$SORT_BAM_imm ]; then
        echo "converting sam to bam and sort"
        samtools view -bt $fai_FILE $sam_imm | samtools sort -o $SORT_BAM_imm  
        echo "index $SORT_BAM_imm"
        samtools index $SORT_BAM_imm
else
        echo "immatureAdults/$SORT_BAM_imm already exists"
fi

# mature adults
# - spliced alignment of Read1
if [ ! -e maturedAdults/$al_mat1 ]; then
        echo "doing spliced-alignment on matured adults (Read1)"
        lastal -i1 -P8 -D10 --split-d 0 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p maturedAdults/$train_mat $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_1_filtered_trimmed_sorted_numbered.fastq | last-postmask > maturedAdults/$al_mat1
else
        echo "maturedAdults/$al_mat1 already exists"
fi
# - spliced alignment of Read2
if [ ! -e maturedAdults/$al_mat2 ]; then
        echo "doing spliced-alignment on matured adults (Read2)"
        lastal -i1 -P8 -D10 --split-d 1 --split-M 3.78 --split-S 0.065 --split-m 0.5 -p maturedAdults/$train_mat $dbNAME/$dbNAME ../rna-seq-data/maturedAdults/ERR4570987_2_filtered_trimmed_sorted_numbered.fastq | last-postmask > maturedAdults/$al_mat2
else
        echo "maturedAdults/$al_mat2 already exists"
fi
# - last-pair-probs Read1, Read2
if [ ! -e maturedAdults/$al_mat_pairprob ]; then
        echo "running last-pair-probs"
        last-pair-probs -r maturedAdults/$al_mat1 maturedAdults/$al_mat2 > maturedAdults/$al_mat_pairprob 
else
        echo "maturedAdults/$al_mat_pairprob already exists"
fi
# - maf-convert sam
if [ ! -e maturedAdults/$sam_mat ]; then
        echo "converting maf to sam"
        maf-convert -j1e5 -d sam maturedAdults/$al_mat_pairprob > maturedAdults/$sam_mat 
else
        echo "maturedAdults/$sam_mat already exists"
fi
# - convert SAM -> BAM, sort, index
if [ ! -e maturedAdults/$SORT_BAM_mat ]; then
        echo "converting sam to bam and sort"
        samtools view -bt $fai_FILE $sam_mat| samtools sort -o $SORT_BAM_mat  
        echo "index $SORT_BAM_mat"
        samtools index $SORT_BAM_mat
else
        echo "maturedAdults/$SORT_BAM_mat already exists"
fi
