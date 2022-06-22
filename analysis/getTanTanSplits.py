'''
Input:
    - an output file of "tantan  -f 4" (.tsv file)
    - an alignment file (.maf file)
Output:
    print out spliced region with tandem repeats
    on both exon end and exon start
    (check only "Exact Splits" and GT-AG splits)
    - maf entry
    - tantan row
    - tantan row
'''
import argparse
import csv
from Util import getMultiMAFEntries
from Util import convert2CoorOnOppositeStrand
from Util import getIntronCoord
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


def getTan(trData, intronStartOrEnd):
    for trRow in trData:
        if (trRow[0] == intronStartOrEnd[0]
                and int(trRow[1]) < intronStartOrEnd[1]
                and intronStartOrEnd[1] <= int(trRow[2])):
            return trRow
    else:
        return None


def printTantanSplits(trData, alignmentFile, outputFile):
    print("--- Searching tan-tan-splits")
    excount = 0
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
                # print('found exact split')
                # print('strand of read {}'.format(readStrand))
                # print(aln1)
                # print(aln2)
                intronStart, intronEnd = getIntronCoord(readStrand,
                                                        aln1, aln2)
                # print(intronStart)
                # print(intronEnd)
                tan1 = getTan(trData, intronStart)
                tan2 = getTan(trData, intronEnd)
                # print(tan1)
                # print(tan2)
                if (tan1 and tan2 and tan1 == tan2
                        and aln1.rStrand == aln2.rStrand):
                    print('< tandem expansion >', file=sys.stderr)
                    print(excount := excount+1, file=sys.stderr)
                    print('strand of read: {}'.format(readStrand),
                          file=sys.stderr)
                    print(aln1, file=sys.stderr)
                    print(aln2, file=sys.stderr)
                    print('\t'.join(tan1), file=sys.stderr)
                    print('\t'.join(tan2), file=sys.stderr)
                    print('\n\n', file=sys.stderr)
                elif (tan1 and tan2):
                    # print('FOUND!')
                    with open(outputFile, 'a') as f:
                        f.write(str(count := count+1)+'\n')
                        f.write('strand of read: {}\n'.format(readStrand))
                        f.write(str(aln1))
                        f.write(str(aln2))
                        f.write('\t'.join(tan1)+'\n')
                        f.write('\t'.join(tan2)+'\n')
                        f.write('\n\n')


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
    parser.add_argument('outputFile',
                        help='output file name')
    args = parser.parse_args()
    '''
    Read the tantan file
    '''
    trData = getTandemRepeatData(args.tantanFile)
    '''
    Get tantan splits
    '''
    printTantanSplits(trData, args.alignmentFile, args.outputFile)
