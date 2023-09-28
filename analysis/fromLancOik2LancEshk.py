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
from Util import getAln


def start(aln):
    """
    return reference's start coordinate
    """
    return (aln.gChr, aln.gStart)


def end(aln):
    """
    return reference's end coordinate
    """
    return (aln.gChr, aln.gEnd)


def noOverlap(aln1, aln2):
    """
    compare reference coordinates
    check if they don't overlap at all
    """
    if aln1.gChr == aln2.gChr:
        s1 = (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)
        s2 = (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)
        if s1 > 0 and s2 > 0:
            return True
        else:
            return False
    else:
        return False


def meetAtPoint(aln1, aln2):
    """
    compare reference coordinates
    check if they meet at a point
    """
    if aln1.gChr == aln2.gChr:
        s1 = (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)
        s2 = (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)
        if s1 > 0 and s2 == 0:
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
        s1 = (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)
        s2 = (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)
        if s1 == 0 and s2 < 0:
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
        s1 = (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)
        s2 = (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)
        if s1 <= 0 and s2 < 0:
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
        s1 = (aln1.gStart - aln2.gStart) * (aln1.gEnd - aln2.gEnd)
        s2 = (aln1.gStart - aln2.gEnd) * (aln1.gEnd - aln2.gStart)
        if s1 > 0 and s2 <= 0:
            return True
        else:
            return False
    else:
        return False


def main(oneOik2lancAlignmentFile, esh2lancAlignmentFile, outputDir):
    oik2lancAlnFileHandle = open(oneOik2lancAlignmentFile)
    esh2lancAlnFileHandle = open(esh2lancAlignmentFile)

    oik2lancAlns = []
    for aln in getAln(oik2lancAlnFileHandle):
        oik2lancAlns.append(aln)

    # sort oik2lancAlns by reference's coordinates
    # assuming ref's strand is always "+"
    oik2lancAlns.sort(key=lambda a: (a.gChr, a.gStart, a.gEnd))

    esh2lancAlns = []
    i = 0
    for esh2lanc in getAln(esh2lancAlnFileHandle):
        if i < len(oik2lancAlns) and (
            noOverlap(esh2lanc, oik2lancAlns[i])
            or meetAtPoint(esh2lanc, oik2lancAlns[i])
        ):
            continue
        elif i < len(oik2lancAlns) and (
            exactMatch(esh2lanc, oik2lancAlns[i])
            or oneIncludesTheOther(esh2lanc, oik2lancAlns[i])
            or overlap(esh2lanc, oik2lancAlns[i])
        ):
            esh2lancAlns.append(esh2lanc)
        elif i < len(oik2lancAlns):
            i += 1
        else:
            break


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "oneOik2lancAlignementFile",
        help="an alignment .maf file of oik-to-lanc \
                        (a group of maf entries close to each other on oik)",
    )
    parser.add_argument(
        "esh2lancAlignmentFile",
        help="a whole alignment .maf file of cmil-to-lanc \
                                sorted by lanc's coordinates",
    )
    parser.add_argument("outputDir", help="a path of outputDirectory")
    args = parser.parse_args()
    """
    MAIN
    """
    main(args.oneOik2lancAlignmentFile, args.esh2lancAlignmentFile, args.outputDir)
