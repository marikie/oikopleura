#!/usr/bin/bash

cd ~/data/oikopleura/analysis/embryos
echo "embryos: getting deletion length distribution"
python ~/oikopleura/analysis/getDeletionLengthDistribution.py ~/data/oikopleura/last/embryos/lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted.maf > deletionLengthDist_lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted.txt

cd ~/data/oikopleura/analysis/immatureAdults
echo "immature adults: getting deletion length distribution"
python ~/oikopleura/analysis/getDeletionLengthDistribution.py ~/data/oikopleura/last/immatureAdults/lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted.maf > deletionLengthDist_lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted.txt

cd ~/data/oikopleura/analysis/maturedAdults
echo "matured adults: getting deletion length distribution"
python ~/oikopleura/analysis/getDeletionLengthDistribution.py ~/data/oikopleura/last/maturedAdults/lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted.maf > deletionLengthDist_lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted.txt
