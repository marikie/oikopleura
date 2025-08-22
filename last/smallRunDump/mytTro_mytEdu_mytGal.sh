#!/bin/bash

# mytTro_mytEdu_mytGal
echo "---mytTro_mytEdu_mytGal"
cd ~/data/mytTro_mytEdu_mytGal/

maf-linked mytTro2mytEdu_one2one_20240428.maf >mytTro2mytEdu_one2one_20240428_maflinked.maf
maf-linked mytTro2mytGal_one2one_20240428.maf >mytTro2mytGal_one2one_20240428_maflinked.maf
maf-sort mytTro2mytEdu_one2one_20240428_maflinked.maf >mytTro2mytEdu_one2one_20240428_maflinked_sorted.maf
maf-sort mytTro2mytGal_one2one_20240428_maflinked.maf >mytTro2mytGal_one2one_20240428_maflinked_sorted.maf
maf-join mytTro2mytEdu_one2one_20240428_maflinked_sorted.maf mytTro2mytGal_one2one_20240428_maflinked_sorted.maf >mytTro_mytEdu_mytGal_20240428_maflinked.maf


python ~/scripts/analysis/triUvMuts_2TSVs.py mytTro_mytEdu_mytGal_20240428_maflinked.maf mytEdu_20240428_maflinked.tsv mytGal_20240428_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R mytEdu_20240428_maflinked.tsv mytEdu_20240428_maflinked.pdf 0 >mytEdu_20240428_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R mytGal_20240428_maflinked.tsv mytGal_20240428_maflinked.pdf 0 >mytGal_20240428_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R mytEdu_20240428_maflinked.tsv mytEdu_20240428_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R mytGal_20240428_maflinked.tsv mytGal_20240428_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R mytEdu_20240428_maflinked.tsv mytEdu_20240428_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R mytGal_20240428_maflinked.tsv mytGal_20240428_ori_maflinked.pdf 0



