"""
Input:
    - an alignment .maf file
    - outputFilePath
Output:
    - a tsv file with the following columns:
    - original trinucleotides
    - mutated trinucleotides
    - mutation type (96 types)
"""
import argparse
from Util import getAlignmentObjsOneByOne
import csv

parser = argparse.ArgumentParser()
parser.add_argument("alignmentFile", help="an alignment .maf file")
parser.add_argument(
    "outputFilePath",
    help="a tsv file with the following columns: original trinucleotides, mutated trinucleotides, mutation type (96 types)",
)
args = parser.parse_args()
alignmentFile = args.alignmentFile
outputFilePath = args.outputFilePath
alnFileHandle = open(alignmentFile)

# how to initialize output file
with open(outputFilePath, "w") as tsvfile:
    writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
    writer.writerow(["refTri", "qryTri", "mutType"])


def getMutType(rTri, qTri):
    bindDict = {"A": "T", "T": "A", "C": "G", "G": "C"}
    rTri_type = ""
    qTri_type = ""
    if rTri[1] not in set(["C", "T"]):
        rTri_type = bindDict[rTri[0]] + bindDict[rTri[1]] + bindDict[rTri[2]]
        qTri_type = bindDict[qTri[0]] + bindDict[qTri[1]] + bindDict[qTri[2]]
    else:
        rTri_type = rTri
        qTri_type = qTri
    assert (
        rTri_type[0] == qTri_type[0] and rTri_type[2] == qTri_type[2]
    ), "edge bases are not the same"
    mutType = (
        rTri_type[0] + "[" + rTri_type[1] + ">" + qTri_type[1] + "]" + rTri_type[2]
    )
    return mutType


for aln in getAlignmentObjsOneByOne(alnFileHandle):
    rSeq = aln.gSeq.upper()
    qSeq = aln.rSeq.upper()
    assert len(rSeq) == len(qSeq), "rSeq and qSeq have different lengths"
    for i in range(len(rSeq) - 2):
        rTri = rSeq[i : i + 3]
        qTri = qSeq[i : i + 3]
        if not (
            all(list(map(lambda b: b in set(["A", "C", "G", "T"]), rTri)))
            and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), qTri)))
        ):
            continue
        elif rTri[0] == qTri[0] and rTri[2] == qTri[2] and rTri[1] != qTri[1]:
            mutType = getMutType(rTri, qTri)
            with open(outputFilePath, "a") as tsvfile:
                writer = csv.writer(tsvfile, delimiter="\t")
                writer.writerow([rTri, qTri, mutType])
        else:
            continue

alnFileHandle.close()
