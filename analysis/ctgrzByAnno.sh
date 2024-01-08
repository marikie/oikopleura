#!/bin/bash

# bedtool intersect ref coord & ref gene annotation

argNum=1

if [ $# -ne $argNum ]; then
	echo "You need $argNum arguments." 1>&2
	echo "- .maf alignment file" 1>&2          # $1
	echo "- .gff annotation file of the query" # $2
	exit 1
fi

mafFile=$1
pslFile=$(basename "${mafFile%.*}")
qryAnnoFile=$2
alnBedFile=$3

# .maf -> .psl
maf-convert psl $mafFile >$pslFile
# .psl -> aligned segments .bed
awk -v OFS="\t" '{print "chr_"$10, $12, $13, $9, "chr_"$14, $16, $17}' $pslFile >qry_ref.bed

# CDS query anno (chr, start, end, strand, geneID)
cat $qryAnnoFile | awk -v OFS='\t' '$3=="CDS"{split($9, a, ";"); split(a[1], b, "="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' >oik_anno_exon.bed
# CDS ref anno: .gff -> (chr, start, end, strand, geneID, proteinDescription)
cat ~/biohazard/data/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff | awk -v OFS="\t" -F';|=|\t' '$3=="CDS"{for(i=9; i<NF; i+=2) {if ($i=="gene") gene=$(i+1); if($i=="product") product=$(i+1)} print "chr_"$1, $4-1, $5, $7, gene, product}' >lanc_anno_CDS_20231219.bed

# gene query anno (chr, start, end, strand, geneID)
awk -v OFS="\t" '$3=="gene"{split($9, a, ";"); split(a[1],b,"="); split(b[2], c, "."); print "chr_"$1, $4-1, $5, $7, c[4]"."c[5]}' ../oikopleura/OKI2018_I69_1.0.gm.gff >oik_anno_gene_20231129.bed
# gene ref anno: .gff -> (chr, start, end, strand, geneID)
awk -v OFS="\t" -F'\t|=|;' '$3=="gene"{for(i=9; i<NF; i+=2){if ($i=="gene") print "chr_"$1, $4-1, $5, $7, $(i+1)}}' ../lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff >lanc_anno_gene_20231128.bed

# intersect aligned seg on query <- -> query CDS annotation
bedtools intersect -wa -wb -a qry_ref.bed -b oik_anno_CDS_20231106.bed >oik_lanc_oikCDS_20231218_tmp.out
# remove duplicated lines
# and make it short (chr start end strand chr start end geneID strand)
cat oik_lanc_oikCDS_20231218_tmp.out | awk -F'\t' 'x[$0]++==0' | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $11, $13}' >oik_lanc_oikCDS_20231218.out

# query CDS annotation <- -> query gene annotation
# query coord, strand, ref coord, geneID, strand, query whole gene coord
# If $5 in the first file is equal to $8 in the second file, merge the line of the first file and the second file.
awk 'NR==FNR{a[$5]=$0; next} $8 in a {print $0, a[$8]}' oik_anno_gene_20231129.bed oik_lanc_oikCDS_20231218.out | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' | awk -v OFS="\t" '{gsub(/^chr_/, "", $10)}1' >oik_lanc_oikCDS_oikGene_20231221.out

# bring ref coord to left
cat oik_lanc_oikCDS_oikGene_20231221.out | awk -v OFS="\t" '{print $5, $6, $7, $1, $2, $3, $4, $8, $9, $10, $11, $12}' >lanc_oik_oikCDS_oikGene_20231221.out
# intersect aligned seg on ref <- -> ref CDS annotation
bedtools intersect -wa -wb -a lanc_oik_oikCDS_oikGene_20231221.out -b lanc_anno_CDS_20231219.bed >lanc_oik_oikCDS_oikGene_lancCDS_20231221_tmp.out
# remove duplicated lines and make it short
# refcoord, qrycoord, alnStrand, qryGeneID, qryGeneStrand, qryGeneCoord, refGeneID, refGeneStrand, proteinDescription
cat lanc_oik_oikCDS_oikGene_lancCDS_20231221_tmp.out | awk -F'\t' -v OFS="\t" 'x[$0]++==0' | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $17, $16, $18}' >lanc_oik_oikCDS_oikGene_lancCDS_20231228.out

# ref CDS anno <- -> ref gene anno
# If $5 in the first file is equal to $13 in the second file, merge the line of the first file and the second file.
awk -F'\t' -v OFS="\t" 'NR==FNR{a[$5]=$0; next} $13 in a {print $0, a[$13]}' lanc_anno_gene_20231128.bed lanc_oik_oikCDS_oikGene_lancCDS_20231228.out | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $16, $17, $18, $15}' | awk -F'\t' -v OFS="\t" '{gsub(/^chr_/, "", $15)}1' >lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231228_tmp.out

# remain only one line with the same aligned coord
awk -F'\t' -v OFS="\t" '!a[$1,$2,$3,$4,$5,$6]++' lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231228_tmp.out >lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231228.out

# separate data into
# consistent and inconsistent
awk -F'\t' -v OFS="\t" '{alnStrand=$7; oikStrand=$9; lancStrand=$14; if (alnStrand == "+" && oikStrand == lancStrand) print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent_20231228.out"; else if (alnStrand != "+" && oikStrand != lancStrand) print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent_20231228.out"; else print >> "lanc_oik_oikCDS_oikGene_lancCDS_lancGene_inconsistent_20231228.out"}' lanc_oik_oikCDS_oikGene_lancCDS_lancGene_20231228.out

mkdir oik2lanc_20231228
cd oik2lanc_20231228
# separate files based on the query geneID
cat ../lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent_20231228.out | awk -F'\t' -v OFS="\t" '{file=$8".out"; print >> file; close(file)}'

# Separate files under a directory into two different directories
# single: files with only one line
# multiple: files with equal to or more than two lines
bash ~/biohazard/oikopleura/analysis/singleLinesOrMultiLines.sh ~/biohazard/data/lanc_oik_last/oik2lanc_20231228

# Separate files under a directory /multiAlnSegsOnTheSameQryGene into two directories
# diffRefGene
# sameRefGene
bash ~/biohazard/oikopleura/analysis/sameOrDiffRefGene.sh ~/biohazard/data/lanc_oik_last/oik2lanc_20231228/multiAlnSegsOnTheSameQryGene

cd ~/biohazard/data/lanc_oik_last/oik2lanc_20231228/multiAlnSegsOnTheSameQryGene/diffRefGene
mkdir OUT
mkdir PNG
mkdir PSL
mv *.out OUT
# make PSL files
bash ~/biohazard/oikopleura/analysis/fromBED2PSL.sh ~/biohazard/data/lanc_oik_last/oik2lanc_20231228/multiAlnSegsOnTheSameQryGene/diffRefGene/OUT ~/biohazard/data/lanc_oik_last/oik2lanc_many2one_20231218.psl
cd OUT
mv *.psl ../PSL

# make dotplot zoom-in PNG files
bash ~/biohazard/oikopleura/analysis/fromPSL2Dotplot.sh ~/biohazard/data/lanc_oik_last/oik2lanc_20231228/multiAlnSegsOnTheSameQryGene/diffRefGene/PSL

# make dotplot zoom-out PNG files
bash ~/biohazard/oikopleura/analysis/fromPSL2Dotplot_zo.sh ~/biohazard/data/lanc_oik_last/oik2lanc_20231228/multiAlnSegsOnTheSameQryGene/diffRefGene/PSL
