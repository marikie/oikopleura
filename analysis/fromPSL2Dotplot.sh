#!/bin/bash
argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1
refAnnoFile="/Users/nakagawamariko/biohazard/data/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff"
qryAnnoFile="/Users/nakagawamariko/biohazard/data/oikopleura/OKI2018_I69_1.0.gm.gff"

cd $targetDir

for file in $(ls $targetDir); do 
  # echo "$file"
  if [ -f "$file" ]; then
    basename="$(basename "$file" ".psl")"
    ziPngFile=$basename"_zi.png"
    # zoPngFile="$(basename)_zo.png"
    
    # echo "$pslFile"
    python ~/biohazard/oikopleura/last/last-dotplot_mariko_1513.py --sort1=3 --strands1=1 --border-color=silver --rot1=v --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile $file ../PNG/$ziPngFile


    # last-dotplot  --max-gap2=100 --max-gap1=100 --sort1=3 --strands1=1 --border-color=silver --border-pixels=5 --rot1=v  --rot2=h --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile  -1 NC_049980.1:19957171-19987773 -1 NC_049982.1:15230685-15257151 -2 PAR:5803360-5809454  /Users/nakagawamariko/biohazard/data/lanc_oik_last/eachOikPart_OnePartInLanc_alignment_20230706_sortedByQuery.maf ./test_anno.png\n\n
  fi
done
