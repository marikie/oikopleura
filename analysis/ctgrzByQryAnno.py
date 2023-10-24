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


def geneID_alnList_dict(alnFile, annoFile_Qry):
    alnFileHandle = open(alnFile)
    annoFile_QryHandle = open(annoFile_Qry)
    geneID_alnList = {}
    for aln in getAln(alnFileHandle):
        for line in annoFile_QryHandle:
            fields = line.rstrip().split("\t")
            feature = fields[2]  # gene, mRNA, CDS, intron, etc.
            if feature == "CDS":
                chrName = fields[0]  # chr1, chr2, etc.
                beg = int(fields[3]) - 1  # from 1-base to inbetween coord
                end = int(fields[4])
                attr = fields[8]
                if ";" in attr or "=" in attr:
                    parts = attr.rstrip(";").split(";")
                    attrDict = dict([(p.split("=")[0], p.split("=")[1]) for p in parts])
                    geneID = attrDict["ID"].split(".")
                if overlap(aln, (chrName, beg, end)):
                    geneID_alnList[geneID] = geneID_alnList.get(geneID, []).append(aln)
                else:
                    pass


def outputMAFandDotplotFiles(alnFile, annoFile_Qry, annoFile_Ref, outRootDirPath):
    geneID_alnList = geneID_alnList_dict(alnFile, annoFile_Qry)

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
