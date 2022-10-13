'''
Input:
    - a TE_CDS_tableFile
      (a combined file of .gff and RepMask.out)
      (already sorted by chr, start, end, strand)
    - a .maf file
Output:
    - output.out
        Find splits that have TE and CDS on both intron start
        and intron end. Print out MAF entries and TE&CDS rows.
            - MAF entries from .maf file
            - TE & CDS rows from the combined file
    - output.maf
        MAF entries of such splits as above
'''
import argparse
import csv
from Util import getAlignmentData


def getTE_CDS_TableData(te_cds_tableFile):
    te_cds_Data = []
    with open(te_cds_tableFile, 'r') as f:
        print('--- Reading TE_CDS_Table_File')
        for row in csv.reader(f, delimiter='\t'):
            te_cds_Data.append(row)
    # te_cds_Data is already sorted
    return te_cds_Data


def beg(element):
    # element = te or cds row
    if isinstance(element, list):
        # convert 1-base to in-between coordinate
        return (element[1], int(element[2])-1)
    # element = alignment tuple
    else:
        return (element[1][0][0], element[1][0][1])


def end(element):
    # element = te or cds row
    if isinstance(element, list):
        return (element[1], int(element[3]))
    # element = alignment tuple
    else:
        return (element[1][1][0], element[1][1][1])


def getTE_CDSsplits(te_cds_Data, alignments_list, outputFileName):
    outputFile = outputFileName + '.out'
    outputMAFfile = outputFileName + '.maf'
    # refresh outputFile
    with open(outputFile, 'w'):
        pass
    # refresh outputMAFfile
    with open(outputMAFfile, 'w'):
        pass

    print('--- Searching te-cds-splits')
    count = 0
    j = 0
    for i in range(len(alignments_list)):
        # intronLeft = ' '.join(map(str, alignments_list[i][1][0]))
        # intronRight = ' '.join(map(str, alignments_list[i][1][1]))

        # include as cds1 when end(TE/CDS) == beg(intron)
        while (j < len(te_cds_Data)
                and end(te_cds_Data[j]) < beg(alignments_list[i])):
            j += 1
        k = j
        # print('intronLeft', intronLeft)
        # print('intronRight', intronRight)
        # print('\t'.join(te_cds_Data[j]))

        # do not include as cds1 when beg(TE/CDS) == beg(intron)
        while (k < len(te_cds_Data)
                and beg(te_cds_Data[k]) < beg(alignments_list[i])):
            # check if strand of CDS == strand of beg(intron)
            if te_cds_Data[k][4] == alignments_list[i][1][0][2]:
                te_cds1 = te_cds_Data[k]
                print('te_cds1: ', te_cds1)
            else:
                te_cds1 = None
            # because te_cds1 != te_cds2, m starts from k+1
            m = k + 1
            # do not include as te_cds2 when end(TE/CDS) == end(intron)
            while (m < len(te_cds_Data)
                   and end(te_cds_Data[m]) <= end(alignments_list[i])):
                m += 1
            n = m
            # include as te_cds2 when beg(TE/CDS) == end(intron)
            while (n < len(te_cds_Data)
                   and beg(te_cds_Data[n]) <= end(alignments_list[i])):
                # check if strand of TE/CDS == strand of end(intron)
                if te_cds_Data[n][4] == alignments_list[i][1][1][2]:
                    te_cds2 = te_cds_Data[n]
                    print('te_cds2: ', te_cds2)
                else:
                    te_cds2 = None
                if (te_cds1 and te_cds2 and
                        te_cds1[0] != te_cds2[0]):
                    rStrand = alignments_list[i][0][0]
                    aln1 = alignments_list[i][0][1]
                    aln2 = alignments_list[i][0][2]
                    intronStart = alignments_list[i][2][0]
                    intronEnd = alignments_list[i][2][1]
                    intronLeft = alignments_list[i][1][0]
                    intronRight = alignments_list[i][1][1]

                    with open(outputMAFfile, 'a') as mFile:
                        mFile.write(aln1._MAF())
                        mFile.write(aln2._MAF())
                        mFile.flush()

                    with open(outputFile, 'a') as oFile:
                        oFile.write(str(count := count+1)+'\n')
                        oFile.write('strand of read: {}\n'.format(rStrand))
                        oFile.write('intronStart: {}\n'.format(
                                                            intronStart))
                        oFile.write('intronEnd:   {}\n'.format(intronEnd))
                        oFile.write('intronLeft:  {}\n'.format(intronLeft))
                        oFile.write('intronRight: {}\n'.format(
                                                            intronRight))
                        oFile.write(aln1._MAF())
                        oFile.write(aln2._MAF())
                        oFile.write('\n')
                        oFile.write('\t'.join(te_cds1)+'\n')
                        oFile.write('\t'.join(te_cds2)+'\n')
                        oFile.write('\n\n')
                        oFile.flush()
                n += 1
            k += 1


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('te_cds_tableFile',
                        help='a combined file of .gff and  RepeatMasker.out')
    parser.add_argument('alignmentFile',
                        help='a .maf file')
    parser.add_argument('outputFileName',
                        help='output-file-path/output-file-name-without-\
                        filename-extension')
    args = parser.parse_args()
    '''
    Read the cds file
    '''
    te_cds_Data = getTE_CDS_TableData(args.te_cds_tableFile)
    '''
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get TE-TE splits
    '''
    getTE_CDSsplits(te_cds_Data, alignments_list, args.outputFileName)
