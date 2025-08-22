#!/bin/bash

# proCut_proCif_proBov
echo "---proCut_proCif_proBov"
cd ~/data/proCut_proCif_proBov/

maf-linked proCut2proCif_one2one_20240423.maf >proCut2proCif_one2one_20240423_maflinked.maf
maf-linked proCut2proBov_one2one_20240423.maf >proCut2proBov_one2one_20240423_maflinked.maf
maf-sort proCut2proCif_one2one_20240423_maflinked.maf >proCut2proCif_one2one_20240423_maflinked_sorted.maf
maf-sort proCut2proBov_one2one_20240423_maflinked.maf >proCut2proBov_one2one_20240423_maflinked_sorted.maf
maf-join proCut2proCif_one2one_20240423_maflinked_sorted.maf proCut2proBov_one2one_20240423_maflinked_sorted.maf >proCut_proCif_proBov_20240423_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py proCut_proCif_proBov_20240423_maflinked.maf proCif_20240423_maflinked.tsv proBov_20240423_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R proCif_20240423_maflinked.tsv proCif_20240423_maflinked.pdf 0 >proCif_20240423_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R proBov_20240423_maflinked.tsv proBov_20240423_maflinked.pdf 0 >proBov_20240423_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R proCif_20240423_maflinked.tsv proCif_20240423_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R proBov_20240423_maflinked.tsv proBov_20240423_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R proCif_20240423_maflinked.tsv proCif_20240423_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R proBov_20240423_maflinked.tsv proBov_20240423_ori_maflinked.pdf 0
