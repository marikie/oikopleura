"""
Input:
    - a 3-genome joined alignment .maf file
      (the top sequence should be the outgroup)
    - outputFilePath1
    - outputFilePath2
Output:
    - two tsv files with the following columns:
                - substitution type
                - sbstNum
                - oriNum
    - two bed files with the following columns:
                [Species B]				 [Species C]
                - chrB					 - chrC
                - startB				 - startC
                - endB					 - endC
                - name					 - name
                - score				 	 - score
                - strandB				 - strandC
                - trinucB				 - trinucC
                - sbst					 - sbst
                - chrA					 - chrA
                - startA				 - startA
                - endA					 - endA
                - strandA				 - strandA
                - trinucA				 - trinucA
                - chrC					 - chrB
                - startC				 - startB
                - endC					 - endB
                - strandC				 - strandB
                - trinucC				 - trinucB
"""

import argparse
import csv
import os
from Util import getJoinedAlignmentObj

oriDict = {
    "ACA": ["ACAA", "ACAG", "ACAT"],
    "ACC": ["ACCA", "ACCG", "ACCT"],
    "ACG": ["ACGA", "ACGG", "ACGT"],
    "ACT": ["ACTA", "ACTG", "ACTT"],
    "CCA": ["CCAA", "CCAG", "CCAT"],
    "CCC": ["CCCA", "CCCG", "CCCT"],
    "CCG": ["CCGA", "CCGG", "CCGT"],
    "CCT": ["CCTA", "CCTG", "CCTT"],
    "GCA": ["GCAA", "GCAG", "GCAT"],
    "GCC": ["GCCA", "GCCG", "GCCT"],
    "GCG": ["GCGA", "GCGG", "GCGT"],
    "GCT": ["GCTA", "GCTG", "GCTT"],
    "TCA": ["TCAA", "TCAG", "TCAT"],
    "TCC": ["TCCA", "TCCG", "TCCT"],
    "TCG": ["TCGA", "TCGG", "TCGT"],
    "TCT": ["TCTA", "TCTG", "TCTT"],
    "ATA": ["ATAA", "ATAC", "ATAG"],
    "ATC": ["ATCA", "ATCC", "ATCG"],
    "ATG": ["ATGA", "ATGC", "ATGG"],
    "ATT": ["ATTA", "ATTC", "ATTG"],
    "CTA": ["CTAA", "CTAC", "CTAG"],
    "CTC": ["CTCA", "CTCC", "CTCG"],
    "CTG": ["CTGA", "CTGC", "CTGG"],
    "CTT": ["CTTA", "CTTC", "CTTG"],
    "GTA": ["GTAA", "GTAC", "GTAG"],
    "GTC": ["GTCA", "GTCC", "GTCG"],
    "GTG": ["GTGA", "GTGC", "GTGG"],
    "GTT": ["GTTA", "GTTC", "GTTG"],
    "TTA": ["TTAA", "TTAC", "TTAG"],
    "TTC": ["TTCA", "TTCC", "TTCG"],
    "TTG": ["TTGA", "TTGC", "TTGG"],
    "TTT": ["TTTA", "TTTC", "TTTG"],
}


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


def sbstType(gTri, ori, sbst):
    if ori in set(["C", "T"]):
        return gTri[0] + ori + gTri[2] + sbst
    else:
        return revDict[gTri[2]] + revDict[ori] + revDict[gTri[0]] + revDict[sbst]


# ACTG -> ACT
# ACGG -> ACG
def ori(sbstType):
    return sbstType[0:3]


def add2totalNum(sbstDict, triNuc):
    if triNuc[1] == "A" or triNuc[1] == "G":
        oriNuc = rev(triNuc)
    else:
        oriNuc = triNuc

    for sbstType in oriDict[oriNuc]:
        sbstDict[sbstType]["totalRootNum"] += 1


