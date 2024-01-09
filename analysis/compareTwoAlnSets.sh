# extract necessary columns
cat lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent_20231228.out | awk -F"\t" -v OFS="\t" '{print $1, $2, $3, $13, $4, $5, $6, $8}' >lanc_lancGene_oik_oikGene_consistent_20240109.out
cat lanc_eshk_eshkCDS_eshkGene_lancCDS_lancGene_consistent_20240108.out | awk -F"\t" -v OFS="\t" '{print $1, $2, $3, $13, $4, $5, $6, $8}' >lanc_lancGene_eshk_eshkGene_consistent_20240109.out
