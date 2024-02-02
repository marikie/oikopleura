"""
Input:
    - a PSL file
    - a whole MAF file
Output:
    - a MAF file with only the alignments from the PSL file
"""
import argparse
import os
from Util import getAlignmentObjsOneByOne


def same(aln, line):
    strand = line.split()[8]
    qryChr = line.split()[9]
    qryStart_pls = int(line.split()[11])
    qryEnd_pls = int(line.split()[12])
    refChr = line.split()[13]
    refStart = int(line.split()[15])
    refEnd = int(line.split()[16])

    if strand == "+":
        qryStart = qryStart_pls
        qryEnd = qryEnd_pls
    else:
        qryLen = int(line.split()[10])
        qryStart = qryLen - qryEnd_pls
        qryEnd = qryLen - qryStart_pls
    # print(refChr, refStart, refEnd, qryChr, qryStart, qryEnd, strand)

    if (
        aln.gChr == refChr
        and aln.gStart == refStart
        and aln.gEnd == refEnd
        and aln.rID == qryChr
        and aln.rStart == qryStart
        and aln.rEnd == qryEnd
    ):
        return True
    else:
        return False


def main(pslFile, inMAFFile, outDir):
    # get pslFile name without extension
    # and add ".maf" extension
    outMAFFile = os.path.splitext(os.path.basename(pslFile))[0] + ".maf"
    # print(outMAFFile)
    # open pslFile
    with open(pslFile, "r") as f:
        lines = f.readlines()
    totalLines = len(lines)

    hits = 0
    for aln in getAlignmentObjsOneByOne(inMAFFile):
        if hits != totalLines:
            for line in lines:
                if hits != totalLines:
                    if same(aln, line):
                        # print(line)
                        hits += 1
                        with open(outDir + "/" + outMAFFile, "a") as f:
                            f.write(aln._MAF())
                    else:
                        pass
                else:
                    break
        else:
            break


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("pslFile", help="a PSL file")
    parser.add_argument("inMAFFile", help="a whole maf file")
    # an optional argument: output directory path
    # if not specified, output to the same directory as the input File
    currentDir = os.getcwd()
    parser.add_argument(
        "-o", "--outDir", help="output directory path", default=currentDir
    )
    args = parser.parse_args()

    """
    MAIN
    """
    # print(args.outDir)
    main(args.pslFile, args.inMAFFile, args.outDir)
