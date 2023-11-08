"""
* Assuming no overlapped segments on the query
Categorize aligned segments based on query's annotation.
Input:
    - .maf file
    - .gff file of the query
    - .gff file of the reference
    - output dir path

Output:
    .maf files under directories below:
        - sameGeneQry_allNoGeneRef
        - sameGeneQry_sameGeneRef
        - sameGeneQry_diffGeneRef_wtNoGene
        - sameGeneQry_diffGeneRef_pure
"""
import argparse
from collections import namedtuple as nt
from Util import setToPlusCoord
from Util import getAln
from Util import noOverlap, meetAtPoint
from Util import plusStrandStart, plusStrandEnd


def overlap(alnCoord, annoCoord):
    """
    If query's coord overlap with annotation line,
    return True
    * alnCoord is + strand coord
    """
    chr1 = alnCoord.chr
    a1 = alnCoord.beg
    b1 = alnCoord.end
    chr2 = annoCoord.chr
    a2 = annoCoord.beg
    b2 = annoCoord.end
    if chr1 == chr2:
        if not noOverlap(chr1, a1, b1, chr2, a2, b2) and not meetAtPoint(
            chr1, a1, b1, chr2, a2, b2
        ):
            return True
        else:
            return False
    else:
        return False


def geneID_alnList_dict(alnFile, annoFile_Qry):
    alnFileHandle = open(alnFile)
    with open(annoFile_Qry) as f:
        annoLines = f.readlines()

    AnnoCoord = nt("AnnoCoord", ["chr", "beg", "end"])
    AlnCoord = nt("AlnCoord", ["chr", "beg", "end"])  # + strand coord
    geneID_alnList = {}
    for aln in getAln(alnFileHandle):
        for line in annoLines:
            fields = line.rstrip().split("\t")
            feature = fields[2]  # gene, mRNA, CDS, intron, etc.
            if feature == "CDS":
                chrName = fields[0]  # chr1, chr2, etc.
                beg = int(fields[3]) - 1  # from 1-base to inbetween coord
                end = int(fields[4])
                annoCoord = AnnoCoord(chrName, beg, end)
                attr = fields[8]
                parts = attr.rstrip(";").split(";")
                attrDict = dict([(p.split("=")[0], p.split("=")[1]) for p in parts])
                geneID = ".".join(attrDict["ID"].split(".")[-4:-2])
                alnBegPlus, alnEndPlus = setToPlusCoord(aln)
                alnCoord = AlnCoord(aln.rID, alnBegPlus, alnEndPlus)
                if overlap(alnCoord, annoCoord):
                    geneID_alnList[geneID] = geneID_alnList.get(geneID, []).append(aln)
                else:
                    pass
            else:
                pass
    return geneID_alnList


def aln_geneID_dict(alnFile, annoFile_Ref):
    alnFileHandle = open(alnFile)
    with open(annoFile_Ref) as f:
        annoLines = f.readlines()

    AnnoCoord = nt("AnnoCoord", ["chr", "beg", "end"])
    AlnCoord = nt("AlnCoord", ["chr", "beg", "end"])  # + strand coord
    aln_refGeneID_dict = {}
    for aln in getAln(alnFileHandle):
        flag = False
        for line in annoLines:
            fields = line.rstrip().split("\t")
            feature = fields[2]  # gene, mRNA, CDS, intron, etc.
            if feature == "CDS":
                chrName = fields[0]  # chr1, chr2, etc.
                beg = int(fields[3]) - 1  # from 1-base to inbetween coord
                end = int(fields[4])
                annoCoord = AnnoCoord(chrName, beg, end)
                attr = fields[8]
                parts = attr.rstrip(";").split(";")
                attrDict = dict([(p.split("=")[0], p.split("=")[1]) for p in parts])
                geneID = attrDict["gene"]
                # Assuming all ref coords are on the + strand
                alnCoord = AlnCoord(aln.gChr, aln.gStart, aln.gEnd)
                if overlap(alnCoord, annoCoord):
                    flag = True
                    aln_refGeneID_dict[aln] = aln_refGeneID_dict.get(aln, set()).add(
                        geneID
                    )
                else:
                    pass
            else:
                pass
        if not flag:
            aln_refGeneID_dict[aln] = aln_refGeneID_dict.get(aln, set()).add(None)
        else:
            pass


def refCategory(alnGroup, aln_geneID_dict):
    for aln in alnGroup:
        geneIDset = aln_geneID_dict[aln]
        if None not in geneIDset and len(geneIDset) == 1:
            return "sameGene"
        elif len(geneIDset) > 1 and None in geneIDset:
            return "diffGene_icldNoGene"
        elif len(geneIDset) > 1 and None not in geneIDset:
            return "diffGene_noNoGene"
        elif None in geneIDset and len(geneIDset) == 1:
            return "allNoGene"
        else:
            raise Exception("len(geneIDset): " + str(len(geneIDset)))


def setName(alnGroup):
    alnGroup.sort(key=lambda a: (a.rID, plusStrandStart(a), plusStrandEnd(a)))
    firstAlnStart = plusStrandStart(alnGroup[0])
    lastAlnEnd = plusStrandEnd(alnGroup[-1])
    fileName = (
        alnGroup[0].rID + "_" + str(firstAlnStart) + "-" + str(lastAlnEnd) + ".maf"
    )
    return fileName


def writeMAFs(alnGroup, outMAFDirPath, fileName):
    with open(outMAFDirPath + "/" + fileName, "w") as f:
        for aln in alnGroup:
            f.write(aln._MAF())


def outputMAFandDotplotFiles(alnFile, annoFile_Qry, annoFile_Ref, outRootDirPath):
    qryGeneID_alnList_dict = geneID_alnList_dict(alnFile, annoFile_Qry)
    aln_refGeneID_dict = aln_geneID_dict(alnFile, annoFile_Ref)

    for alnGroup in qryGeneID_alnList_dict.values():
        if len(alnGroup) > 1:
            try:
                refCTGR = refCategory(alnGroup, aln_refGeneID_dict)
            except:
                print("Other category")

            fileName = setName(alnGroup)
            if refCTGR == "sameGene":
                outMAFDirPath = outRootDirPath + "/sameGeneRef/MAF"
            elif refCTGR == "diffGene_icldNoGene":
                outMAFDirPath = outRootDirPath + "/diffGeneRef_icldNoGene/MAF"
            elif refCTGR == "diffGene_noNoGene":
                outMAFDirPath = outRootDirPath + "/diffGeneRef_noNoGene/MAF"
            else:  # refCTGR == "allNoGene"
                outMAFDirPath = outRootDirPath + "/allNoGeneRef/MAF"
            writeMAFs(alnGroup, outMAFDirPath, fileName)
        else:
            pass


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
