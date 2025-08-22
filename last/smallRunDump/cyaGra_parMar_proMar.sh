#!/bin/bash

# cyaGra_parMar_proMar
echo "---cyaGra_parMar_proMar"
cd ~/data/cyaGra_parMar_proMar/

maf-linked cyaGra2parMar_one2one_20240911.maf >cyaGra2parMar_one2one_20240911_maflinked.maf
maf-linked cyaGra2proMar_one2one_20240911.maf >cyaGra2proMar_one2one_20240911_maflinked.maf
maf-sort cyaGra2parMar_one2one_20240911_maflinked.maf >cyaGra2parMar_one2one_20240911_maflinked_sorted.maf
maf-sort cyaGra2proMar_one2one_20240911_maflinked.maf >cyaGra2proMar_one2one_20240911_maflinked_sorted.maf
maf-join cyaGra2parMar_one2one_20240911_maflinked_sorted.maf cyaGra2proMar_one2one_20240911_maflinked_sorted.maf >cyaGra_parMar_proMar_20240911_maflinked.maf


python ~/scripts/analysis/triUvMuts_2TSVs.py cyaGra_parMar_proMar_20240911_maflinked.maf parMar_20240911_maflinked.tsv proMar_20240911_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R parMar_20240911_maflinked.tsv parMar_20240911_maflinked.pdf 0 >parMar_20240911_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R proMar_20240911_maflinked.tsv proMar_20240911_maflinked.pdf 0 >proMar_20240911_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R parMar_20240911_maflinked.tsv parMar_20240911_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R proMar_20240911_maflinked.tsv proMar_20240911_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R parMar_20240911_maflinked.tsv parMar_20240911_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R proMar_20240911_maflinked.tsv proMar_20240911_ori_maflinked.pdf 0
