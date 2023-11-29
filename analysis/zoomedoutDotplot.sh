#!/bin/bash
argNum=1

if [ $# -ne $argNum ]; then
        echo "You need $argNum arguments." 1>&2
        echo "- path to the target directory" 1>&2 # $1
        exit 1
fi

targetDir=$1
pslFile="/Users/nakagawamariko/biohazard/data/lanc_oik_last/eachOikPart_OnePartInLanc_alignment_20230706_sortedByQuery.psl"
refAnnoFile="/Users/nakagawamariko/biohazard/data/lancelets/ncbi_dataset/data/GCF_000003815.2/genomic.gff"
qryAnnoFile="/Users/nakagawamariko/biohazard/data/oikopleura/OKI2018_I69_1.0.gm.gff"

cd $targetDir

for file in $(ls qgene*\.out); do 
  # echo "$file"
  if [ -f "$file" ]; then
    pngFile="$(echo "$file" | sed 's/.*\.\(ranno\.ref\.[^.]*\)\.out/\1.png/')"
    
    refAnnoRange=""
    qryAnnoRange=""
    
    
    # echo "$pslFile"
    python ~/biohazard/oikopleura/last/last-dotplot_mariko_1513.py --sort1=3 --strands1=1 --border-color=silver --rot1=v --labels1=2 --labels2=2 --fontsize=10 -a $refAnnoFile -b $qryAnnoFile $file $pngFile
  fi
done
