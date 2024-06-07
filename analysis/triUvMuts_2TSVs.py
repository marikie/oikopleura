"""
Input:
    - a 3-genome joined alignment .maf file
      (the top sequence should be the outgroup)
    - outputFilePath1
    - outputFilePath2
Output:
    - two tsv files with the following columns:
        - mutation type
        - mutNum
        - totalRootNum
"""

import argparse
import csv
from Util import getJoinedAlignmentObj


#############
# functions
#############
def bothEdgeBasesSame(g1Tri, g2Tri, g3Tri):
    return (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    )


revDict = {"A": "T", "T": "A", "C": "G", "G": "C"}


def rev(triNuc):
    return revDict[triNuc[2]] + revDict[triNuc[1]] + revDict[triNuc[0]]


def mutType(gTri, ori, mut):
    if ori in set(["C", "T"]):
        return gTri[0] + "[" + ori + ">" + mut + "]" + gTri[2]
    else:
        return (
            revDict[gTri[2]]
            + "["
            + revDict[ori]
            + ">"
            + revDict[mut]
            + "]"
            + revDict[gTri[0]]
        )


def ori(mutType):
    return mutType[0] + mutType[2] + mutType[6]


def add2totalNum(mutDict, triNuc):
    if triNuc[1] == "A" or triNuc[1] == "G":
        oriNuc = rev(triNuc)
    else:
        oriNuc = triNuc

    for key in mutDict.keys():
        if ori(key) == oriNuc:
            mutDict[key]["totalRootNum"] += 1


def add2MutDict(g1Tri, g2Tri, g3Tri, mutDict2, mutDict3):
    """
    If the middle bases are all different to each other,
    do nothing.
    If the mutation happened on genome2,
    add the mutation count to mutDict2 (N[majority > minority]N),
    add the total count to mutDict2 (N(majority)N),
    and add the total count to mutDict3 (N(majority)N).
    If the mutation happened on genome3,
    add the mutation count to mutDict3 (N[majority > minority]N),
    add the total count to mutDict3 (N(majority)N),
    and add the total count to mutDict2 (N(majority)N).
    If the mutation happend on genome1,
    do nothing.
    """
    # print("add2MutDict called")
    # print("g1Tri: ", g1Tri)
    # print("g2Tri: ", g2Tri)
    # print("g3Tri: ", g3Tri)
    assert (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    ), "edge bases are not the same (not a mutational signature)"

    middleList = [g1Tri[1], g2Tri[1], g3Tri[1]]
    majority = ""
    minority = ""
    # print("middleList: ", middleList)
    # print("set(middleList): ", set(middleList))

    if len(set(middleList)) == 1:
        # only original count
        add2totalNum(mutDict2, g1Tri)
        add2totalNum(mutDict3, g1Tri)
    # if there is a mutation on org1, org2, or org3
    elif len(set(middleList)) == 2:
        for base in set(middleList):
            if middleList.count(base) == 2:
                majority = base
            elif middleList.count(base) == 1:
                minority = base
            else:
                raise (Exception)
        # print("majority: ", majority, "minority: ", minority)
        # if the mutation is on org1
        # ambiguous: minority > majority or majority > minority
        if g1Tri[1] == minority:
            # print("g1Tri[1] == minority")
            pass
        # if the mutation is on org2
        # majority > minority on mutDict2
        elif g2Tri[1] == minority:
            # print("g2Tri[1] == minority")
            # mutation count
            # print(
            #     "mutType(g2Tri, majority, minority): ",
            #     mutType(g2Tri, majority, minority),
            # )
            mutDict2[mutType(g2Tri, majority, minority)]["mutNum"] += 1
            # total count (original is g1Tri) to mutDict2 and mutDict3
            add2totalNum(mutDict2, g1Tri)
            add2totalNum(mutDict3, g1Tri)
        # if the mutation is on org3
        # majority > minority on mutDict3
        elif g3Tri[1] == minority:
            # print("g3Tri[1] == minority")
            # mutation count
            mutDict3[mutType(g3Tri, majority, minority)]["mutNum"] += 1
            # total count (original is g1Tri) to mutDict2 and mutDict3
            add2totalNum(mutDict2, g1Tri)
            add2totalNum(mutDict3, g1Tri)
    # if the middle bases are all different
    # set(middleList) == 3
    else:
        # do nothing
        pass


def initialize_mut_dict():
    """
    key: mutType (e.g. A[C>A]G)
    value: {
        "mutNum": 0,
        "totalRootNum": 0
    }
    """
    mutDict = {}
    letters = ["A", "C", "G", "T"]
    conversion = ["C>A", "C>G", "C>T", "T>A", "T>C", "T>G"]
    for i in range(len(letters)):
        for j in range(len(conversion)):
            for k in range(len(letters)):
                mtype = letters[i] + "[" + conversion[j] + "]" + letters[k]
                if mtype not in mutDict:
                    mutDict[mtype] = {}
                mutDict[mtype]["mutNum"] = 0
                mutDict[mtype]["totalRootNum"] = 0
    return mutDict


def write_output_file(outputFilePath, mutDict):
    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["mutType", "mutNum", "totalRootNum"])
        mutTypeList = sorted(
            list(mutDict.keys()), key=lambda x: (x[2], x[4], x[0], x[6])
        )
        for mutType in mutTypeList:
            writer.writerow(
                [
                    mutType,
                    mutDict[mutType]["mutNum"],
                    mutDict[mutType]["totalRootNum"],
                ]
            )


###################
# main procedures
###################
def main(alnFileHandle, outputFilePath2, outputFilePath3):
    mutDict2 = initialize_mut_dict()
    mutDict3 = initialize_mut_dict()

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
            # if indels are included, go next
            if not (
                all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g1Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g2Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g3Tri)))
            ):
                continue
            # if there are no indels
            # and the edge bases are the same,
            # count original trinucs as total and count mutations if there is a mutation
            elif bothEdgeBasesSame(g1Tri, g2Tri, g3Tri):
                add2MutDict(g1Tri, g2Tri, g3Tri, mutDict2, mutDict3)
            # if there are no indels,
            # but edge bases are not all the same,
            # go next
            else:
                continue

    alnFileHandle.close()

    # write to outputFilePath2
    write_output_file(outputFilePath2, mutDict2)
    # write to outputFilePath3
    write_output_file(outputFilePath3, mutDict3)


if __name__ == "__main__":
    ###################
    # parse arguments
    ###################
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "joinedAlignmentFile",
        help="a 3-genome joined alignment .maf file (the top sequence should be the outgroup)",
    )
    parser.add_argument(
        "outputFilePath2",
        help="a tsv file2 of genome2 with the following columns: mutation type (96 types), the num of mutation, the total num of the original trinucleotides",
    )
    parser.add_argument(
        "outputFilePath3",
        help="a tsv file3 of genome3 with the following columns: mutation type (96 types), the num of mutation, the total num of the original trinucleotides",
    )
    args = parser.parse_args()
    joinedAlnFile = args.joinedAlignmentFile
    outputFilePath2 = args.outputFilePath2
    outputFilePath3 = args.outputFilePath3
    alnFileHandle = open(joinedAlnFile)

    ###################
    # main
    ###################
    main(alnFileHandle, outputFilePath2, outputFilePath3)