def add2DictList(g1Tri, g2Tri, g3Tri, sbstDict2, sbstDict3, recList2, recList3):
    """
    If the middle bases are all different to each other,
    do nothing.
    If the substitution happened on genome2,
    add the substitution count to sbstDict2 (N[majority > minority]N),
    add the total count to sbstDict2 (N(majority)N),
    and add the total count to sbstDict3 (N(majority)N).
    If the substitution happened on genome3,
    add the substitution count to sbstDict3 (N[majority > minority]N),
    add the total count to sbstDict3 (N(majority)N),
    and add the total count to sbstDict2 (N(majority)N).
    If the substitution happend on genome1,
    do nothing.
    """
    # print("add2sbstDict called")
    # print("g1Tri: ", g1Tri)
    # print("g2Tri: ", g2Tri)
    # print("g3Tri: ", g3Tri)

    middleList = [g1Tri[1], g2Tri[1], g3Tri[1]]
    majority = ""
    minority = ""
    # print("middleList: ", middleList)
    # print("set(middleList): ", set(middleList))

    if len(set(middleList)) == 1:
        # only original count
        add2totalNum(sbstDict2, g1Tri)
        add2totalNum(sbstDict3, g1Tri)
    # if there is a substitution on org1, org2, or org3
    elif len(set(middleList)) == 2:
        for base in set(middleList):
            if middleList.count(base) == 2:
                majority = base
            elif middleList.count(base) == 1:
                minority = base
            else:
                raise (Exception)
        # print("majority: ", majority, "minority: ", minority)
        # if the substitution is on org1
        # ambiguous: minority > majority or majority > minority
        if g1Tri[1] == minority:
            # print("g1Tri[1] == minority")
            pass
        # if the substitution is on org2
        # majority > minority on sbstDict2
        elif g2Tri[1] == minority:
            # print("g2Tri[1] == minority")
            # substitution count
            # print(
            #     "sbstType(g2Tri, majority, minority): ",
            #     sbstType(g2Tri, majority, minority),
            # )
            sbstDict2[sbstType(g2Tri, majority, minority)]["sbstNum"] += 1
            # total count (original is g1Tri) to sbstDict2 and sbstDict3
            add2totalNum(sbstDict2, g1Tri)
            add2totalNum(sbstDict3, g1Tri)
            recList2.append(SbstRecord(g1Tri, g2Tri, g3Tri))
        # if the substitution is on org3
        # majority > minority on sbstDict3
        elif g3Tri[1] == minority:
            # print("g3Tri[1] == minority")
            # substitution count
            sbstDict3[sbstType(g3Tri, majority, minority)]["sbstNum"] += 1
            # total count (original is g1Tri) to sbstDict2 and sbstDict3
            add2totalNum(sbstDict2, g1Tri)
            add2totalNum(sbstDict3, g1Tri)


def initialize_sbst_dict():
    """
    key: sbstType (e.g. ACGA which means ACG -> AAG)
    value: {
        "sbstNum": 0,
        "oriNum": 0
    }
    """
    sbstDict = {}
    letters = ["A", "C", "G", "T"]
    midLetters = ["C", "T"]
    cSubs = ["A", "G", "T"]
    tSubs = ["A", "C", "G"]
    for i in letters:
        for j in midLetters:
            if j == "C":
                for k in cSubs:
                    for l in letters:
                        sbstType = i + j + l + k
                        sbstDict[sbstType] = {"sbstNum": 0, "oriNum": 0}
            if j == "T":
                for k in tSubs:
                    for l in letters:
                        sbstType = i + j + l + k
                        sbstDict[sbstType] = {"sbstNum": 0, "oriNum": 0}
    return sbstDict


def write_tsv_file(outputFilePath, sbstDict):
    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["sbstType", "sbstNum", "oriNum"])
        sbstTypeList = sorted(
            list(sbstDict.keys()), key=lambda x: (x[1], x[3], x[0], x[2])
        )
        for sbstType in sbstTypeList:
            writer.writerow(
                [
                    sbstType[0]
                    + "["
                    + sbstType[1]
                    + ">"
                    + sbstType[3]
                    + "]"
                    + sbstType[2],
                    sbstDict[sbstType]["sbstNum"],
                    sbstDict[sbstType]["oriNum"],
                ]
            )


