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
import os
from Util import getAln
from Util import setToPlusCoord


def start(aln):
    return (aln.gChr, aln.gStart)


def end(aln):
    return (aln.gChr, aln.gEnd)


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

    print("loading oik2lancAlns")
    oik2lancAlns = []
    for aln in getAln(oik2lancAlnFileHandle):
        oik2lancAlns.append(aln)
        # print(aln._MAF())
    # sort oik2lancAlns by reference's coordinates
    # assuming ref's strand is always "+"
    oik2lancAlns.sort(key=lambda a: (a.gChr, a.gStart, a.gEnd))

    print("loading esh2lancAlns")
    # ! assuming esh2lancAlignmentFile is already SORTED !
    esh2lancAlns = []
    for aln in getAln(esh2lancAlnFileHandle):
        esh2lancAlns.append(aln)

    esh2lancAlns_toMAF = []
    j = 0
    for i in range(len(oik2lancAlns)):
        while j < len(esh2lancAlns) and end(esh2lancAlns[j]) <= start(oik2lancAlns[i]):
            # print("FIRST WHILE")
            # print("i = ", i)
            # print("j = ", j)
            # print("eshark")
            # print(esh2lancAlns[j]._MAF())
            # print("oik")
            # print(oik2lancAlns[i]._MAF())
            j += 1
        k = j
        while k < len(esh2lancAlns) and start(esh2lancAlns[k]) < end(oik2lancAlns[i]):
            if (
                exactMatch(esh2lancAlns[k], oik2lancAlns[i])
                or oneIncludesTheOther(esh2lancAlns[k], oik2lancAlns[i])
                or overlap(esh2lancAlns[k], oik2lancAlns[i])
            ):
                # print("OVERLAP")
                # print("i = ", i)
                # print("j = ", j)
                # print("k = ", k)
                # print("eshark")
                # print(esh2lancAlns[j]._MAF())
                # print("oik")
                # print(oik2lancAlns[i]._MAF())
                esh2lancAlns_toMAF.append(esh2lancAlns[k])
            else:
                raise Exception("no overlap")
            k += 1

    if len(esh2lancAlns_toMAF) > 0:
        # output to a .maf file
        p1 = subprocess.run(["ls", outputDirPath], capture_output=True)
        if p1.returncode != 0:
            subprocess.run(["mkdir", outputDirPath])
            subprocess.run(["mkdir", outputDirPath + "/MAF"])
        else:
            pass

        # # convet to + strand coord
        # firstElemStart = setToPlusCoord(oik2lancAlns[0])[0]
        # # print('firstStart: ', firstElemStart)
        # lastElemEnd = setToPlusCoord(oik2lancAlns[-1])[1]
        # # print('lastEnd: ', lastElemEnd)
        # mafFileName = (
        #     oik2lancAlns[0].rID
        #     + "_"
        #     + str(firstElemStart)
        #     + "-"
        #     + str(lastElemEnd)
        #     + ".maf"
        # )
        mafFileName = os.path.basename(oneOik2lancAlignmentFile)

        with open(outputDirPath + "/MAF/" + mafFileName, "w") as f:
            for aln in esh2lancAlns_toMAF:
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
