"""
Input:
    - a fasta file of a reference genome
    - an output file path
Output:
    - a tsv file with the number of trinucleotides in the entire genome
"""

import argparse
import csv
from Bio import SeqIO
from Util import rev


def initialize_trinuc_dict():
    """
    key: trinuc (ACA, ACC, ...)
    value: num
    """
    trinucDict = {}
    letters = ["A", "C", "G", "T"]
    middle_letters = ["C", "T"]
    for i in range(len(letters)):
        for j in range(len(middle_letters)):
            for k in range(len(letters)):
                trinuc = letters[i] + middle_letters[j] + letters[k]
                if trinuc not in trinucDict:
                    trinucDict[trinuc] = 0
    return trinucDict


def conv(trinuc):
    if trinuc[1] == "C" or trinuc[1] == "T":
        return trinuc
    else:
        return rev(trinuc)


def main(fastaFile, outputFilePath):
    trinucDict = initialize_trinuc_dict()
    for record in SeqIO.parse(fastaFile, "fasta"):
        seq = record.seq
        for i in range(len(seq) - 2):
            trinuc = seq[i : i + 3]
            trinuc = conv(trinuc)
            trinucDict[trinuc] += 1
    with open(outputFilePath, "w") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow(["trinuc", "num"])
        trinucList = sorted(trinucDict.keys())
        for trinuc in trinucList:
            writer.writerow([trinuc, trinucDict[trinuc]])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("fastaFile", help="a fasta file of a reference genome")
    parser.add_argument("outputFilePath", help="an output file path")
    args = parser.parse_args()
    """
    MAIN
    """
    main(args.fastaFile, args.outputFilePath)
