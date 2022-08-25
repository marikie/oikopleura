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


def isTE(line):
    if (line[10] != 'Normally_Non-integrating_Virus' and
            line[10] != 'Artifact' and
            line[10] != 'Low_complexity' and
            line[10] != 'Other' and
            line[10] != 'Segmental_Duplication' and
            line[10] != 'rRNA' and
            line[10] != 'scRNA' and
            line[10] != 'snRNA' and
            line[10] != 'tRNA' and
            line[10] != 'Centromeric' and
            line[10] != 'Acromeric' and
            line[10] != 'Macro' and
            line[10] != 'Subtelomeric' and
            line[10] != 'W-chromosomal' and
            line[10] != 'Y-chromosomal' and
            line[10] != 'Simple_repeat' and
            line[10] != 'Unknown'):
        return True
    else:
        return False


def getTEData(repeatMaskerFile):
    teData = []
    with open(repeatMaskerFile, 'r') as f:
        print('--- Reading RepeatMasker File')
        for row in csv.reader(skipFirstTwoRows(f), delimiter='\t'):
            if isTE(row):
                teData.append(row)
    # sort according to chromosome name, start position, and end position
    print('--- Sorting repeatData')
    teData_sorted = sorted(repeatData,
                           key=lambda r: (r[4], int(r[5]), int(r[6])))
    return teData_sorted


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


def beg(element):
    # element = te row
    if isinstance(element, list):
        return (element[4], int(element[5]))
    # element = alignment tuple
    else:
        return (element[1][0][0], element[1][0][1])


def end(element):
    # element = te row
    if isinstance(element, list):
        return (element[4], int(element[6]))
    # element = alignment tuple
    else:
        return (element[1][1][0], element[1][1][1])


def getTE_TESplits(teData, alignments_list, outputFileName):
    outputFile = outputFileName + '.out'
    outputMAFfile = outputFileName + '.maf'
    # refresh outputFile
    with open(outputFile, 'w'):
        pass
    # refresh outputMAFfile
    with open(outputMAFfile, 'w'):
        pass

    print('--- Searching TE-TE splits')
    count = 0
    j = 0
    for i in range(len(alignments_list)):
        # intronLeft = ' '.join(map(str, alignments_list[i][1][0]))
        # intronRight = ' '.join(map(str, alignments_list[i][1][1]))
        while (j < len(teData)
                and end(teData[j]) < beg(alignments_list[i])):
            j += 1
        k = j
        # print('intronLeft', intronLeft)
        # print('intronRight', intronRight)
        # print('\t'.join(teData[j]))
        while (k < len(teData)
                and beg(teData[k]) < beg(alignments_list[i])):
            te1 = teData[k]
            # because te1 != te2, m starts from k+1
            m = k + 1
            while (m < len(teData)
                   and end(teData[m]) < end(alignments_list[i])):
                m += 1
            n = m
            while (n < len(teData)
                   and beg(teData[n]) < end(alignments_list[i])):
                te2 = teData[n]
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
                    oFile.write('intronLeft: {}\n'.format(intronLeft))
                    oFile.write('intronRight: {}\n'.format(intronRight))
                    oFile.write(aln1._MAF())
                    oFile.write(aln2._MAF())
                    oFile.write('\t'.join(te1)+'\n')
                    oFile.write('\t'.join(te2)+'\n')
                    oFile.write('\n\n')
                    oFile.flush()
                n += 1
            k += 1


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
    teData = getTEData(args.repeatMaskerFile)
    '''
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get TE-TE splits
    '''
    getTE_TESplits(teData, alignments_list, args.outputFileName)
