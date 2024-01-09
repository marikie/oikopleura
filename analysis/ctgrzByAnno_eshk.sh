# .maf -> .psl
maf-convert psl eshk2lanc_many2one_20240106.maf >eshk2lanc_many2one_20240106.psl

# .psl -> aligned segments .bed
awk -v OFS="\t" '{print "chr_"$10, $12, $13, $9, "chr_"$14, $16, $17}' eshk2lanc_many2one_20240106.psl >eshk_lanc.bed

# CDS query anno (chr, start, end, strand, geneID)
cat ~/biohazard/data/elephantShark/ncbi_dataset/data/GCF_018977255.1/genomic.gff | awk -v OFS="\t" -F';|=|\t' '$3=="CDS"{for(i=9; i<NF; i+=2) {if ($i=="gene") gene=$(i+1); if($i=="product") product=$(i+1)} print "chr_"$1, $4-1, $5, $7, gene, product}' >eshk_anno_CDS_20240108.bed

# gene query anno (chr, start, end, strand, geneID)
awk -v OFS="\t" -F'\t|=|;' '$3=="gene"{for(i=9; i<NF; i+=2){if ($i=="gene") print "chr_"$1, $4-1, $5, $7, $(i+1)}}' ../elephantShark/ncbi_dataset/data/GCF_018977255.1/genomic.gff >eshk_anno_gene_20240108.bed

# intersect aligned seg on query <- -> query CDS annotation
bedtools intersect -wa -wb -a eshk_lanc.bed -b eshk_anno_CDS_20240108.bed >eshk_lanc_eshkCDS_20240108_tmp.out
# remove duplicated lines
# and make it short (chr start end strand chr start end geneID strand, description)
cat eshk_lanc_eshkCDS_20240108_tmp.out | awk -F'\t' 'x[$0]++==0' | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $12, $11, $13}' >eshk_lanc_eshkCDS_20240108.out

# query CDS annotation <- -> query gene annotation
# query coord, strand, ref coord, geneID, strand, query whole gene coord, description
# If $5 in the first file is equal to $8 in the second file, merge the line of the first file and the second file.
awk -v OFS="\t" 'NR==FNR{a[$5]=$0; next} $8 in a {print $0, a[$8]}' eshk_anno_gene_20240108.bed eshk_lanc_eshkCDS_20240108.out | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $11, $12, $13, $10}' | awk -F'\t' -v OFS="\t" '{gsub(/^chr_/, "", $10)}1' >eshk_lanc_eshkCDS_eshkGene_20240108.out

# bring ref coord to left
cat eshk_lanc_eshkCDS_eshkGene_20240108.out | awk -F'\t' -v OFS="\t" '{print $5, $6, $7, $1, $2, $3, $4, $8, $9, $10, $11, $12, $13}' >lanc_eshk_eshkCDS_eshkGene_20240108.out

# intersect aligned seg on ref <- -> ref CDS annotation
bedtools intersect -wa -wb -a lanc_eshk_eshkCDS_eshkGene_20240108.out -b lanc_anno_CDS_20231219.bed >lanc_eshk_eshkCDS_eshkGene_lancCDS_20240108_tmp.out
# remove duplicated lines and make it short
# refcoord, qrycoord, alnStrand, qryGeneID, qryGeneStrand, qryGeneCoord, refGeneID, refGeneStrand, qryproteinDescription, refproteinDescription
cat lanc_eshk_eshkCDS_eshkGene_lancCDS_20240108_tmp.out | awk -F'\t' -v OFS="\t" 'x[$0]++==0' | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $18, $17, $13, $19}' >lanc_eshk_eshkCDS_eshkGene_lancCDS_20240108.out

# ref CDS anno <- -> ref gene anno
# If $5 in the first file is equal to $13 in the second file, merge the line of the first file and the second file.
awk -F'\t' -v OFS="\t" 'NR==FNR{a[$5]=$0; next} $13 in a {print $0, a[$13]}' lanc_anno_gene_20231128.bed lanc_eshk_eshkCDS_eshkGene_lancCDS_20240108.out | awk -F'\t' -v OFS="\t" '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $17, $18, $19, $15, $16}' | awk -F'\t' -v OFS="\t" '{gsub(/^chr_/, "", $15)}1' >lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_20240108_tmp.out

# remain only one line with the same aligned coord
awk -F'\t' -v OFS="\t" '!a[$1,$2,$3,$4,$5,$6]++' lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_20240108_tmp.out >lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_20240108.out

# separate data into
# consistent and inconsistent
awk -F'\t' -v OFS="\t" '{alnStrand=$7; eshkStrand=$9; lancStrand=$14; if (alnStrand == "+" && eshkStrand == lancStrand) print >> "lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_consistent_20240108.out"; else if (alnStrand != "+" && eshkStrand != lancStrand) print >> "lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_consistent_20240108.out"; else print >> "lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_inconsistent_20240108.out"}' lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_20240108.out
