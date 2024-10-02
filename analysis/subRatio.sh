#!/bin/bash

echo -e "\n\nmytEdu, mytGal" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/mytTro_mytEdu_mytGal/mytTro_mytEdu_mytGal_20240428.maf >> /home/mrk/data/subRatios.out

echo -e "\n\nulvMut, ulvCom" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/ulvPro_ulvMut_ulvCom/ulvPro_ulvMut_ulvCom_20240610.maf >> /home/mrk/data/subRatios.out

echo -e "\n\nostTau, ostLuc" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/ostMed_ostTau_ostLuc/ostMed_ostTau_ostLuc_20240423.maf >> /home/mrk/data/subRatios.out

echo -e "\n\nproCif, proBov" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/proCut_proCif_proBov/proCut_proCif_proBov_20240423.maf >> /home/mrk/data/subRatios.out

echo -e "\n\nwalIch, walHed" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/walMel_walIch_walHed/walMel_walIch_walHed_20240611.maf >> /home/mrk/data/subRatios.out

echo -e "\n\naspChe, aspCri" >> /home/mrk/data/subRatios.out
python subRatio.py /home/mrk/data/aspCos_aspChe_aspCri/aspCos_aspChe_aspCri_20240617.maf >> /home/mrk/data/subRatios.out