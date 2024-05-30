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
def isMutSig(g1Tri, g2Tri, g3Tri):
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


def noMut(g1Tri, g2Tri, g3Tri):
    if (
        (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0])
        and (g1Tri[1] == g2Tri[1] and g2Tri[1] == g3Tri[1])
        and (g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2])
    ):
        return True
    else:
        return False


revDict = {"A": "T", "T": "A", "C": "G", "G": "C"}


def rev(triNuc):
    return revDict[triNuc[2]] + revDict[triNuc[1]] + revDict[triNuc[0]]


def mutType(gTri, ori, mut):
    return gTri[0] + "[" + ori + ">" + mut + "]" + gTri[2]


def revMutType(gTri, ori, mut):
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
    assert (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    ), "edge bases are not the same (not a mutational signature)"

    middleList = [g1Tri[1], g2Tri[1], g3Tri[1]]
    majority = ""
    minority = ""

    if set(middleList) == 3:
        # do nothing
        pass
    else:
        for base in set(middleList):
            if middleList.count(base) == 2:
                majority = base
            elif middleList.count(base) == 1:
                minority = base
            else:
                raise (Exception)

        # ambiguous: minority > majority or majority > minority
        if g1Tri[1] == minority:
            pass
        # majority > minority on mutDict2
        elif g2Tri[1] == minority:
            if majority in set(["C", "T"]):
                # mutation count
                mutDict2[mutType(g2Tri, majority, minority)]["mutNum"] += 1
                # total count (original is g1Tri)
                add2totalNum(mutDict2, g1Tri)
                add2totalNum(mutDict3, g1Tri)
            else:
                # mutation count
                mutDict2[revMutType(g2Tri, majority, minority)]["mutNum"] += 1
                # total count (original is rev(g1Tri))
                add2totalNum(mutDict2, rev(g1Tri))
                add2totalNum(mutDict3, rev(g1Tri))
        # majority > minority on mutDict3
        elif g3Tri[1] == minority:
            if majority in set(["C", "T"]):
                # mutation count
                mutDict3[mutType(g3Tri, majority, minority)]["mutNum"] += 1
                # total count (original is g1Tri)
                add2totalNum(mutDict2, g1Tri)
                add2totalNum(mutDict3, g1Tri)
            else:
                # mutation count
                mutDict3[revMutType(g3Tri, majority, minority)]["mutNum"] += 1
                # total count (original is rev(g1Tri))
                add2totalNum(mutDict2, rev(g1Tri))
                add2totalNum(mutDict3, rev(g1Tri))


def initialize_mut_dict():
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
            # and there are no substitution,
            # count as total num to both of mutDicts
            elif noMut(g1Tri, g2Tri, g3Tri):
                add2totalNum(mutDict2, g1Tri)
                add2totalNum(mutDict3, g1Tri)
            # if its a mutational signature
            # count as mutation and add the count of the original trinuc as total
            elif isMutSig(g1Tri, g2Tri, g3Tri):
                try:
                    add2MutDict(g1Tri, g2Tri, g3Tri, mutDict2, mutDict3)
                except Exception:
                    print("g1Tri, g2Tri, g3Tri: ", g1Tri, g2Tri, g3Tri)
            # if there are no indels, and there are mutations
            # but not a mutational signature,
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

    ###################
    # test
    ###################
    # alnFileHandle = open(
    #     "/Users/nakagawamariko/biohazard/data/oikAlb_oikDio_oikVan/test_joined.maf"
    # )
    # outputFilePath = (
    #     "/Users/nakagawamariko/biohazard/data/oikAlb_oikDio_oikVan/test_20240410.tsv"
    # )
