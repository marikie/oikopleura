"""
Input:
    - a 3-genome joined alignment .maf file
      (the top sequence should be the outgroup)
    - outputFilePath1
    - outputFilePath2
Output:
    - two tsv files with the following columns:
                - mutType
                - mutNum
                - totalRootNum
    - two bed files with the following columns:
                [Species B]				 [Species C]
                - chrB					 - chrC
                - startB				 - startC
                - endB					 - endC
                - name					 - name
                - score				 	 - score
                - strandB				 - strandC
                - trinucB				 - trinucC
                - mutType				 - mutType
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


def mutType(gTri, ori, mut):
    if ori in set(["C", "T"]):
        return gTri[0] + ori + gTri[2] + mut
    else:
        return revDict[gTri[2]] + revDict[ori] + revDict[gTri[0]] + revDict[mut]


# ACTG -> ACT
# ACGG -> ACG
def ori(mutType):
    return mutType[0:3]


def add2totalNum(mutDict, triNuc):
    if triNuc[1] == "A" or triNuc[1] == "G":
        oriNuc = rev(triNuc)
    else:
        oriNuc = triNuc

    for mutType in oriDict[oriNuc]:
        mutDict[mutType]["totalRootNum"] += 1


def add2DictList(g1Tri, g2Tri, g3Tri, mutDict2, mutDict3):
    """
    If the middle bases are all different to each other,
    do nothing.
    If the substitution happened on genome2,
    add the substitution count to mutDict2 (N[majority > minority]N),
    add the total count to mutDict2 (N(majority)N),
    and add the total count to mutDict3 (N(majority)N).
    If the substitution happened on genome3,
    add the substitution count to mutDict3 (N[majority > minority]N),
    add the total count to mutDict3 (N(majority)N),
    and add the total count to mutDict2 (N(majority)N).
    If the substitution happend on genome1,
    do nothing.
    """
    # print("add2mutDict called")
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
        add2totalNum(mutDict2, g1Tri)
        add2totalNum(mutDict3, g1Tri)
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
        # majority > minority on mutDict2
        elif g2Tri[1] == minority:
            # print("g2Tri[1] == minority")
            # substitution count
            # print(
            #     "mutType(g2Tri, majority, minority): ",
            #     mutType(g2Tri, majority, minority),
            # )
            mutDict2[mutType(g2Tri, majority, minority)]["mutNum"] += 1
            # total count (original is g1Tri) to mutDict2 and mutDict3
            add2totalNum(mutDict2, g1Tri)
            add2totalNum(mutDict3, g1Tri)
        # if the substitution is on org3
        # majority > minority on mutDict3
        elif g3Tri[1] == minority:
            # print("g3Tri[1] == minority")
            # substitution count
            mutDict3[mutType(g3Tri, majority, minority)]["mutNum"] += 1
            # total count (original is g1Tri) to mutDict2 and mutDict3
            add2totalNum(mutDict2, g1Tri)
            add2totalNum(mutDict3, g1Tri)


def initialize_mut_dict():
    """
    key: mutType (e.g. ACGA which means ACG -> AAG)
    value: {
        "mutNum": 0,
        "oriNum": 0
    }
    """
    mutDict = {}
    letters = ["A", "C", "G", "T"]
    midLetters = ["C", "T"]
    cSubs = ["A", "G", "T"]
    tSubs = ["A", "C", "G"]
    for i in letters:
        for j in midLetters:
            if j == "C":
                for k in cSubs:
                    for l in letters:
                        mutType = i + j + l + k
                        mutDict[mutType] = {"mutNum": 0, "oriNum": 0}
            if j == "T":
                for k in tSubs:
                    for l in letters:
                        mutType = i + j + l + k
                        mutDict[mutType] = {"mutNum": 0, "oriNum": 0}
    return mutDict


def write_tsv_file(outputFilePath, mutDict):
    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["mutType", "mutNum", "oriNum"])
        mutTypeList = sorted(
            list(mutDict.keys()), key=lambda x: (x[1], x[3], x[0], x[2])
        )
        for mutType in mutTypeList:
            writer.writerow(
                [
                    mutType[0] + "[" + mutType[1] + ">" + mutType[3] + "]" + mutType[2],
                    mutDict[mutType]["mutNum"],
                    mutDict[mutType]["oriNum"],
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
    originalTripletCounts = collections.Counter()
    mutCounts2 = collections.Counter()
    mutCounts3 = collections.Counter()
    with open(outputBedFilePath2, "w") as bedFile2:
        bedFile2.write(
            "chrB\tstartB\tendB\tname\tscore\tstrandB\ttrinucB\tsbstType\tchrA\tstartA\tendA\tstrandA\ttrinucA\tchrC\tstartC\tendC\tstrandC\ttrinucC\n"
        )
    with open(outputBedFilePath3, "w") as bedFile3:
        bedFile3.write(
            "chrC\tstartC\tendC\tname\tscore\tstrandC\ttrinucC\tsbstType\tchrA\tstartA\tendA\tstrandA\ttrinucA\tchrB\tstartB\tendB\tstrandB\ttrinucB\n"
        )
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
            x, y, z = gSeq1[i : i + 3]
            a, b, c = gSeq2[i : i + 3]
            d, e, f = gSeq3[i : i + 3]
            # if both edge bases same, and outgroup middle base not unique:
            if x == a and x == d and z == c and z == f and (y == b or y == e):
                # skip cases with gaps or any other non-ACGT symbols:
                if x in "ACGT" and z in "ACGT" and b in "ACGT" and e in "ACGT":
                    originalTriplet = x + y + z
                    originalTripletCounts[originalTriplet] += 1
                    if b != y:
                        mutCounts2[originalTriplet + b] += 1
                        with open(outputBedFilePath2, "a") as bedFile2:
                            bedFile2.write(
                                f"{aln.gChr2}\t{aln.gStart2}\t{aln.gEnd2}\t.\t.\t{aln.gStrand2}\t{a}{b}{c}\t{originalTriplet+b}\t{aln.gChr1}\t{aln.gStart1}\t{aln.gEnd1}\t{aln.gStrand1}\t{originalTriplet}\t{aln.gChr3}\t{aln.gStart3}\t{aln.gEnd3}\t{aln.gStrand3}\t{d}{e}{f}\n"
                            )
                    if e != y:
                        mutCounts3[originalTriplet + e] += 1
    alnFileHandle.close()

    # write to outputFilePath2
    write_tsv_file(outputTsvFilePath2, mutDict2)
    # write to outputFilePath3
    write_tsv_file(outputTsvFilePath3, mutDict3)


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
