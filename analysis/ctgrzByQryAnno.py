"""
* Assuming no overlapped segments on the query
Categorize aligned segments based on query's annotation.
Input:
    - .maf file
    - .gff file of the query
    - .gff file of the reference
    - output dir path

Output:
    - sameGeneQry_allNoGeneRef
    - sameGeneQry_sameGeneRef
    - sameGeneQry_diffGeneRef_wtNoGene
    - sameGeneQry_diffGeneRef_pure
    (- Others) !! This is supposed to be empty
"""
import argparse
from Util import setToPlusCoord
from Util import getAln


def writeMAFandPNG(outMAFDirPath, outPNGDirPath, fileBasename):
    pass


def outputMAFandDotplotFiles(alnFile, annoFile_Qry, annoFile_Ref, outRootDirPath):
    alnFileHandle = open(alnFile)
    annoFile_QryHandle = open(annoFile_Qry)

    geneID_alnList = {}
    for aln in getAln(alnFileHandle):
        for line in annoFile_QryHandle:
            if overlap(aln, line):
                geneID_alnList[geneID] = geneID_alnList.get(geneID, []).append(aln)

    for sameGeneGroup, genesOnRef in getSameGeneGroup(sortedAlnFile, annoFile_Qry):
        firstElmStart = setToPlusCoord(sameGeneGroup[0])[0]
        lastElmEnd = setToPlusCoord(sameGeneGroup[-1])[1]
        # file name without extention
        fileBasename = (
            sameGeneGroup[0].rID + "-" + str(firstElmStart) + "-" + str(lastElmEnd)
        )
        if genesOnRef == "allNoGene":
            outMAFDirPath = outRootDirPath + "/sameGeneQry_allNoGeneRef/MAF"
            outPNGDirPath = outRootDirPath + "/sameGeneQry_allNoGeneRef/PNG"
        elif genesOnRef == "sameGene":
            outMAFDirPath = outRootDirPath + "/sameGeneQry_sameGeneRef/MAF"
            outPNGDirPath = outRootDirPath + "/sameGeneQry_sameGeneRef/PNG"
        elif genesOnRef == "diffGene_wtNoGene":
            outMAFDirPath = outRootDirPath + "/sameGeneQry_diffGeneRef_wtNoGene/MAF"
            outPNGDirPath = outRootDirPath + "/sameGeneQry_diffGeneRef_wtNoGene/PNG"
        elif genesOnRef == "diffGene_pure":
            outMAFDirPath = outRootDirPath + "/sameGeneQry_diffGeneRef_pure/MAF"
            outPNGDirPath = outRootDirPath + "/sameGeneQry_diffGeneRef_pure/PNG"
        else:
            outMAFDirPath = outRootDirPath + "/Others/MAF"
            outPNGDirPath = outRootDirPath + "/Others/PNG"
        writeMAFandPNG(outMAFDirPath, outPNGDirPath, fileBasename)


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("alnFile", help="a .maf alignment file")
    parser.add_argument(
        "annoFile_Qry",
        help="an annotation file for the 2nd \
                                (vertical) genome (query)",
    )
    parser.add_argument(
        "annoFile_Ref",
        help="an annotation file for the 1st \
                                (horizontal) genome (reference)",
    )
    parser.add_argument("outputDirPath", help="path of the output directory")
    args = parser.parse_args()
    """
    MAIN
    """
    outputMAFandDotplotFiles(
        args.alnFile, args.annoFile_Qry, args.annoFile_Ref, args.outputDirPath
    )
