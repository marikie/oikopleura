#!/bin/bash

# bedtool intersect ref coord & ref gene annotation

argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- .maf alignment file" 1>&2 # $1
        echo "- .gff annotation file of the query" # $2
        exit 1
fi

mafFile=$1
pslFile=$(basename "${mafFile%.*}")
qryAnnoFile=$2
alnBedFile=

# .maf -> .psl
maf-convert psl  $mafFile > $pslFile
# .psl -> aligned segments .bed
awk -v OFS="\t" '{print "chr_"$10, $12, $13, $9, "chr_"$14, $16, $17}' $pslFile > alignedSegs.bed

# CDS query anno (chr, start, end, strand, geneID)
cat $qryAnnoFile  awk -v OFS='\t' '$3=="CDS"{split($9, a, ";"); split(a[1], b, "="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' > oik_anno_exon.bed

# intersect aligned seg on query <- -> query CDS annotation
bedtools intersect -wa -wb -a oik_lanc_many2one_alignedQuery_20231106.bed -b oik_anno_CDS_20231106.bed > oik_lanc_intersect_oik_anno_20231106.out
# make it short (chr start end strand chr start end geneID strand)
# and remove duplicated lines
cat oik_lanc_intersect_oik_anno_20231110.out | awk -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $11, $13}' | awk 'x[$0]++==0' > oik_lanc_intersect_oik_anno_shrt_20231207.out
# remove duplicated lines
cat oik_lanc_intersect_oik_anno_shrt_20231205.out | awk 'x[$0]++==0' > oik_lanc_intersect_oik_anno_shrt_merged_20231207.out

# gene query anno (chr, start, end, strand, geneID)
awk -v OFS="\t" '$3=="gene"{split($9, a, ";"); split(a[1],b,"="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' ../oikopleura/OKI2018_I69_1.0.gm.gff > oik_anno_gene_20231129.bed

# intersect aligned seg on query <- -> query gene annotation 
bedtools intersect -wa -wb -a oik_lanc_intersect_oik_anno_shrt_merged_20231207.out -b oik_anno_gene_20231129.bed 
