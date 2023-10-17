"""
* Assuming no overlapped segments on the query
Categorize aligned segments based on query's annotation.
Input:
    - .maf file sorted by query's + strand coord

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


def getSameGeneGroup(sortedAlnFile, annoFile_Qry, annoFile_Ref):
    """
    Assuming sortedAlnFile is already sorted by query's + strand coord
    """
    alnFileHandle = open(sortedAlnFile)

    prvGene = None
    sameGeneGroup = []
    for currAln in getAln(alnFileHandle):
        currGene = getGene(currAln, annoFile_Qry)
        if prvGene == currGene:
            # prvGene == currGene == None
            if prvGene == None:
                # do nothing
                pass
            # prvGene == currGene == geneA
            else:
                # add currAln
                sameGeneGroup.append(currAln)
                # no need to update prvGene
        # prvGene != currGene
        else:
            # prvGene == None, currGene == geneA
            if prvGene == None:
                # add currAln
                sameGeneGroup.append(currAln)
                # update prvGene
                prvGene = currGene
            # prvGene == geneA, currGene == None
            elif currGene == None:
                if len(sameGeneGroup) > 1:
                    yield sameGeneGroup
                else:
                    # do not yield
                    pass
                # reset sameGeneGroup
                sameGeneGroup = []
                # do not add currAln
                # update prvGene
                prvGene = currGene
            # prvGene == geneA, currGene == geneB
            else:
                if len(sameGeneGroup) > 1:
                    yield sameGeneGroup
                else:
                    # do not yield
                    pass
                # reset sameGeneGroup and add currAln
                sameGeneGroup = [currAln]
                # update prvGene
                prvGene = currGene


def outputMAFandDotplotFiles(sortedAlnFile, annoFile_Qry, annoFile_Ref, outRootDirPath):
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
    parser.add_argument(
        "sortedAlnFile",
        help="a .maf alignment file \
                                sorted by query + strand coordinates",
    )
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
        args.sortedAlnFile, args.annoFile_Qry, args.annoFile_Ref, args.outputDirPath
    )
