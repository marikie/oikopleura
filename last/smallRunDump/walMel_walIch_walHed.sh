#!/bin/bash

# walMel_walIch_walHed
echo "---walMel_walIch_walHed"
cd ~/data/walMel_walIch_walHed/

maf-linked walMel2walIch_one2one_20240611.maf >walMel2walIch_one2one_20240611_maflinked.maf
maf-linked walMel2walHed_one2one_20240611.maf >walMel2walHed_one2one_20240611_maflinked.maf
maf-sort walMel2walIch_one2one_20240611_maflinked.maf >walMel2walIch_one2one_20240611_maflinked_sorted.maf
maf-sort walMel2walHed_one2one_20240611_maflinked.maf >walMel2walHed_one2one_20240611_maflinked_sorted.maf
maf-join walMel2walIch_one2one_20240611_maflinked_sorted.maf walMel2walHed_one2one_20240611_maflinked_sorted.maf >walMel_walIch_walHed_20240611_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py walMel_walIch_walHed_20240611_maflinked.maf walIch_20240611_maflinked.tsv walHed_20240611_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R walIch_20240611_maflinked.tsv walIch_20240611_maflinked.pdf 0 >walIch_20240611_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R walHed_20240611_maflinked.tsv walHed_20240611_maflinked.pdf 0 >walHed_20240611_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R walIch_20240611_maflinked.tsv walIch_20240611_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R walHed_20240611_maflinked.tsv walHed_20240611_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R walIch_20240611_maflinked.tsv walIch_20240611_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R walHed_20240611_maflinked.tsv walHed_20240611_ori_maflinked.pdf 0


