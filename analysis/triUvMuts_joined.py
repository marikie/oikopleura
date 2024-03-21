"""
Input:
    - a 3-genome joined alignment .maf file
    - outputFilePath
Output:
    - a tsv file with the following columns:
        - trinucleotides of genome 1
        - trinucleotides of genome 2
        - trinucleotides of genome 3
        - mutation type
"""
import argparse
import csv
from Util import getJoinedAlignmentObj

parser = argparse.ArgumentParser()
parser.add_argument("joinedAlignmentFile", help="a 3-genome joined alignment .maf file")
parser.add_argument(
    "outputFilePath",
    help="a tsv file with the following columns: trinucleotides of genome 1, trinucleotides of genome 2, trinucleotides of genome 3, mutation type (96 types)",
)
args = parser.parse_args()
joinedAlnFile = args.joinedAlignmentFile
outputFilePath = args.outputFilePath
alnFileHandle = open(joinedAlnFile)

# initialize output file
with open(outputFilePath, "w") as tsvfile:
    writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
    writer.writerow(["g1Tri", "g2Tri", "g3Tri", "mutation_type"])


def isMut(g1Tri, g2Tri, g3Tri):
    if not (
        (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0])
        and (g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2])
    ):
        return False
    middleSet = set([g1Tri[1], g2Tri[1], g3Tri[1]])
    if len(middleSet) == 2:
        return True
    else:
        return False


def getMutType(g1Tri, g2Tri, g3Tri):
    assert (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    ), "edge bases are not the same"

    bindDict = {"A": "T", "T": "A", "C": "G", "G": "C"}
    middleList = [g1Tri[1], g2Tri[1], g3Tri[1]]
    majority = ""
    minority = ""

    for base in set(middleList):
        if middleList.count(base) == 2:
            majority = base
        elif middleList.count(base) == 1:
            minority = base
        else:
            raise (Exception)

    if majority not in set(["C", "T"]):
        mutType = (
            bindDict[g1Tri[0]]
            + "["
            + bindDict[majority]
            + ">"
            + bindDict[minority]
            + "]"
            + bindDict[g1Tri[2]]
        )
    else:
        mutType = g1Tri[0] + "[" + majority + ">" + minority + "]" + g1Tri[2]

    return mutType


for aln in getJoinedAlignmentObj(alnFileHandle):
    gSeq1 = aln.gSeq1.upper()
    gSeq2 = aln.gSeq2.upper()
    gSeq3 = aln.gSeq3.upper()
    assert (
        len(gSeq1) == len(gSeq2)
        and len(gSeq1) == len(gSeq3)
        and len(gSeq2) == len(gSeq3)
    ), "gSeq1, gSeq2, and gSeq3 should have the same length"
    for i in range(len(gSeq1) - 2):
        g1Tri = gSeq1[i : i + 3]
        g2Tri = gSeq2[i : i + 3]
        g3Tri = gSeq3[i : i + 3]
        if not (
            all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g1Tri)))
            and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g2Tri)))
            and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g3Tri)))
        ):
            continue
        elif isMut(g1Tri, g2Tri, g3Tri):
            mutType = getMutType(g1Tri, g2Tri, g3Tri)
            with open(outputFilePath, "a") as tsvfile:
                writer = csv.writer(tsvfile, delimiter="\t")
                writer.writerow([g1Tri, g2Tri, g3Tri, mutType])
        else:
            continue

alnFileHandle.close()
