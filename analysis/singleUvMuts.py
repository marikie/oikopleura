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
        "A": {"count": 0, "type": "no_mutation", "ctgr": "TtoT/AtoA"},
        "C": {"count": 0, "type": "transversion", "ctgr": "TtoG/AtoC"},
        "G": {"count": 0, "type": "transition", "ctgr": "TtoC/AtoG"},
        "T": {"count": 0, "type": "transversion", "ctgr": "TtoA/AtoT"},
        "-": {"count": 0, "type": "deletion", "ctgr": "Tto-/Ato-"},
    },
    "C": {
        "A": {"count": 0, "type": "transversion", "ctgr": "CtoA/GtoT"},
        "C": {"count": 0, "type": "no_mutation", "ctgr": "CtoC/GtoG"},
        "G": {"count": 0, "type": "transversion", "ctgr": "CtoG/GtoC"},
        "T": {"count": 0, "type": "transition", "ctgr": "CtoT/GtoA"},
        "-": {"count": 0, "type": "deletion", "ctgr": "Cto-/Gto-"},
    },
    "G": {
        "A": {"count": 0, "type": "transition", "ctgr": "CtoT/GtoA"},
        "C": {"count": 0, "type": "transversion", "ctgr": "CtoG/GtoC"},
        "G": {"count": 0, "type": "no_mutation", "ctgr": "CtoC/GtoG"},
        "T": {"count": 0, "type": "transversion", "ctgr": "CtoA/GtoT"},
        "-": {"count": 0, "type": "deletion", "ctgr": "Cto-/Gto-"},
    },
    "T": {
        "A": {"count": 0, "type": "transversion", "ctgr": "TtoA/AtoT"},
        "C": {"count": 0, "type": "transition", "ctgr": "TtoC/AtoG"},
        "G": {"count": 0, "type": "transversion", "ctgr": "TtoG/AtoC"},
        "T": {"count": 0, "type": "no_mutation", "ctgr": "TtoT/AtoA"},
        "-": {"count": 0, "type": "deletion", "ctgr": "Tto-/Ato-"},
    },
    "-": {
        "A": {"count": 0, "type": "insertion", "ctgr": "-toA/-toT"},
        "C": {"count": 0, "type": "insertion", "ctgr": "-toC/-toG"},
        "G": {"count": 0, "type": "insertion", "ctgr": "-toC/-toG"},
        "T": {"count": 0, "type": "insertion", "ctgr": "-toA/-toT"},
    },
}

for aln in getAlignmentObjsOneByOne(alnFileHandle):
    rSeq = aln.gSeq.upper()
    qSeq = aln.rSeq.upper()
    assert len(rSeq) == len(qSeq), "rSeq and qSeq have different lengths"
    for rbase, qbase in zip(rSeq, qSeq):
        if rbase not in mutationDict:
            mutationDict[rbase] = {}
        if qbase not in mutationDict[rbase]:
            mutationDict[rbase][qbase] = {
                "count": 0,
                "type": "exception",
                "ctgr": "exception",
            }
        mutationDict[rbase][qbase]["count"] += 1
alnFileHandle.close()

# how to write to a file
with open(outputFilePath, "w") as f:
    writer = csv.writer(f, delimiter="\t", lineterminator="\n")
    # how to write a header
    writer.writerow(["refBase", "qryBase", "count", "type", "category"])
    for origBase, mutDict in mutationDict.items():
        for mutBase, info in mutDict.items():
            writer.writerow(
                [origBase, mutBase, info["count"], info["type"], info["ctgr"]]
            )
