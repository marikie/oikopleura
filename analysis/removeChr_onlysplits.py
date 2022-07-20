'''
Input:
    - a .maf file
    - the part of the name of the chromosome you want to remove
    (names including the input name are removed)
Output:
    - alignments in maf format
'''
import argparse
from Util import getMultiMAFEntries


def chrExist(alignments, chromosomeName):
    for aln in alignments:
        if chromosomeName in aln.gChr:
            return True
    else:
        return False


def main(alignmentFile, chromosomeName):
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        if chrExist(alignments, chromosomeName):
            # go to next mafEntry
            continue
        else:
            for aln in alignments:
                print(aln._MAF())


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf file')
    parser.add_argument('chromosomeName',
                        help='name of the chromosome you want to remove (names\
                        including the input name are removed)')
    args = parser.parse_args()
    '''
    M A I N
    '''
    main(args.alignmentFile, args.chromosomeName)

