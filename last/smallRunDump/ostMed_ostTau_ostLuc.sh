#!/bin/bash

# ostMed_ostTau_ostLuc
echo "---ostMed_ostTau_ostLuc"
cd ~/data/ostMed_ostTau_ostLuc/

maf-linked ostMed2ostTau_one2one_20240423.maf >ostMed2ostTau_one2one_20240423_maflinked.maf
maf-linked ostMed2ostLuc_one2one_20240423.maf >ostMed2ostLuc_one2one_20240423_maflinked.maf
maf-sort ostMed2ostTau_one2one_20240423_maflinked.maf >ostMed2ostTau_one2one_20240423_maflinked_sorted.maf
maf-sort ostMed2ostLuc_one2one_20240423_maflinked.maf >ostMed2ostLuc_one2one_20240423_maflinked_sorted.maf
maf-join ostMed2ostTau_one2one_20240423_maflinked_sorted.maf ostMed2ostLuc_one2one_20240423_maflinked_sorted.maf >ostMed_ostTau_ostLuc_20240423_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py ostMed_ostTau_ostLuc_20240423_maflinked.maf ostTau_20240423_maflinked.tsv ostLuc_20240423_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R ostTau_20240423_maflinked.tsv ostTau_20240423_maflinked.pdf 0 >ostTau_20240423_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R ostLuc_20240423_maflinked.tsv ostLuc_20240423_maflinked.pdf 0 >ostLuc_20240423_maflinked.out


Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ostTau_20240423_maflinked.tsv ostTau_20240423_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ostLuc_20240423_maflinked.tsv ostLuc_20240423_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R ostTau_20240423_maflinked.tsv ostTau_20240423_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R ostLuc_20240423_maflinked.tsv ostLuc_20240423_ori_maflinked.pdf 0


