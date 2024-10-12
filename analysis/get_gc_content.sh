#!/bin/bash

echo "oikAlb"
echo "python gc_content.py /home/mrk/genomes/oikAlb/GCA_004367875.1_ASM436787v1_genomic.fna"
python gc_content.py /home/mrk/genomes/oikAlb/GCA_004367875.1_ASM436787v1_genomic.fna

echo -e "\noikVan"
echo "python gc_content.py /home/mrk/genomes/oikVan/GCA_004367855.1_ASM436785v1_genomic.fna"
python gc_content.py /home/mrk/genomes/oikVan/GCA_004367855.1_ASM436785v1_genomic.fna 

echo -e "\nbatBro"
echo "python gc_content.py /home/mrk/genomes/bathymodiolusBrooksi/GCA_963680875.1_xbBatBroo1.1_genomic.fna"
python gc_content.py /home/mrk/genomes/bathymodiolusBrooksi/GCA_963680875.1_xbBatBroo1.1_genomic.fna

echo -e "\nbatSep"
echo "python gc_content.py /home/mrk/genomes/bathymodiolusSeptemdierum/GCA_963383655.1_xbBatSept2.1_genomic.fna"
python gc_content.py /home/mrk/genomes/bathymodiolusSeptemdierum/GCA_963383655.1_xbBatSept2.1_genomic.fna

echo -e "\nmytEdu"
echo "python gc_content.py /home/mrk/genomes/mytilusEdulis/GCA_019925275.1_PEIMed_genomic.fna"
python gc_content.py /home/mrk/genomes/mytilusEdulis/GCA_019925275.1_PEIMed_genomic.fna

echo -e "\nmytGal"
echo "python gc_content.py /home/mrk/genomes/mytilusGalloprovincialis/GCA_037788925.1_MytGallo_primary_0.1_genomic.fna"
python gc_content.py /home/mrk/genomes/mytilusGalloprovincialis/GCA_037788925.1_MytGallo_primary_0.1_genomic.fna

echo -e "\nulvCom"
echo "python gc_content.py /home/mrk/genomes/ulvaCompressa/GCA_024500015.1_ASM2450001v1_genomic.fna"
python gc_content.py /home/mrk/genomes/ulvaCompressa/GCA_024500015.1_ASM2450001v1_genomic.fna

echo -e "\nulvMut"
echo "python gc_content.py /home/mrk/genomes/ulvaMutabilis/GCA_900538255.1_Ulvmu_WT_fa_genomic.fna"
python gc_content.py /home/mrk/genomes/ulvaMutabilis/GCA_900538255.1_Ulvmu_WT_fa_genomic.fna

echo -e "\nostTau"
echo "python gc_content.py /home/mrk/genomes/ostreococcusTauri/GCF_000214015.3_version_140606_genomic.fna"
python gc_content.py /home/mrk/genomes/ostreococcusTauri/GCF_000214015.3_version_140606_genomic.fna

echo -e "\nostLuc"
echo "python gc_content.py /home/mrk/genomes/ostreococcusLucimarinus/GCF_000092065.1_ASM9206v1_genomic.fna"
python gc_content.py /home/mrk/genomes/ostreococcusLucimarinus/GCF_000092065.1_ASM9206v1_genomic.fna

echo -e "\nproBov"
echo "python gc_content.py /home/mrk/genomes/protothecaBovis/GCA_003612995.1_ASM361299v1_genomic.fna"
python gc_content.py /home/mrk/genomes/protothecaBovis/GCA_003612995.1_ASM361299v1_genomic.fna

echo -e "\nproCif"
echo "python gc_content.py /home/mrk/genomes/protothecaCiferrii/GCA_003613005.1_ASM361300v1_genomic.fna"
python gc_content.py /home/mrk/genomes/protothecaCiferrii/GCA_003613005.1_ASM361300v1_genomic.fna

echo -e "\nwalIch"
echo "python gc_content.py /home/mrk/genomes/wallemiaIchthyophaga/GCF_000400465.1_Wallemia_ichthyophaga_version_1.0_genomic.fna"
python gc_content.py /home/mrk/genomes/wallemiaIchthyophaga/GCF_000400465.1_Wallemia_ichthyophaga_version_1.0_genomic.fna

echo -e "\nwalHed"
echo "python gc_content.py /home/mrk/genomes/wallemiaHederae/GCA_004918325.1_ASM491832v1_genomic.fna"
python gc_content.py /home/mrk/genomes/wallemiaHederae/GCA_004918325.1_ASM491832v1_genomic.fna

echo -e "\naspChe"
echo "python gc_content.py /home/mrk/genomes/aspergillusChevalieri/GCF_016861735.1_AchevalieriM1_assembly01_genomic.fna"
python gc_content.py /home/mrk/genomes/aspergillusChevalieri/GCF_016861735.1_AchevalieriM1_assembly01_genomic.fna

echo -e "\naspCri"
echo "python gc_content.py /home/mrk/genomes/aspergillusCristatus/GCA_034509305.1_ASM3450930v1_genomic.fna"
python gc_content.py /home/mrk/genomes/aspergillusCristatus/GCA_034509305.1_ASM3450930v1_genomic.fna

echo -e "\nulvMutCh" >> /home/mrk/data/gc_contents.out
python gc_content.py /home/mrk/genomes/chloroplast/Ulva_mutabilis_chloroplast.fasta >> /home/mrk/data/gc_contents.out

echo -e "\nulvComCh" >> /home/mrk/data/gc_contents.out
python gc_content.py /home/mrk/genomes/chloroplast/Ulva_compressa_chloroplast.fasta >> /home/mrk/data/gc_contents.out

echo -e "\nproBovPl" >> /home/mrk/data/gc_contents.out
python gc_content.py /home/mrk/genomes/plastids/Prototheca_bovis_plastid.fasta >> /home/mrk/data/gc_contents.out

echo -e "\nproCifPl" >> /home/mrk/data/gc_contents.out
python gc_content.py /home/mrk/genomes/plastids/Prototheca_ciferrii_plastid.fasta >> /home/mrk/data/gc_contents.out

