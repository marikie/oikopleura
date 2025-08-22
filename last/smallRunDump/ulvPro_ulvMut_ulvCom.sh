#!/bin/bash

# ulvPro_ulvMut_ulvCom
echo "---ulvPro_ulvMut_ulvCom"
cd ~/data/ulvPro_ulvMut_ulvCom/

maf-linked ulvPro2ulvMut_one2one_20240610.maf >ulvPro2ulvMut_one2one_20240610_maflinked.maf
maf-linked ulvPro2ulvCom_one2one_20240610.maf >ulvPro2ulvCom_one2one_20240610_maflinked.maf
maf-sort ulvPro2ulvMut_one2one_20240610_maflinked.maf >ulvPro2ulvMut_one2one_20240610_maflinked_sorted.maf
maf-sort ulvPro2ulvCom_one2one_20240610_maflinked.maf >ulvPro2ulvCom_one2one_20240610_maflinked_sorted.maf
maf-join ulvPro2ulvMut_one2one_20240610_maflinked_sorted.maf ulvPro2ulvCom_one2one_20240610_maflinked_sorted.maf >ulvPro_ulvMut_ulvCom_20240610_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py ulvPro_ulvMut_ulvCom_20240610_maflinked.maf ulvMut_20240610_maflinked.tsv ulvCom_20240610_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R ulvMut_20240610_maflinked.tsv ulvMut_20240610_maflinked.pdf 0 >ulvMut_20240610_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R ulvCom_20240610_maflinked.tsv ulvCom_20240610_maflinked.pdf 0 >ulvCom_20240610_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ulvMut_20240610_maflinked.tsv ulvMut_20240610_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ulvCom_20240610_maflinked.tsv ulvCom_20240610_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R ulvMut_20240610_maflinked.tsv ulvMut_20240610_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R ulvCom_20240610_maflinked.tsv ulvCom_20240610_ori_maflinked.pdf 0


