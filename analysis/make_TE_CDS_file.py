'''
Input:
    - a .gff file (annotation)
    - a RepMast.out file (RepeatMasker output file)
Output:
    - combined file
'''
import argparse
import csv


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
            if row[2] == 'CDS':
                # add 5 columns at the beginning 
                newline = ['CDS', row[0], row[3], row[4], row[6]]
                newline.extend(row)
                cdsData.append(newline)
            else:
                pass
        return cdsData


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


def getTEdata(repMaskFile):
    teData = []
    with open(repMaskFile, 'r') as f:
        print('--- Reading RepeatMasker File')
        for row in csv.reader(skipFirstTwoRows(f), delimiter='\t'):
            # row: a string of the whole line
            row_list = [c.split() for c in row][0]
            # row_list: a list of contents in a line
            if isTE(row_list):
                # add 5 columns at the beginning
                if row_list[8]=='+':
                    strand = row_list[8]
                else:
                    strand = '-'
                newline = ['TE', row_list[4], row_list[5], row_list[6], strand]
                newline.extend(row_list)
                teData.append(newline)
    return teData


def writeInOutputFile(cdsData, teData, outputFilePath):
    cdsData.extend(teData)
    combinedData = cdsData

    # sort combinedData
    # by chrName, start pos, end pos, strand
    print('--- Sorting the combined data')
    combinedData.sort(key=lambda r: (r[1], int(r[2]), int(r[3]), r[4]))

    print('--- Writing in the output file')
    with open(outputFilePath, 'w') as f:
        for line in combinedData:
            f.write('\t'.join(line)+'\n')


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('gffFile',
                        help='a .gff file')
    parser.add_argument('repMaskFile',
                        help='a RepMask.out file')
    parser.add_argument('outputFilePath',
                        help='output file path')
    args = parser.parse_args()
    '''
    Read the .gff file
    '''
    cdsData = getCDSdata(args.gffFile)
    '''
    Read the RepMask.out file
    '''
    teData = getTEdata(args.repMaskFile)
    '''
    Write in the output file
    '''
    writeInOutputFile(cdsData, teData, args.outputFilePath)
