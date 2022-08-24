'''
Input:
    - an output file of RepeatMasker
    - a .maf file (alignment)
Output:
    - output.out
        Find splits that have TE sequences on both intron start
        and intron end, and print out MAF entries and TE rows
            - MAF entries from .maf file
            - TE rows from the input RepeatMasker file
    - output.maf
        MAF entries of such splits as above
'''
import argparse
import csv
from Util import getMultiMAFEntries
from Util import getIntronCoord


def skipFirstTwoRows(repeatMaskerFile):
    for i, row in enumerate(repeatMaskerFile):
        if i != 0 and i != 1:
            yield row


def getRepeatData(repeatMaskerFile):
    repeatData = []
    with open(repeatMaskerFile, 'r') as f:
        print('--- Reading RepeatMasker File')
        for row in csv.reader(skipFirstTwoRows(f), delimiter='\t'):
            repeatData.append(row)
    # sort according to chromosome name, start position, and end position
    print('--- Sorting repeatData')
    repeatData_sorted = sorted(repeatData,
                               key=lambda r: (r[4], int(r[5]), int(r[6])))
    return repeatData_sorted


def getAlignmentData(alignmentFile):
    print('--- Reading alignmentFile')
    alignments_list = []
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # prerequisite:
        # alignments are already sorted
        # according to + strand's coordinates

        readStrand = None
        # get the order of alignments
        # if the first alignment has donor and doesn't have acceptor
        # or the last alignment doesn't have donor and has acceptor
        if (alignments[0].don and not alignments[0].acc)\
                or (not alignments[-1].don and alignments[-1].acc):
            # set readStrand to '+'
            readStrand = '+'
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
        else:
            # go to next readID
            # (do NOT append to alignments_list)
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the reaad
            # (checking only "Exact Splits")
            # do NOT append alignments with inexact splits
            if aln2.rStart - aln1.rEnd == 0:
                intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                intronLeft = min([intronStart, intronEnd],
                                 key=lambda c: (c[0], c[1]))
                intronRight = max([intronStart, intronEnd],
                                  key=lambda c: (c[0], c[1]))
                # alignments_list: list of tuple
                alignments_list.append(((readStrand, aln1, aln2),
                                        (intronLeft, intronRight)))

    # sort alignments_list according to
    # intronLeft and intronRight chromosom name and coord
    print('--- Sorting alignments')
    alignments_list.sort(key=lambda a_c: ((a_c[1][0][0], a_c[1][0][1]),
                                          (a_c[1][1][0], a_c[1][1][1])))

    return alignments_list


def getTE_TESplits(repeatData, alignments_list, outputFileName):
    pass


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('repeatMaskerFile',
                        help='an output file of RepeatMasker')
    parser.add_argument('alignmentFile',
                        help='a .maf file')
    parser.add_argument('outputFileName',
                        help='output-file-path/output-file-name-without-\
                        filename-extension')
    args = parser.parse_args()
    '''
    Read the cds file
    '''
    repeatData = getRepeatData(args.repeatMaskerFile)
    '''
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get TE-TE splits
    '''
    getTE_TESplits(repeatData, alignments_list, args.outputFileName)