###################
# main procedures
###################
def main(
    alnFileHandle,
    outputTsvFilePath2,
    outputTsvFilePath3,
    outputBedFilePath2,
    outputBedFilePath3,
):
    sbstDict2 = initialize_sbst_dict()
    sbstDict3 = initialize_sbst_dict()
    # print("sbstDict2: ", len(sbstDict2.keys()))
    recList2 = []
    recList3 = []
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
            # if not all (i in "ACGT" for i in gTri)
            if not (
                all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g1Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g2Tri)))
                and all(list(map(lambda b: b in set(["A", "C", "G", "T"]), g3Tri)))
            ):
                continue
            # if there are no indels
            # and the edge bases are the same,
            # count original trinucs as total and count substitutions if there is a substitution
            if bothEdgeBasesSame(g1Tri, g2Tri, g3Tri):
                add2DictList(
                    g1Tri, g2Tri, g3Tri, sbstDict2, sbstDict3, recList2, recList3
                )

    alnFileHandle.close()

    # write to outputFilePath2
    write_tsv_file(outputTsvFilePath2, sbstDict2)
    # write to outputFilePath3
    write_tsv_file(outputTsvFilePath3, sbstDict3)


def get_default_output_file_names(joinedAlnFile):
    # file name without extension
    filename = os.path.splitext(os.path.basename(joinedAlnFile))[0]
    # Get the path before the filename at the end
    path_before_filename = os.path.dirname(joinedAlnFile)

    filename_parts = filename.split("_")
    if len(filename_parts) < 3:
        raise ValueError("The file name should be org1_org2_org3_*.maf")
    org2 = filename_parts[1]
    org3 = filename_parts[2]
    rest = "_".join(filename_parts[3:])
    if rest == "":
        otFile2 = f"{org2}.tsv"
        otFile3 = f"{org3}.tsv"
        obFile2 = f"{org2}.bed"
        obFile3 = f"{org3}.bed"
    else:
        otFile2 = f"{org2}_{rest}.tsv"
        otFile3 = f"{org3}_{rest}.tsv"
        obFile2 = f"{org2}_{rest}.bed"
        obFile3 = f"{org3}_{rest}.bed"
    ot2 = os.path.join(path_before_filename, otFile2)
    ot3 = os.path.join(path_before_filename, otFile3)
    ob2 = os.path.join(path_before_filename, obFile2)
    ob3 = os.path.join(path_before_filename, obFile3)

    return ot2, ot3, ob2, ob3


if __name__ == "__main__":
    ###################
    # parse arguments
    ###################
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "joinedAlignmentFile",
        help="a 3-genome joined alignment .maf file (the top sequence should be the outgroup), the file name should be org1_org2_org3_*.maf",
    )
    parser.add_argument(
        "-ot2",
        "--outputTsvFilePath2",
        help="output tsv file path for organism2",
    )
    parser.add_argument(
        "-ot3",
        "--outputTsvFilePath3",
        help="output tsv file path for organism3",
    )
    parser.add_argument(
        "-ob2",
        "--outputBedFilePath2",
        help="output bed file path for organism2",
    )
    parser.add_argument(
        "-ob3",
        "--outputBedFilePath3",
        help="output bed file path for organism3",
    )
    args = parser.parse_args()
    joinedAlnFile = args.joinedAlignmentFile
    outputTsvFilePath2 = (
        args.outputTsvFilePath2 or get_default_output_file_names(joinedAlnFile)[0]
    )
    outputTsvFilePath3 = (
        args.outputTsvFilePath3 or get_default_output_file_names(joinedAlnFile)[1]
    )
    outputBedFilePath2 = (
        args.outputBedFilePath2 or get_default_output_file_names(joinedAlnFile)[2]
    )
    outputBedFilePath3 = (
        args.outputBedFilePath3 or get_default_output_file_names(joinedAlnFile)[3]
    )

    # print(f"joinedAlnFile: {joinedAlnFile}")
    # print(f"outputFilePath2: {outputFilePath2}")
    # print(f"outputFilePath3: {outputFilePath3}")
    # exit(1)

    ###################
    # main
    ###################
    alnFileHandle = open(joinedAlnFile)
    main(
        alnFileHandle,
        outputTsvFilePath2,
        outputTsvFilePath3,
        outputBedFilePath2,
        outputBedFilePath3,
    )
