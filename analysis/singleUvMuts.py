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

if __name__ == "__main__":
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
            "C": [0, "transversion"],
            "G": [0, "transition"],
            "T": [0, "transversion"],
        },
        "C": {
            "A": [0, "transversion"],
            "G": [0, "transversion"],
            "T": [0, "transition"],
        },
        "G": {
            "A": [0, "transversion"],
            "C": [0, "transversion"],
            "T": [0, "transversion"],
        },
        "T": {
            "A": [0, "transversion"],
            "C": [0, "transition"],
            "G": [0, "transversion"],
        },
    }
    for aln in getAlignmentObjsOneByOne(alnFileHandle):
        rSeq = aln.gSeq.upper()
        qSeq = aln.rSeq.upper()
        assert len(rSeq) == len(qSeq), "rSeq and qSeq have different lengths"
        for rbase, qbase in zip(rSeq, qSeq):
            if rbase != "-" and qbase != "-":
                if rbase != qbase:
                    mutationDict[rbase][qbase][0] += 1
    alnFileHandle.close()

    # how to write to a file
    with open(outputFilePath, "w") as f:
        writer = csv.writer(f, delimiter="\t", lineterminator="\n")
        for origBase, mutDict in mutationDict.items():
            for mutBase, info in mutDict.items():
                writer.writerow([origBase, mutBase, info[0], info[1]])
