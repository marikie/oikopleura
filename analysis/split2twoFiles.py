"""
Input:
	- a tsv file with 15 columns about trinucleotide substitutions of 3 species
	- outputFilePathB
	- outputFilePathC

Output:
	- two tsv files with 7 columns (speciesB and speciesC)
"""

import argparse
import csv
from Util import bothEdgeBasesSame


def isSpcB(trinucA, trinucB, trinucC):
    assert bothEdgeBasesSame(
        trinucA, trinucB, trinucC
    ), "trinucA, trinucB, trinucC are not valid"
    if trinucA[1] == trinucC[1] and trinucB[1] != trinucA[1]:
        return True
    else:
        return False


def isSpcC(trinucA, trinucB, trinucC):
    assert bothEdgeBasesSame(
        trinucA, trinucB, trinucC
    ), "trinucA, trinucB, trinucC are not valid"
    if trinucA[1] == trinucB[1] and trinucC[1] != trinucA[1]:
        return True
    else:
        return False


revDict = {"A": "T", "T": "A", "C": "G", "G": "C"}


def sbstType(trinuc, majority, minority):
    if majority in set(["A", "G"]):
        return (
            revDict[trinuc[2]]
            + "["
            + revDict[majority]
            + ">"
            + revDict[minority]
            + "]"
            + revDict[trinuc[0]]
        )
    else:
        return trinuc[0] + "[" + majority + ">" + minority + "]" + trinuc[2]


def getSbstSig(trinucA, trinucB, trinucC):
    assert bothEdgeBasesSame(
        trinucA, trinucB, trinucC
    ), f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC} are not valid"
    assert (
        len(set([trinucA[1], trinucB[1], trinucC[1]])) == 2
    ), f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC} are not valid"

    middleList = [trinucA[1], trinucB[1], trinucC[1]]
    for base in set(middleList):
        if middleList.count(base) == 2:
            majority = base
        elif middleList.count(base) == 1:
            minority = base
        else:
            raise Exception(
                f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC} are not valid"
            )
    if trinucA[1] == minority:
        raise Exception(
            f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC} are not valid"
        )
    elif trinucB[1] == minority:
        return sbstType(trinucB, majority, minority)
    elif trinucC[1] == minority:
        return sbstType(trinucC, majority, minority)
    else:
        raise Exception(
            f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC} are not valid"
        )


def main(tsv3spcFilePath, outputFilePathB, outputFilePathC):
    spcBFileHandle = open(outputFilePathB, "w")
    spcBwriter = csv.writer(spcBFileHandle, delimiter="\t", lineterminator="\n")
    spcCFileHandle = open(outputFilePathC, "w")
    spcCwriter = csv.writer(spcCFileHandle, delimiter="\t", lineterminator="\n")
    spcBwriter.writerow(
        ["#", "chrB", "startB", "endB", "name", "score", "strandB", "sbstSig"]
    )
    spcCwriter.writerow(
        ["#", "chrC", "startC", "endC", "name", "score", "strandC", "sbstSig"]
    )
    with open(tsv3spcFilePath, "r") as tsv3spcFileHandle:
        tsv3spcReader = csv.DictReader(tsv3spcFileHandle, delimiter="\t")

        for row in tsv3spcReader:
            # Access columns by name
            trinucA = row["trinucA"]
            chrB = row["chrB"]
            startB = row["startB"]
            endB = row["endB"]
            strandB = row["strandB"]
            trinucB = row["trinucB"]
            chrC = row["chrC"]
            startC = row["startC"]
            endC = row["endC"]
            strandC = row["strandC"]
            trinucC = row["trinucC"]

            if isSpcB(trinucA, trinucB, trinucC):
                try:
                    sbstSig = getSbstSig(trinucA, trinucB, trinucC)
                except Exception as e:
                    print(f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC}")
                    raise e
                spcBwriter.writerow([chrB, startB, endB, ".", ".", strandB, sbstSig])
            elif isSpcC(trinucA, trinucB, trinucC):
                try:
                    sbstSig = getSbstSig(trinucA, trinucB, trinucC)
                except Exception as e:
                    print(f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC}")
                    raise e
                spcCwriter.writerow([chrC, startC, endC, ".", ".", strandC, sbstSig])
            else:
                print(f"trinucA: {trinucA}, trinucB: {trinucB}, trinucC: {trinucC}")
                raise Exception("trinucA, trinucB, trinucC are not valid")

    spcBFileHandle.close()
    spcCFileHandle.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "tsv3spcFilePath",
        help="a tsv file with 15 columns about trinucleotide substitutions of 3 species",
    )
    parser.add_argument("outputFilePathB", help="a tsv file with 7 columns (speciesB)")
    parser.add_argument("outputFilePathC", help="a tsv file with 7 columns (speciesC)")
    args = parser.parse_args()

    main(args.tsv3spcFilePath, args.outputFilePathB, args.outputFilePathC)
