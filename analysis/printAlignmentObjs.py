'''
Input: an alignment file (MAF format)
Output: print readID and allignments
'''
from getAlignmentObjs import getMultiMAFEntries
import argparse


def main(alignmentFile):
    print('coordinates are inbetween coordinates')
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        print('< {} >'.format(readID))
        for aln in alignments: print(aln)

if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile', help='spliced alignments of reads to reference in MAF format')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
