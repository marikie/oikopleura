"""
Input: 
    - an alignment .maf file
Output:
    - a tsv file with the following columns:
        - original base
        - mutated base
        - the number of such mutations
        - mutation type (transition or transversion)
"""
import argparse
from Util import getAlignmentObjsOneByOne
import csv

parser = argparse.ArgumentParser()
parser.add_argument("alignmentFile", help="an alignment .maf file")
parser.add_argument(
    "outputFilePath",
    help="a tsv file with the following columns: original base, mutated base, the number of such mutations, mutation type (transition or transversion)",
)
args = parser.parse_args()
alignmentFile = args.alignmentFile
outputFilePath = args.outputFilePath
alnFileHandle = open(alignmentFile)

mutationDict = {
    "A": {
        "A": {"count": 0, "type": "no_mutation"},
        "C": {"count": 0, "type": "transversion"},
        "G": {"count": 0, "type": "transition"},
        "T": {"count": 0, "type": "transversion"},
        "-": {"count": 0, "type": "deletion"},
    },
    "C": {
        "A": {"count": 0, "type": "transversion"},
        "C": {"count": 0, "type": "no_mutation"},
        "G": {"count": 0, "type": "transversion"},
        "T": {"count": 0, "type": "transition"},
        "-": {"count": 0, "type": "deletion"},
    },
    "G": {
        "A": {"count": 0, "type": "transversion"},
        "C": {"count": 0, "type": "transversion"},
        "G": {"count": 0, "type": "no_mutation"},
        "T": {"count": 0, "type": "transversion"},
        "-": {"count": 0, "type": "deletion"},
    },
    "T": {
        "A": {"count": 0, "type": "transversion"},
        "C": {"count": 0, "type": "transition"},
        "G": {"count": 0, "type": "transversion"},
        "T": {"count": 0, "type": "no_mutation"},
        "-": {"count": 0, "type": "deletion"},
    },
    "-": {
        "A": {"count": 0, "type": "insertion"},
        "C": {"count": 0, "type": "insertion"},
        "G": {"count": 0, "type": "insertion"},
        "T": {"count": 0, "type": "insertion"},
    },
}

for aln in getAlignmentObjsOneByOne(alnFileHandle):
    rSeq = aln.gSeq.upper()
    qSeq = aln.rSeq.upper()
    assert len(rSeq) == len(qSeq), "rSeq and qSeq have different lengths"
    for rbase, qbase in zip(rSeq, qSeq):
        mutationDict[rbase][qbase]["count"] += 1
alnFileHandle.close()

# how to write to a file
with open(outputFilePath, "w") as f:
    writer = csv.writer(f, delimiter="\t", lineterminator="\n")
    # how to write a header
    writer.writerow(["refBase", "qryBase", "count", "type"])
    for origBase, mutDict in mutationDict.items():
        for mutBase, info in mutDict.items():
            writer.writerow([origBase, mutBase, info["count"], info["type"]])
