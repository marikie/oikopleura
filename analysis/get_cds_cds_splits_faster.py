'''
Input:
    - a .gff file (annotation)
    - a .maf file (alignment)
Output:
    - output.out
        Find splits that have CDS sequences on both intron start
        and intron end positions, and
        print out MAF entries with CDS rows
            - MAF entries from .maf file
            - CDS rows from .gff file
    - output.maf
        MAF entries of such splits as above
'''
import argparse
import csv
from Util import getMultiMAFEntries
from Util import getIntronCoord


def decomment(csvFile):
    for row in csvFile:
        not_comment_line = row.split('#')[0].strip()
        if not_comment_line:
            yield not_comment_line


def getCDSdata(gffFile):
    cdsData = []
    with open(gffFile, 'r') as f:
        print('--- Reading gffFile')
        for row in csv.reader(decomment(f), delimiter='\t'):
            # print(row)
            if row[2] == 'CDS':
                cdsData.append(row)
            else:
                pass
        # sort according to chromosome name, start position, end position,
        # and strand
        print('--- Sorting cdsData')
        cdsData_sorted = sorted(cdsData,
                                key=lambda r: (r[0], int(r[3]), int(r[4]),
                                               r[6]))
        return cdsData_sorted


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
                # print('intronStart: ', intronStart[0],
                #      str(intronStart[1]), intronStart[2])
                # print('intronEnd: ', intronEnd[0],
                #      str(intronEnd[1]), intronEnd[2])
                intronLeft = min([intronStart, intronEnd],
                                 key=lambda c: (c[0], c[1], c[2]))
                intronRight = max([intronStart, intronEnd],
                                  key=lambda c: (c[0], c[1], c[2]))
                # print('intronLeft: ', intronLeft[0],
                #      str(intronLeft[1]), intronLeft[2])
                # print('intronRight: ', intronRight[0],
                #      str(intronRight[1]), intronRight[2])
                # alignments_list: list of tuple
                alignments_list.append(((readStrand, aln1, aln2),
                                        (intronLeft, intronRight),
                                        (intronStart, intronEnd)))

    # sort alignments_list according to
    # intronLeft and intronRight chromosom name and coord
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
    # element = cds row
    if isinstance(element, list):
        return (element[0], int(element[3]))
    # element = alignment tuple
    else:
        return (element[1][0][0], element[1][0][1])


def end(element):
    # element = cds row
    if isinstance(element, list):
        return (element[0], int(element[4]))
    # element = alignment tuple
    else:
        return (element[1][1][0], element[1][1][1])


def printCdsCdsSplits(cdsData, alignments_list, outputFileName):
    outputFile = outputFileName + '.out'
    outputMAFfile = outputFileName + '.maf'
    # refresh outputFile
    with open(outputFile, 'w'):
        pass
    # refresh outputMAFfile
    with open(outputMAFfile, 'w'):
        pass

    print('--- Searching cds-cds-splits')
    count = 0
    j = 0
    for i in range(len(alignments_list)):
        # intronLeft = ' '.join(map(str, alignments_list[i][1][0]))
        # intronRight = ' '.join(map(str, alignments_list[i][1][1]))

        # do not include end(CDS) == beg(intron)
        while (j < len(cdsData)
                and end(cdsData[j]) <= beg(alignments_list[i])):
            j += 1
        k = j
        # print('intronLeft', intronLeft)
        # print('intronRight', intronRight)
        # print('\t'.join(cdsData[j]))

        # consider as cds1 when beg(CDS) == beg(intron)
        while (k < len(cdsData)
                and beg(cdsData[k]) <= beg(alignments_list[i])):
            # check if strand of CDS == strand of beg(intron)
            if cdsData[k][6] == alignments_list[i][1][0][2]:
                cds1 = cdsData[k]
                cds1_gene = '.'.join(cds1[-1].split(';')[1].split(
                            '=')[1].split('.')[3:5])
            else:
                cds1 = None
            # because cds1 != cds2, m starts from k+1
            m = k + 1
            # do not include as cds2 when end(CDS) == end(intron)
            while (m < len(cdsData)
                   and end(cdsData[m]) <= end(alignments_list[i])):
                m += 1
            n = m
            # include as cds2 when beg(CDS) == end(intron)
            while (n < len(cdsData)
                   and beg(cdsData[n]) <= end(alignments_list[i])):
                # check if strand of CDS == strand of end(intron)
                if cdsData[n][6] == alignments_list[i][1][1][2]:
                    cds2 = cdsData[n]
                    cds2_gene = '.'.join(cds2[-1].split(';')[1].split(
                        '=')[1].split('.')[3:5])
                else:
                    cds2 = None
                if cds1 and cds2:
                    if cds1_gene != cds2_gene:
                        rStrand = alignments_list[i][0][0]
                        aln1 = alignments_list[i][0][1]
                        aln2 = alignments_list[i][0][2]
                        intronLeft = alignments_list[i][1][0]
                        intronRight = alignments_list[i][1][1]

                        with open(outputMAFfile, 'a') as mFile:
                            mFile.write(aln1._MAF())
                            mFile.write(aln2._MAF())
                            mFile.flush()

                        with open(outputFile, 'a') as oFile:
                            oFile.write(str(count := count+1)+'\n')
                            oFile.write('strand of read: {}\n'.format(rStrand))
                            oFile.write('intronLeft:  {}\n'.format(intronLeft))
                            oFile.write('intronRight: {}\n'.format(
                                                                intronRight))
                            oFile.write(aln1._MAF())
                            oFile.write(aln2._MAF())
                            oFile.write('\t'.join(cds1)+'\n')
                            oFile.write('\t'.join(cds2)+'\n')
                            oFile.write('\n\n')
                            oFile.flush()
                n += 1
            k += 1


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('cdsFile',
                        help='a .gff file')
    parser.add_argument('alignmentFile',
                        help='a .maf file')
    parser.add_argument('outputFileName',
                        help='output-file-path/output-file-name-without-\
                        filename-extension')
    args = parser.parse_args()
    '''
    Read the cds file
    '''
    cdsData = getCDSdata(args.cdsFile)
    '''
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get cds-cds splits
    '''
    printCdsCdsSplits(cdsData, alignments_list, args.outputFileName)
