#!/bin/bash

# oenArg_oenOak_oenPar
echo "---oenArg_oenOak_oenPar"
cd ~/data/oenArg_oenOak_oenPar/

maf-linked oenArg2oenOak_one2one_20240802.maf >oenArg2oenOak_one2one_20240802_maflinked.maf
maf-linked oenArg2oenPar_one2one_20240802.maf >oenArg2oenPar_one2one_20240802_maflinked.maf
maf-sort oenArg2oenOak_one2one_20240802_maflinked.maf >oenArg2oenOak_one2one_20240802_maflinked_sorted.maf
maf-sort oenArg2oenPar_one2one_20240802_maflinked.maf >oenArg2oenPar_one2one_20240802_maflinked_sorted.maf
maf-join oenArg2oenOak_one2one_20240802_maflinked_sorted.maf oenArg2oenPar_one2one_20240802_maflinked_sorted.maf >oenArg_oenOak_oenPar_20240802_maflinked.maf


python ~/scripts/analysis/triUvMuts_2TSVs.py oenArg_oenOak_oenPar_20240802_maflinked.maf oenOak_20240802_maflinked.tsv oenPar_20240802_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R oenOak_20240802_maflinked.tsv oenOak_20240802_maflinked.pdf 0 >oenOak_20240802_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R oenPar_20240802_maflinked.tsv oenPar_20240802_maflinked.pdf 0 >oenPar_20240802_maflinked.out


Rscript ~/scripts/analysis/R/sbmut_sbstCount.R oenOak_20240802_maflinked.tsv oenOak_20240802_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R oenPar_20240802_maflinked.tsv oenPar_20240802_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R oenOak_20240802_maflinked.tsv oenOak_20240802_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R oenPar_20240802_maflinked.tsv oenPar_20240802_ori_maflinked.pdf 0

