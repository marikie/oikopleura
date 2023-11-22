'''
Input: a pickled dictionary (key: readID, value: a list of Alignment objects)
Output: a column of numbers (deletion length distribution)
'''
from getAlignmentObjs import getMultiMAFEntries
import argparse
import re


def main(alignmentFile):
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        for aln in alignments:
            cigarListIter = iter(re.split(r'(\D)', aln.cigar))
            for num, letter in zip(cigarListIter, cigarListIter):
                if letter == 'D':
                    print(num)
                else:
                    pass


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads to\
                              reference in MAF format')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
