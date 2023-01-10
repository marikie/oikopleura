'''
Input: an alignment file (MAF format), and readID (str)
Output:
    print out alignments of readID in MAF format
'''
import argparse
from Util import getMultiMAFEntries


def main(alignmentFile, input_readID):
    for readID, alnList in getMultiMAFEntries(alignmentFile):
        if readID == input_readID:
            for aln in alnList:
                print(aln._MAF())


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads to reference\
                        in MAF format')
    parser.add_argument('readID',
                        help='readID')
    args = parser.parse_args()

    '''
    Main
    '''
    main(args.alignmentFile, args.readID)
