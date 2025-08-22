#!/bin/bash

# arcCen_ampZal_ampCit
echo "---arcCen_ampZal_ampCit"
cd ~/data/arcCen_ampZal_ampCit/
maf-linked arcCen2ampZal_one2one_20241126.maf >arcCen2ampZal_one2one_20241126_maflinked.maf
maf-linked arcCen2ampCit_one2one_20241126.maf >arcCen2ampCit_one2one_20241126_maflinked.maf
maf-sort arcCen2ampZal_one2one_20241126_maflinked.maf >arcCen2ampZal_one2one_20241126_maflinked_sorted.maf
maf-sort arcCen2ampCit_one2one_20241126_maflinked.maf >arcCen2ampCit_one2one_20241126_maflinked_sorted.maf
maf-join arcCen2ampZal_one2one_20241126_maflinked_sorted.maf arcCen2ampCit_one2one_20241126_maflinked_sorted.maf >arcCen_ampZal_ampCit_20241126_maflinked.maf

python ~/scripts/analysis/triUvMuts_2TSVs.py arcCen_ampZal_ampCit_20241126_maflinked.maf ampZal_20241126_maflinked.tsv ampCit_20241126_maflinked.tsv

Rscript ~/scripts/analysis/R/sbmut.R ampZal_20241126_maflinked.tsv ampZal_20241126_maflinked.pdf 0 >ampZal_20241126_maflinked.out
Rscript ~/scripts/analysis/R/sbmut.R ampCit_20241126_maflinked.tsv ampCit_20241126_maflinked.pdf 0 >ampCit_20241126_maflinked.out

Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ampZal_20241126_maflinked.tsv ampZal_20241126_sbst_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_sbstCount.R ampCit_20241126_maflinked.tsv ampCit_20241126_sbst_maflinked.pdf 0

Rscript ~/scripts/analysis/R/sbmut_oriCount.R ampZal_20241126_maflinked.tsv ampZal_20241126_ori_maflinked.pdf 0
Rscript ~/scripts/analysis/R/sbmut_oriCount.R ampCit_20241126_maflinked.tsv ampCit_20241126_ori_maflinked.pdf 0
