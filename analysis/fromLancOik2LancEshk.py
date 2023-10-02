"""
Input:
    - an alignment .maf file of oik-to-lanc
      (close to each other on oik)
    - a whole alignment .maf file of cmil-to-lanc
      sorted by lanc's coord
Output:
    - a .maf file of cmil-to-lanc where lanc's coord
      overlap with that of input's oik-to-lanc 
"""
import argparse
import subprocess
from Util import getAln
from Util import setToPlusCoord


def s1(aln1, aln2):
    return (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)


def s2(aln1, aln2):
    return (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)


def noOverlap(aln1, aln2):
    """
    compare reference coordinates
    check if they don't overlap at all
    """
    if aln1.gChr == aln2.gChr:
        if s1(aln1, aln2) > 0 and s2(aln1, aln2) > 0:
            return True
        else:
            return False
    else:
        return True


def meetAtPoint(aln1, aln2):
    """
    compare reference coordinates
    check if they meet at a point
    """
    if aln1.gChr == aln2.gChr:
        if s1(aln1, aln2) > 0 and s2(aln1, aln2) == 0:
            return True
        else:
            return False
    else:
        return False


def exactMatch(aln1, aln2):
    """
    compare reference coordinates
    check if they match exactly
    """
    if aln1.gChr == aln2.gChr:
        if s1(aln1, aln2) == 0 and s2(aln1, aln2) < 0:
            return True
        else:
            return False
    else:
        return False


def oneIncludesTheOther(aln1, aln2):
    """
    compare reference coordinates
    check if one includes the other
    """
    if aln1.gChr == aln2.gChr:
        if s1(aln1, aln2) <= 0 and s2(aln1, aln2) < 0:
            return True
        else:
            return False
    else:
        return False


def overlap(aln1, aln2):
    """
    compare reference coordinates
    check if they overlap
    """
    if aln1.gChr == aln2.gChr:
        if s1(aln1, aln2) > 0 and s2(aln1, aln2) <= 0:
            return True
        else:
            return False
    else:
        return False


def main(oneOik2lancAlignmentFile, esh2lancAlignmentFile, outputDirPath):
    oik2lancAlnFileHandle = open(oneOik2lancAlignmentFile)
    esh2lancAlnFileHandle = open(esh2lancAlignmentFile)

    oik2lancAlns = []
    for aln in getAln(oik2lancAlnFileHandle):
        oik2lancAlns.append(aln)
        # print(aln._MAF())

    # sort oik2lancAlns by reference's coordinates
    # assuming ref's strand is always "+"
    oik2lancAlns.sort(key=lambda a: (a.gChr, a.gStart, a.gEnd))

    esh2lancAlns = []
    i = 0
    for j, esh2lanc in enumerate(getAln(esh2lancAlnFileHandle)):
        # print(esh2lanc._MAF())
        if i < len(oik2lancAlns) and (
            noOverlap(esh2lanc, oik2lancAlns[i])
            or meetAtPoint(esh2lanc, oik2lancAlns[i])
        ):
            # print("j = ", j)
            # print("noOverlap, meetAtPoint")
            continue
        elif i < len(oik2lancAlns) and (
            exactMatch(esh2lanc, oik2lancAlns[i])
            or oneIncludesTheOther(esh2lanc, oik2lancAlns[i])
            or overlap(esh2lanc, oik2lancAlns[i])
        ):
            # print("exactMatch, oneIncludesTheOther, overlap")
            esh2lancAlns.append(esh2lanc)
        elif i < len(oik2lancAlns):
            # print(esh2lanc._MAF())
            # print(oik2lancAlns[i]._MAF())
            # print("i = ", i)
            # print("i += 1")
            i += 1
        else:
            break

    if len(esh2lancAlns) > 0:
        # output to a .maf file
        p1 = subprocess.run(["ls", outputDirPath], capture_output=True)
        if p1.returncode != 0:
            subprocess.run(["mkdir", outputDirPath])
            subprocess.run(["mkdir", outputDirPath + "/MAF"])
        else:
            pass

        # convet to + strand coord
        firstElemStart = setToPlusCoord(oik2lancAlns[0])[0]
        # print('firstStart: ', firstElemStart)
        lastElemEnd = setToPlusCoord(oik2lancAlns[-1])[1]
        # print('lastEnd: ', lastElemEnd)
        mafFileName = (
            oik2lancAlns[0].rID
            + "_"
            + str(firstElemStart)
            + "-"
            + str(lastElemEnd)
            + ".maf"
        )

        with open(outputDirPath + "/MAF/" + mafFileName, "w") as f:
            for aln in esh2lancAlns:
                f.write(aln._MAF())
    else:
        pass


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "oneOik2lancAlignmentFile",
        help="an alignment .maf file of oik-to-lanc \
                        (a group of maf entries close to each other on oik)",
    )
    parser.add_argument(
        "esh2lancAlignmentFile_sorted",
        help="a whole alignment .maf file of cmil-to-lanc \
                                SORTED by lanc's coordinates",
    )
    parser.add_argument("outputDirPath", help="a path of outputDirectory")
    args = parser.parse_args()
    """
    MAIN
    """
    main(
        args.oneOik2lancAlignmentFile,
        args.esh2lancAlignmentFile_sorted,
        args.outputDirPath,
    )
