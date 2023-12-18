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
alnBedFile=$3

# .maf -> .psl
maf-convert psl  $mafFile > $pslFile
# .psl -> aligned segments .bed
awk -v OFS="\t" '{print "chr_"$10, $12, $13, $9, "chr_"$14, $16, $17}' $pslFile > qry_ref.bed

# CDS query anno (chr, start, end, strand, geneID)
cat $qryAnnoFile  awk -v OFS='\t' '$3=="CDS"{split($9, a, ";"); split(a[1], b, "="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' > oik_anno_exon.bed
# CDS ref anno: .gff -> (chr, start, end, strand, geneID)
cat /home/mrk/oikopleura/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff | awk -v OFS="\t" -F';|=|\t' '$3=="CDS"{for(i=9; i<NF; i+=2) {if ($i == "gene") print "chr_"$1, $4, $5, $7, $(i+1)}}' > lanc_anno_CDS_20231120.bed
# gene query anno (chr, start, end, strand, geneID)
awk -v OFS="\t" '$3=="gene"{split($9, a, ";"); split(a[1],b,"="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' ../oikopleura/OKI2018_I69_1.0.gm.gff > oik_anno_gene_20231129.bed
# gene ref anno: .gff -> (chr, start, end, strand, geneID)
awk -v OFS="\t" -F'\t|=|;' '$3=="gene"{for(i=9; i<NF; i+=2){if ($i=="gene") print "chr_"$1, $4-1, $5, $7, $(i+1)}}' ../lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff > lanc_anno_gene_20231128.bed

# intersect aligned seg on query <- -> query CDS annotation
bedtools intersect -wa -wb -a qry_ref.bed -b oik_anno_CDS_20231106.bed > oik_lanc_oikCDS_20231218_tmp.out
# remove duplicated lines 
# and make it short (chr start end strand chr start end geneID strand)
cat oik_lanc_oikCDS_20231218_tmp.out | awk 'x[$0]++==0' | awk -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $11, $13}' > oik_lanc_oikCDS_20231218.out

# query CDS annotation <- -> query gene annotation 
# query coord, strand, ref coord, geneID, strand, query whole gene coord
# If $8 in the first file is equal to $5 in the second file, merge the line of the first file and the second file.
awk 'NR==FNR{a[$8]=$0; next} $5 in a{print a[$5], $0}' oik_lanc_oikCDS_20231218.out oik_anno_gene_20231129.bed| awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' | awk -v OFS="\t" '{gsub(/^chr_/, "", $10)}1' > oik_lanc_oikCDS_oikGene_20231218.out

# bring ref coord to left
cat oik_lanc_oikCDS_oikGene_20231218.out | awk -v OFS="\t" '{print $5, $6, $7, $1, $2, $3, $4, $8, $9, $10, $11, $12}' > lanc_oik_oikCDS_oikGene_20231218.out
# intersect aligned seg on ref <- -> ref CDS annotation
bedtools intersect -wa -wb -a lanc_oik_oikCDS_oikGene_20231218.out -b lanc_anno_CDS_20231121.bed > lanc_oik_oikCDS_oikGene_lancCDS_20231218_tmp.out
# remove duplicated lines and make it short
cat lanc_oik_oikCDS_oikGene_lancCDS_20231218_tmp.out | awk 'x[$0]++==0' | awk -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $16, $17}' > lanc_oik_oikCDS_oikGene_lancCDS_20231218.out

# intersect aligned seg on ref <- -> ref gene anno
# If $13 in the first file is equal to $5 in the second file, merge the line of the first file and the second file.
awk 'NR==FNR{a[$13]=$0; next} $5 in a{print a[$5], $0}' lanc_oik_oikCDS_oikGene_lancCDS_20231214.out lanc_anno_gene_20231128.bed| awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17}' | awk -v OFS="\t" '{gsub(/^chr_/, "", $15)}1' > lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231214.out

# separate data into
# consistent and inconsistent
awk '{if ($7 == "+" && $9 == $14) print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent.out"; else if ($7 != "+" && $9 != $14) print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent.out"; else print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_inconsistent.out"}' lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231214.out

