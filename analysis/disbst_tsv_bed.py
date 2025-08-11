#! /usr/bin/env python3

"""
Input:
    - a 3-genome joined alignment .maf file
      (the top sequence should be the outgroup)
    - outputTSVFilePath2
    - outputTSVFilePath3
    - outputBedFilePath2
    - outputBedFilePath3
Output:
    - two tsv files with the following columns:
        - mutation type
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
import itertools
import os
from Util import getJoinedAlignmentObj


#############
# functions
#############


revDict = {"A": "T", "T": "A", "C": "G", "G": "C"}

# We don't want to count any original doublet separately from its
# reverse complement.  So use the reverse-complement of these (arbitrary?) ones
reversedOriginalDoublets = "AA GT AG CA GG GA"

# generate all possible double substitution types
mutTypes = []
for x, y, b, c in itertools.product("ACGT", repeat=4):
	originalDoublet = x + y
	mutatedDoublet = b + c
	# require both bases to be different:
	if x == b or y == c:
		continue
	# arbitrarily(?) exclude cases whose reverse-complement is included:
	if (
		originalDoublet in reversedOriginalDoublets
		or originalDoublet == "AT"
		and mutatedDoublet in "GG TC TG"
		or originalDoublet == "CG"
		and mutatedDoublet in "AA AC GA"
		or originalDoublet == "GC"
		and mutatedDoublet in "CT TG TT"
		or originalDoublet == "TA"
		and mutatedDoublet in "AC AG CC"
	):
		continue
	mutType = originalDoublet + mutatedDoublet
	mutTypes.append(mutType)


def initialize_mut_dict():
    """
    key: mutType (e.g. ACGA which means AC -> GA)
    value: 0
    """
    mutDict = dict.fromkeys(mutTypes, 0)
    return mutDict


def write_output_file(outputFilePath, mutDict, totDict):
    with open(outputFilePath, "w") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t", lineterminator="\n")
        writer.writerow(["mutType", "mutNum", "totalRootNum"])
        for mutType in sorted(mutDict):
            originalDoublet = mutType[0:2]
            writer.writerow(
                [
                    originalDoublet + ">" + mutType[2:4],
                    mutDict[mutType],
                    totDict[originalDoublet],
                ]
            )


def mutDictFromCounts(counts):
    mutDict = initialize_mut_dict()
    for key, count in counts.items():
        if key not in mutDict:
            x, y, b, c = key
            key = revDict[y] + revDict[x] + revDict[c] + revDict[b]
        mutDict[key] += count
    return mutDict


def totDictFromCounts(counts):
    totDict = collections.Counter()
    for doublet, count in counts.items():
        if doublet in reversedOriginalDoublets:
            x, y = doublet
            doublet = revDict[y] + revDict[x]
        totDict[doublet] += count
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
    outputFilePath2,
    outputFilePath3,
    outputBedFilePath2,
    outputBedFilePath3,
):
    originalDoubletCounts = collections.Counter()
    mutCounts2 = collections.Counter()
    mutCounts3 = collections.Counter()

    # Add headers for BED files
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
        for i in range(len(gSeq1) - 3):
            w, x, y, z = gSeq1[i : i + 4]
            a, b, c, d = gSeq2[i : i + 4]
            e, f, g, h = gSeq3[i : i + 4]
            if (
                w == a
                and w == e
                and z == d
                and z == h
                and (x + y == b + c or x + y == f + g)
                and w in "ACGT"
                and z in "ACGT"
                and b in "ACGT"
                and c in "ACGT"
                and f in "ACGT"
                and g in "ACGT"
            ):
                originalDoublet = x + y
                originalDoubletCounts[originalDoublet] += 1
				# puls strand's coordinates of the mutated two bases
				start1, end1 = set2PosCoord(
					aln.gStrand1,
					aln.gStart1 + i + 1,
					aln.gStart1 + i + 3,
					aln.gLength1,
				)
				start2, end2 = set2PosCoord(
					aln.gStrand2,
					aln.gStart2 + i + 1,
					aln.gStart2 + i + 3,
					aln.gLength2,
				)
				start3, end3 = set2PosCoord(
					aln.gStrand3,
					aln.gStart3 + i + 1,
					aln.gStart3 + i + 3,
					aln.gLength3,
				)
                if b != x and c != y:
                    mutCounts2[originalDoublet + b + c] += 1
                    sbstType = x + y + ">" + b + c
                    with open(outputBedFilePath2, "a") as bedFile:
                        bedFile.write(
                            f"{aln.gChr1}\t{aln.gStart1 + i + 1}\t{aln.gStart1 + i + 2}\t{aln.gStrand1}\t{originalDoublet}\t"
                            f"{aln.gChr2}\t{aln.gStart2 + i + 1}\t{aln.gStart2 + i + 2}\t{aln.gStrand2}\t{b + c}\t"
                            f"{aln.gChr3}\t{aln.gStart3 + i + 1}\t{aln.gStart3 + i + 2}\t{aln.gStrand3}\t{f + g}\t{sbstType}\n"
                        )
                if f != x and g != y:
                    mutCounts3[originalDoublet + f + g] += 1
                    sbstType = x + y + ">" + f + g
                    with open(outputBedFilePath3, "a") as bedFile:
                        bedFile.write(
                            f"{aln.gChr1}\t{aln.gStart1 + i + 1}\t{aln.gStart1 + i + 2}\t{aln.gStrand1}\t{originalDoublet}\t"
                            f"{aln.gChr2}\t{aln.gStart2 + i + 1}\t{aln.gStart2 + i + 2}\t{aln.gStrand2}\t{b + c}\t"
                            f"{aln.gChr3}\t{aln.gStart3 + i + 1}\t{aln.gStart3 + i + 2}\t{aln.gStrand3}\t{f + g}\t{sbstType}\n"
                        )

    alnFileHandle.close()

    mutDict2 = mutDictFromCounts(mutCounts2)
    mutDict3 = mutDictFromCounts(mutCounts3)
    totDict = totDictFromCounts(originalDoubletCounts)

    write_output_file(outputFilePath2, mutDict2, totDict)
    write_output_file(outputFilePath3, mutDict3, totDict)


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
        outFile2 = f"{org2}_dinuc.tsv"
        outFile3 = f"{org3}_dinuc.tsv"
        obFile2 = f"{org2}_dinuc.bed"
        obFile3 = f"{org3}_dinuc.bed"
    else:
        outFile2 = f"{org2}_{rest}_dinuc.tsv"
        outFile3 = f"{org3}_{rest}_dinuc.tsv"
        obFile2 = f"{org2}_{rest}_dinuc.bed"
        obFile3 = f"{org3}_{rest}_dinuc.bed"
    outputFilePath2 = os.path.join(path_before_filename, outFile2)
    outputFilePath3 = os.path.join(path_before_filename, outFile3)
    outputBedFilePath2 = os.path.join(path_before_filename, obFile2)
    outputBedFilePath3 = os.path.join(path_before_filename, obFile3)
    return outputFilePath2, outputFilePath3, outputBedFilePath2, outputBedFilePath3


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
        "-o2",
        "--outputFilePath2",
        help="output file path for organism2",
    )
    parser.add_argument(
        "-o3",
        "--outputFilePath3",
        help="output file path for organism3",
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
    outputFilePath2, outputFilePath3, outputBedFilePath2, outputBedFilePath3 = (
        get_default_output_file_names(joinedAlnFile)
    )

    ###################
    # main
    ###################
    alnFileHandle = open(joinedAlnFile)
    main(
        alnFileHandle,
        outputFilePath2,
        outputFilePath3,
        outputBedFilePath2,
        outputBedFilePath3,
    )
