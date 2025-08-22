#!/bin/bash

# oenArg_oenGla_oenEla
echo "---oenArg_oenGla_oenEla"
cd ~/data/oenArg_oenGla_oenEla/

maf-linked oenArg2oenGla_one2one_20240802.maf >oenArg2oenGla_one2one_20240802_maflinked.maf
maf-linked oenArg2oenEla_one2one_20240802.maf >oenArg2oenEla_one2one_20240802_maflinked.maf
maf-sort oenArg2oenGla_one2one_20240802_maflinked.maf >oenArg2oenGla_one2one_20240802_maflinked_sorted.maf
maf-sort oenArg2oenEla_one2one_20240802_maflinked.maf >oenArg2oenEla_one2one_20240802_maflinked_sorted.maf
maf-join oenArg2oenGla_one2one_20240802_maflinked_sorted.maf oenArg2oenEla_one2one_20240802_maflinked_sorted.maf >oenArg_oenGla_oenEla_20240802_maflinked.maf


python ~/scripts/analysis/triUvMuts_2TSVs.py oenArg_oenGla_oenEla_20240802_maflinked.maf oenGla_20240802_maflinked.tsv oenEla_20240802_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R oenGla_20240802_maflinked.tsv oenGla_20240802_maflinked.pdf 0 >oenGla_20240802_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R oenEla_20240802_maflinked.tsv oenEla_20240802_maflinked.pdf 0 >oenEla_20240802_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R oenGla_20240802_maflinked.tsv oenGla_20240802_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R oenEla_20240802_maflinked.tsv oenEla_20240802_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R oenGla_20240802_maflinked.tsv oenGla_20240802_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R oenEla_20240802_maflinked.tsv oenEla_20240802_ori_maflinked.pdf 0

