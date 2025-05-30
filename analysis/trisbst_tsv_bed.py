"""
Input:
    - a 3-genome joined alignment .maf file
      (the top sequence should be the outgroup)
    - outputTsvFilePath2
    - outputTsvFilePath3
    - outputBedFilePath2
    - outputBedFilePath3
Output:
    - two tsv files with the following columns:
                - mutType
                - mutNum
                - totalRootNum
    - two bed files with the following columns:
                - chrA
                - startA
                - endA
                - strandA
                - trinucA
                - chrB
                - startB
                - endB
                - strandB
                - trinucB
                - chrC
                - startC
                - endC
                - strandC
                - trinucC
                - sbstType
"""

import argparse
import collections
import csv
import os
from Util import getJoinedAlignmentObj

#############
# functions
#############
revDict = {"A": "T", "T": "A", "C": "G", "G": "C"}


def initialize_mut_dict():
    """
    key: mutType (e.g. ACGA which means ACG -> AAG)
    value: 0
    """
    mutDict = {}
    letters = "ACGT"
    midLetters = "CT"
    for i in letters:
        for j in midLetters:
            for k in letters:
                for l in letters:
                    if l != j:
                        mutType = i + j + k + l
                        mutDict[mutType] = 0
    return mutDict


def write_tsv_file(outputFilePath, mutDict, totDict):
    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["mutType", "mutNum", "totalRootNum"])
        mutTypeList = sorted(
            list(mutDict.keys()), key=lambda x: (x[1], x[3], x[0], x[2])
        )
        for mutType in mutTypeList:
            originalTriplet = mutType[0:3]
            writer.writerow(
                [
                    mutType[0] + "[" + mutType[1] + ">" + mutType[3] + "]" + mutType[2],
                    mutDict[mutType],
                    totDict[originalTriplet],
                ]
            )


def mutDictFromCounts(counts):
    mutDict = initialize_mut_dict()
    for key, count in counts.items():
        x, y, z, b = key
        if y == "A" or y == "G":
            key = revDict[z] + revDict[y] + revDict[x] + revDict[b]
        mutDict[key] += count
    return mutDict


def totDictFromCounts(counts):
    totDict = collections.Counter()
    for triplet, count in counts.items():
        x, y, z = triplet
        if y == "A" or y == "G":
            triplet = revDict[z] + revDict[y] + revDict[x]
        totDict[triplet] += count
    return totDict


def set2PosCoord(strand, start, end, length):
    if strand == "+":
        return start, end
    else:
        return length - end, length - start


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

    header = "# chrA\tstartA\tendA\tstrandA\ttrinucA\tchrB\tstartB\tendB\tstrandB\ttrinucB\tchrC\tstartC\tendC\tstrandC\ttrinucC\tsbstType\n"
    with open(outputBedFilePath2, "w") as bedFile2:
        bedFile2.write(header)
    with open(outputBedFilePath3, "w") as bedFile3:
        bedFile3.write(header)

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
                    trinuc2 = a + b + c
                    trinuc3 = d + e + f
                    # only write the coordinates of the middle base
                    start1, end1 = set2PosCoord(
                        aln.gStrand1,
                        aln.gStart1 + i + 1,
                        aln.gStart1 + i + 2,
                        aln.gLength1,
                    )
                    start2, end2 = set2PosCoord(
                        aln.gStrand2,
                        aln.gStart2 + i + 1,
                        aln.gStart2 + i + 2,
                        aln.gLength2,
                    )
                    start3, end3 = set2PosCoord(
                        aln.gStrand3,
                        aln.gStart3 + i + 1,
                        aln.gStart3 + i + 2,
                        aln.gLength3,
                    )
                    variants = [
                        (b, mutCounts2, outputBedFilePath2),
                        (e, mutCounts3, outputBedFilePath3),
                    ]
                    for alt, mutCounts, outputFile in variants:
                        if alt != y:
                            mutCounts[originalTriplet + alt] += 1
                            if y in ("A", "G"):
                                sbstType = (
                                    revDict[z]
                                    + "["
                                    + revDict[y]
                                    + ">"
                                    + revDict[alt]
                                    + "]"
                                    + revDict[x]
                                )
                            else:
                                sbstType = x + "[" + y + ">" + alt + "]" + z
                            with open(outputFile, "a") as bedFile:
                                bedFile.write(
                                    f"{aln.gChr1}\t{start1}\t{end1}\t{aln.gStrand1}\t{originalTriplet}\t"
                                    f"{aln.gChr2}\t{start2}\t{end2}\t{aln.gStrand2}\t{trinuc2}\t"
                                    f"{aln.gChr3}\t{start3}\t{end3}\t{aln.gStrand3}\t{trinuc3}\t{sbstType}\n"
                                )
    alnFileHandle.close()

    mutDict2 = mutDictFromCounts(mutCounts2)
    mutDict3 = mutDictFromCounts(mutCounts3)
    totDict = totDictFromCounts(originalTripletCounts)

    # write to outputFilePath2
    write_tsv_file(outputTsvFilePath2, mutDict2, totDict)
    # write to outputFilePath3
    write_tsv_file(outputTsvFilePath3, mutDict3, totDict)


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
