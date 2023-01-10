#!/usr/bin/bash

cd ~/data/oikopleura/analysis/embryos
echo "embryos: getting splicing signals"
python ~/oikopleura/analysis/getSplicingSignalsDistOfExactSplicings.py ~/data/oikopleura/last/embryos/lastsplitOKI2018_I69_1.0_ERR4570985_filtered_trimmed_sorted.maf > splicingSignalsDistExactSplicings_embryos_filtered_trimmed_sorted.tsv 2> splicingSignalsDistExactSplicings_embryos_filtered_trimmed_sorted.error

cd ~/data/oikopleura/analysis/immatureAdults
echo "immature adults: getting splicing signals"
python ~/oikopleura/analysis/getSplicingSignalsDistOfExactSplicings.py ~/data/oikopleura/last/immatureAdults/lastsplitOKI2018_I69_1.0_ERR4570986_filtered_trimmed_sorted.maf > splicingSignalsDistExactSplicings_immature_filtered_trimmed_sorted.tsv 2> splicingSignalsDistExactSplicings_immature_filtered_trimmed_sorted.error

cd ~/data/oikopleura/analysis/maturedAdults
echo "matured adults: getting splicing signals"
python ~/oikopleura/analysis/getSplicingSignalsDistOfExactSplicings.py ~/data/oikopleura/last/maturedAdults/lastsplitOKI2018_I69_1.0_ERR4570987_filtered_trimmed_sorted.maf > splicingSignalsDistExactSplicings_matured_filtered_trimmed_sorted.tsv 2> splicingSignalsDistExactSplicings_matured_filtered_trimmed_sorted.error
