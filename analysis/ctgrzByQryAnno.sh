#~/bin/bash

argnum=6 

if [ $# -ne $argnum ]; then
        echo "You need $argnum arguments." 1>&2
        echo "- output dir path" #1
        echo "- today's date" 1>&2 #2
        echo "- chr name of the query" 1>&2 #3
        echo "- alignment .maf file path" 1>&2 #4
        echo "- query annotation .gff file path" 1>&2 #5
        echo "- reference annotation .gff file path" 1>&2 #6
        exit 1
fi

OUTDIRPATH="$1_$2"
chrName=$3

# make $mafFile_chr
mafFile=$4
mafFile_chr="${mafFile:0:-4}_$chrName.maf"
awk '!/^#/' $mafFile | awk '/^s chr1/ {if (NR > 2) print a[(NR+1)%3]; print a[(NR+2)%3]; print; getline; print; getline; print; next} {a[NR%3] = $0}' > $mafFile_chr

# make $qryAnnoFile_chr
qryAnnoFile=$5
qryAnnoFile_chr="${qryAnnoFile:0:-4}_$chrName"
awk -v pat="^$chrName" '$0~pat' $qryAnnoFile > $qryAnnoFile_chr

refAnnoFile=$6

# make directories for outputs
mkdir $OUTDIRPATH

mkdir "$OUTDIRPATH/sameGeneRef"
mkdir "$OUTDIRPATH/sameGeneRef/MAF"
mkdir "$OUTDIRPATH/sameGeneRef/PNG"

mkdir "$OUTDIRPATH/diffGeneRef_icldNoGene"
mkdir "$OUTDIRPATH/diffGeneRef_icldNoGene/MAF"
mkdir "$OUTDIRPATH/diffGeneRef_icldNoGene/PNG"

mkdir "$OUTDIRPATH/diffGeneRef_noNoGene"
mkdir "$OUTDIRPATH/diffGeneRef_noNoGene/MAF"
mkdir "$OUTDIRPATH/diffGeneRef_noNoGene/PNG"

mkdir "$OUTDIRPATH/allNoGeneRef"
mkdir "$OUTDIRPATH/allNoGeneRef/MAF"
mkdir "$OUTDIRPATH/allNoGeneRef/PNG"

python ctgrzByQryAnno.py $mafFile_chr $qryAnnoFile_chr $refAnnoFile $OUTDIRPATH
