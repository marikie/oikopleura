#!/bin/bash

# gigPla_batSep_batBro
echo "---gigPla_batSep_batBro"
cd ~/data/gigPla_batSep_batBro/

maf-linked gigPla2batSep_one2one_20240610.maf >gigPla2batSep_one2one_20240610_maflinked.maf
maf-linked gigPla2batBro_one2one_20240610.maf >gigPla2batBro_one2one_20240610_maflinked.maf
maf-sort gigPla2batSep_one2one_20240610_maflinked.maf >gigPla2batSep_one2one_20240610_maflinked_sorted.maf
maf-sort gigPla2batBro_one2one_20240610_maflinked.maf >gigPla2batBro_one2one_20240610_maflinked_sorted.maf
maf-join gigPla2batSep_one2one_20240610_maflinked_sorted.maf gigPla2batBro_one2one_20240610_maflinked_sorted.maf >gigPla_batSep_batBro_20240610_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py gigPla_batSep_batBro_20240610_maflinked.maf batSep_20240610_maflinked.tsv batBro_20240610_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R batSep_20240610_maflinked.tsv batSep_20240610_maflinked.pdf 0 >batSep_20240610_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R batBro_20240610_maflinked.tsv batBro_20240610_maflinked.pdf 0 >batBro_20240610_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R batSep_20240610_maflinked.tsv batSep_20240610_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R batBro_20240610_maflinked.tsv batBro_20240610_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R batSep_20240610_maflinked.tsv batSep_20240610_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R batBro_20240610_maflinked.tsv batBro_20240610_ori_maflinked.pdf 0


