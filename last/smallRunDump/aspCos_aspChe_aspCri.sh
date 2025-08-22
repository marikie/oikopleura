#!/bin/bash

# aspCos_aspChe_aspCri
echo "---aspCos_aspChe_aspCri"
cd ~/data/aspCos_aspChe_aspCri/

maf-linked aspCos2aspChe_one2one_20240617.maf >aspCos2aspChe_one2one_20240617_maflinked.maf
maf-linked aspCos2aspCri_one2one_20240617.maf >aspCos2aspCri_one2one_20240617_maflinked.maf
maf-sort aspCos2aspChe_one2one_20240617_maflinked.maf >aspCos2aspChe_one2one_20240617_maflinked_sorted.maf
maf-sort aspCos2aspCri_one2one_20240617_maflinked.maf >aspCos2aspCri_one2one_20240617_maflinked_sorted.maf
maf-join aspCos2aspChe_one2one_20240617_maflinked_sorted.maf aspCos2aspCri_one2one_20240617_maflinked_sorted.maf >aspCos_aspChe_aspCri_20240617_maflinked.maf


python ~/scripts/analysis/triUvMuts_2TSVs.py aspCos_aspChe_aspCri_20240617_maflinked.maf aspChe_20240617_maflinked.tsv aspCri_20240617_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R aspChe_20240617_maflinked.tsv aspChe_20240617_maflinked.pdf 0 >aspChe_20240617_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R aspCri_20240617_maflinked.tsv aspCri_20240617_maflinked.pdf 0 >aspCri_20240617_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R aspChe_20240617_maflinked.tsv aspChe_20240617_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R aspCri_20240617_maflinked.tsv aspCri_20240617_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R aspChe_20240617_maflinked.tsv aspChe_20240617_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R aspCri_20240617_maflinked.tsv aspCri_20240617_ori_maflinked.pdf 0
