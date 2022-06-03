'''
Input:
    - an output file of "tantan  -f 4" (.tsv file)
    - an alignment file (.maf file)
Output:
    print out spliced region with tandem repeats
    on both exon end and exon start (check only "Exact Splits")
    - maf entry
    - tantan row
    - tantan row
'''
import argparse
import csv
from getAlignmentObjs import getMultiMAFEntries
from getSplicingSignalsDistOfExactSplicings import convert2CoorOnOppositeStrand
import sys


def getTandemRepeatData(tantanFile):
    with open(tantanFile, 'r') as f:
        print("--- Reading tantanFile")
        tandemRepeatData = [row for row in csv.reader(f, delimiter='\t')]
    # sort according to chromosom name, start position, and end position
        print("--- Sorting tandemRepeatData")
    tandemRepeatData_sorted = sorted(tandemRepeatData,
                                     key=lambda x: (x[0], x[1], x[2]))
    return tandemRepeatData_sorted


def getTan(trData, aln, EndOrBegin):
    if EndOrBegin == 'End':
        for trRow in trData:
            if (trRow[0] == aln.gChr
                    and int(trRow[1]) < aln.gEnd
                    and aln.gEnd <= int(trRow[2])):
                return trRow
        else:
            return None
    else:  # 'Begin'
        for trRow in trData:
            if (trRow[0] == aln.gChr
                    and int(trRow[1]) < aln.gStart
                    and aln.gStart <= int(trRow[2])):
                return trRow
        else:
            return None


def printTantanSplits(trData, alignmentFile):
    print("--- Searching tan-tan-splits")
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # preparation: sort alignments
        # adjust all reads' coordinates to + strand's coordinates
        for aln in alignments:
            if aln.rStrand == '+':
                pass
            else:
                aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        # sort alignments according to reads's start position
        alignments.sort(key=lambda a: a.rStart)

        # get the order of alignments
        # if the first alignment has donor and doesn't have acceptor
        # or the last alignment doesn't have donor and has acceptor
        if (alignments[0].don and not alignments[0].acc)\
                or (not alignments[-1].don and alignments[-1].acc):
            # do nothing
            pass
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # reverse the alignments list
            alignments.sort(reverse=True, key=lambda aln: aln.rStart)
            # adjust all coordinates to - strand's coordinates
            for aln in alignments:
                aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        else:
            # go to next readID
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # check only "Exact Splits"
            # if two separate alignments are continuous on the reaad
            if aln2.rStart - aln1.rEnd == 0:
                tan1 = getTan(trData, aln1, 'End')
                tan2 = getTan(trData, aln2, 'Begin')
                if tan1 and tan2:
                    print(aln1)
                    print(aln2)
                    print('\t'.join(tan1))
                    print('\t'.join(tan2))
                    print('\n\n')


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('tantanFile',
                        help='an output .tsv file of \
                        \"tantan -f 4\"')
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads \
                        to reference in MAF format')
    args = parser.parse_args()
    '''
    Read the tantan file
    '''
    trData = getTandemRepeatData(args.tantanFile)
    '''
    Get tantan splits
    '''
    printTantanSplits(trData, args.alignmentFile)
