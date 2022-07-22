'''
Input:
    - an output file of "tantan  -f 4" (.tsv file)
    - an alignment file (.maf file)
Output:
    print out spliced region with tandem repeats
    on both exon end and exon start
    (check only "Exact Splits" and 'GT-AG' introns)
    - maf entry
    - tantan row
    - tantan row
'''
import argparse
import csv
from getAlignmentObjs import getMultiMAFEntries
from getSplicingSignalsDistOfExactSplicings import convert2CoorOnOppositeStrand


def getTandemRepeatData(tantanFile):
    with open(tantanFile, 'r') as f:
        print('--- Reading tantanFile')
        tandemRepeatData = [row for row in csv.reader(f, delimiter='\t')]
    # sort according to chromosom name, start position, and end position
        print('--- Sorting tandemRepeatData')
    tandemRepeatData_sorted = sorted(tandemRepeatData,
                                     key=lambda x: (x[0], int(x[1]),
                                                    int(x[2])))
    # print(tandemRepeatData_sorted)
    return tandemRepeatData_sorted


def getIntronCoord(readStrand, aln1, aln2):
    # assuming aln.gStrand == '+'
    try:
        if not (aln1.gStrand == '+' and aln2.gStrand == '+'):
            raise Exception
    except Exception:
        print('< gStrand = \"-\" >')
        print(aln1)
        print(aln2)

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
            # adjust all coordinates to + strand's coordinates
            # for aln in alignments:
            #    if aln.rStrand == '-':
            #        aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
            # adjust all coordinates to - strand's coordinates
            # for aln in alignments:
            #    if aln.rStrand == '+':
            #        aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
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
                # print('intronStart: ', intronStart[0],
                #      str(intronStart[1]), intronStart[2])
                # print('intronEnd: ', intronEnd[0],
                #      str(intronEnd[1]), intronEnd[2])
                intronLeft = min([intronStart, intronEnd],
                                 key=lambda c: (c[0], c[1]))
                intronRight = max([intronStart, intronEnd],
                                  key=lambda c: (c[0], c[1]))
                # print('intronLeft: ', intronLeft[0],
                #      str(intronLeft[1]), intronLeft[2])
                # print('intronRight: ', intronRight[0],
                #      str(intronRight[1]), intronRight[2])
                # alignments_list: list of tuple
                alignments_list.append(((readStrand, aln1, aln2),
                                        (intronLeft, intronRight)))

    # sort alignments_list according to
    # intronStart and intronEnd chromosom name and coord
    print('--- Sorting alignments')
    alignments_list.sort(key=lambda a_c: ((a_c[1][0][0], a_c[1][0][1]),
                                          (a_c[1][1][0], a_c[1][1][1])))
    # print sorted alignments_list
    # for alignments in alignments_list:
    #    intronLeft = alignments[1][0]
    #    intronRight = alignments[1][1]
    #    print('intronLeft:', intronLeft[0],
    #          str(intronLeft[1]), intronLeft[2])
    #    print('intronRight:', intronRight[0],
    #          str(intronRight[1]), intronRight[2])

    return alignments_list


def beg(element):
    if isinstance(element, list):
        return (element[0], int(element[1]))
    else:
        return (element[1][0][0], element[1][0][1])


def end(element):
    if isinstance(element, list):
        return (element[0], int(element[2]))
    else:
        return (element[1][1][0], element[1][1][1])


def printTantanSplits(trData, alignments_list, outputFile):
    # refresh outputFile
    with open(outputFile, 'w') as f:
        pass

    print('--- Searching tan-tan-splits')
    count = 0
    j = 0
    for i in range(len(alignments_list)):
        # intronLeft = ' '.join(map(str, alignments_list[i][1][0]))
        # intronRight = ' '.join(map(str, alignments_list[i][1][1]))
        while (j < len(trData)
                and end(trData[j]) < beg(alignments_list[i])):
            j += 1
        k = j
        # print('intronLeft', intronLeft)
        # print('intronRight', intronRight)
        # print('\t'.join(trData[j]))
        while (k < len(trData)
                and beg(trData[k]) < beg(alignments_list[i])):
            tan1 = trData[k]
            # because tan1 != tan2, m starts from k+1
            m = k + 1
            while (m < len(trData)
                   and end(trData[m]) < end(alignments_list[i])):
                m += 1
            n = m
            while (n < len(trData)
                   and beg(trData[n]) < end(alignments_list[i])):
                tan2 = trData[n]
                rStrand = alignments_list[i][0][0]
                aln1 = alignments_list[i][0][1]
                aln2 = alignments_list[i][0][2]
                # if (aln1.don.upper() == 'GT'
                #        and aln2.acc.upper() == 'AG'):
                with open(outputFile, 'a') as f:
                    f.write(str(count := count+1)+'\n')
                    f.write('strand of read: {}\n'.format(rStrand))
                    f.write(aln1._MAF())
                    f.write(aln2._MAF())
                    f.write('\n')
                    f.write('\t'.join(tan1)+'\n')
                    f.write('\t'.join(tan2)+'\n')
                    f.write('\n\n')
                    f.flush()
                n += 1
            k += 1


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
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get tantan splits
    '''
    printTantanSplits(trData, alignments_list, args.outputFile)
