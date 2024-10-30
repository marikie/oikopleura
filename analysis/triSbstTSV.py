"""
Input:
    - a 3-genome joined alignment .maf file
    - outputFilePath
Output:
    - a TSV file
        - chromosome A
        - start A (in-between coord of + strand)
        - end A
        - strand A
        - trinuc A
        - chromosome B
        - start B (in-between coord of + strand)
        - end B
        - strand B
        - trinuc B
        - chromosome C
        - start C (in-between coord of + strand)
        - end C
        - strand C
        - trinuc C
"""

import argparse
import csv
from Util import getJoinedAlignmentObj


def bothEdgeBasesSame(g1Tri, g2Tri, g3Tri):
    return (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    )


def getPlusStrandStart(coord, gLength, gStrand):
    if gStrand == "+":
        return coord
    else:
        minusEnd = coord + 1
        plusStart = gLength - minusEnd
        return plusStart


def isSbst(g1Tri, g2Tri, g3Tri):
    """
    If the substitution happened only on genome2, return True.
    If the substitution happened only on genome3, return True.
    Otherwise, return False.
    """
    assert (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    ), "edge bases are not the same (not a mutational signature)"

    middleList = [g1Tri[1], g2Tri[1], g3Tri[1]]
    minority = ""
    if len(set(middleList)) == 2:
        for base in set(middleList):
            if middleList.count(base) == 1:
                minority = base
        if g2Tri[1] == minority or g3Tri[1] == minority:
            return True
        else:
            return False
    else:
        return False


def write2TSV(aln, i, g1Tri, g2Tri, g3Tri, writer):
    gStart1 = getPlusStrandStart(aln.gStart1, aln.gLength1, aln.gStrand1)
    gStart2 = getPlusStrandStart(aln.gStart2, aln.gLength2, aln.gStrand2)
    gStart3 = getPlusStrandStart(aln.gStart3, aln.gLength3, aln.gStrand3)
    writer.writerow(
        [
            aln.gChr1,
            gStart1 + i,
            gStart1 + i + 1,
            aln.gStrand1,
            g1Tri,
            aln.gChr2,
            gStart2 + i,
            gStart2 + i + 1,
            aln.gStrand2,
            g2Tri,
            aln.gChr3,
            gStart3 + i,
            gStart3 + i + 1,
            aln.gStrand3,
            g3Tri,
        ]
    )


def main(alnFileHandle, outputFilePath):
    outFileHandle = open(outputFilePath, "w")
    writer = csv.writer(outFileHandle, delimiter="\t", lineterminator="\n")
    writer.writerow(
        [
            "chrA",
            "startA",
            "endA",
            "strandA",
            "trinucA",
            "chrB",
            "startB",
            "endB",
            "strandB",
            "trinucB",
            "chrC",
            "startC",
            "endC",
            "strandC",
            "trinucC",
        ]
    )
    for aln in getJoinedAlignmentObj(alnFileHandle):
        gSeq1 = aln.gSeq1.upper()
        gSeq2 = aln.gSeq2.upper()
        gSeq3 = aln.gSeq3.upper()

        for i in range(len(gSeq1) - 2):
            g1Tri = gSeq1[i : i + 3]
            g2Tri = gSeq2[i : i + 3]
            g3Tri = gSeq3[i : i + 3]
            # if all trinucs are the same, go next
            if g1Tri == g2Tri == g3Tri:
                continue
            # if indels are included, go next
            elif not (
                all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g1Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g2Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g3Tri)))
            ):
                continue
            # if there are no indels,
            # and the edge bases are the same,
            # and can consider it as a substitution
            # write to TSV
            elif bothEdgeBasesSame(g1Tri, g2Tri, g3Tri) and isSbst(g1Tri, g2Tri, g3Tri):
                write2TSV(aln, i, g1Tri, g2Tri, g3Tri, writer)
            # if there are no indels,
            # but edge bases are not all the same,
            # or it's not a substitution,
            # go next
            else:
                continue

    alnFileHandle.close()
    outFileHandle.close()


if __name__ == "__main__":
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "joinedAlignmentFile", help="a 3-genome joined alignment .maf file"
    )
    parser.add_argument("outputFilePath", help="a path for the output tsv file")
    args = parser.parse_args()

    alnFileHandle = open(args.joinedAlignmentFile)
    # main
    main(alnFileHandle, args.outputFilePath)
