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


def getIntronCoord(readStrand, aln1, aln2):
    if (aln1.gStrand != '+' or aln2.gStrand != '+'):
        print('< gStrand = \"-\" >', file=sys.stderr)
        print(aln1, file=sys.stderr)
        print(aln2, file=sys.stderr)
        print('\n\n', file=sys.stderr)

    # assuming aln.gStrand == '+'
    if ((readStrand == '+' and aln1.rStrand == '+') or
            (readStrand == '-' and aln1.rStrand == '-')):
        intronStart = (aln1.gChr, aln1.gEnd, '+')
    else:
        # ((readStrand == '+' and aln1.rStrand == '-') or
        #   (readStrand == '-' and aln1.rStrand == '+'))
        intronStart = (aln1.gChr, aln1.gStart, '-')

    if ((readStrand == '+' and aln2.rStrand == '+') or
            (readStrand == '-' and aln2.rStrand == '-')):
        intronEnd = (aln2.gChr, aln2.gStart, '+')
    else:
        # ((readStrand == '+' and aln1.rStrand == '-') or
        #   (readStrand == '-' and aln1.rStrand == '+'))
        intronEnd = (aln2.gChr, aln2.gEnd, '-')

    return (intronStart, intronEnd)


def getTan(trData, intronStartOrEnd):
    for trRow in trData:
        if (trRow[0] == intronStartOrEnd[0]
                and int(trRow[1]) < intronStartOrEnd[1]
                and intronStartOrEnd[1] <= int(trRow[2])):
            return trRow
    else:
        return None


def printTantanSplits(trData, alignmentFile):
    print("--- Searching tan-tan-splits")
    count = 0
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
            # adjust all coordinates to + strand's coordinates
            for aln in alignments:
                if aln.rStrand == '-':
                    aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
            # adjust all coordinates to - strand's coordinates
            for aln in alignments:
                if aln.rStrand == '+':
                    aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        else:
            # go to next readID
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the reaad
            # (checking only "Exact Splits")
            if aln2.rStart - aln1.rEnd == 0:
                intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                tan1 = getTan(trData, intronStart)
                tan2 = getTan(trData, intronEnd)
                if (tan1 and tan2 and tan1 == tan2
                        and aln1.rStrand == aln2.rStrand):
                    print('< tandem expansion >', file=sys.stderr)
                    print('strand of read: {}'.format(readStrand),
                          file=sys.stderr)
                    print(aln1, file=sys.stderr)
                    print(aln2, file=sys.stderr)
                    print('\t'.join(tan1), file=sys.stderr)
                    print('\t'.join(tan2), file=sys.stderr)
                    print('\n\n', file=sys.stderr)
                elif (tan1 and tan2
                        and aln1.don.upper() == 'GT'
                        and aln2.acc.upper() == 'AG'):
                    print(count := count+1)
                    print('strand of read: {}'.format(readStrand))
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
