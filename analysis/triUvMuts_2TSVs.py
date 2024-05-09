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


def getMutTypeList(g1Tri, g2Tri, g3Tri):
    assert (g1Tri[0] == g2Tri[0] and g2Tri[0] == g3Tri[0]) and (
        g1Tri[2] == g2Tri[2] and g2Tri[2] == g3Tri[2]
    ), "edge bases are not the same"

    mutTypeList = []
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

    # minority > majority or majority > minority
    if g1Tri[1] == minority:
        # minority > majority
        if minority in set(["C", "T"]):
            mutTypeList.append(mutType(g1Tri, minority, majority))
        else:
            mutTypeList.append(revMutType(g1Tri, minority, majority))

        # majority > minority
        if majority in set(["C", "T"]):
            mutTypeList.append(mutType(g1Tri, majority, minority))
        else:
            mutTypeList.append(revMutType(g1Tri, majority, minority))

    # majority > minority
    else:
        if majority in set(["C", "T"]):
            mutTypeList.append(mutType(g1Tri, majority, minority))
        else:
            mutTypeList.append(revMutType(g1Tri, majority, minority))

    return mutTypeList


def ori(mutType):
    return mutType[0] + mutType[2] + mutType[6]


def add2totalNum(mutDict, g1Tri, g2Tri, g3Tri):
    assert noMut(g1Tri, g2Tri, g3Tri), "not a noMut"

    if g1Tri[1] == "A" or g1Tri[1] == "G":
        triNuc = rev(g1Tri)
    else:
        triNuc = g1Tri

    for key in mutDict.keys():
        if ori(key) == triNuc:
            mutDict[key]["totalRootNum"] += 1


def add2MutDict(mutDict, mutTypeList):
    if len(mutTypeList) == 1:
        mutDict[mutTypeList[0]]["mutNum"] += 1
        mutDict[mutTypeList[0]]["totalRootNum"] += 1
    else:
        mutDict[mutTypeList[0]]["mutNum"] += 0.5
        mutDict[mutTypeList[1]]["mutNum"] += 0.5
        mutDict[mutTypeList[0]]["totalRootNum"] += 0.5
        mutDict[mutTypeList[1]]["totalRootNum"] += 0.5


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

###################
# main procedures
###################
def main(alnFileHandle, outputFilePath1, outputFilePath2):
    mutDict1 = initialize_mut_dict()
    mutDict2 = initialize_mut_dict()

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
            elif noMut(g1Tri, g2Tri, g3Tri):
                add2totalNum(mutDict, g1Tri, g2Tri, g3Tri)
            elif isMut(g1Tri, g2Tri, g3Tri):
                try:
                    mutTypeList = getMutTypeList(g1Tri, g2Tri, g3Tri)
                    add2MutDict(mutDict, mutTypeList)
                except Exception:
                    print("g1Tri, g2Tri, g3Tri: ", g1Tri, g2Tri, g3Tri)
            else:
                continue

    alnFileHandle.close()

    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["mutType", "mutNum", "totalRootNum"])
        mutTypeList = sorted(list(mutDict.keys()), key=lambda x: (x[2], x[4], x[0], x[6] ))
        for mutType in mutTypeList:
            writer.writerow(
                [
                    mutType,
                    mutDict[mutType]["mutNum"],
                    mutDict[mutType]["totalRootNum"],
                ]
            )


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
        "outputFilePath1",
        help="a tsv file1 with the following columns: mutation type (96 types), the num of mutation, the total num of the original trinucleotides",
    )
    parser.add_argument(
        "outputFilePath2",
        help="a tsv file with the following columns: mutation type (96 types), the num of mutation, the total num of the original trinucleotides",
    )
    args = parser.parse_args()
    joinedAlnFile = args.joinedAlignmentFile
    outputFilePath1 = args.outputFilePath1
    outputFilePath2 = args.outputFilePath2
    alnFileHandle = open(joinedAlnFile)

    ###################
    # test
    ###################
    # alnFileHandle = open(
    #     "/Users/nakagawamariko/biohazard/data/oikAlb_oikDio_oikVan/test_joined.maf"
    # )
    # outputFilePath = (
    #     "/Users/nakagawamariko/biohazard/data/oikAlb_oikDio_oikVan/test_20240410.tsv"
    # )

    ###################
    # main
    ###################
    main(alnFileHandle, outputFilePath1, outputFilePath2)
