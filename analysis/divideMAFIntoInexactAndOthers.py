'''
Input: MAF file
Output: two MAF files
    - _inexact_splits
    - _inexactSplitsRemoved
'''
import argparse
import os
from Util import getMultiMAFEntries_all


def main(alignmentFile):
    out_inexactFilePath = os.path.splitext(alignmentFile)[0]\
                            + '_inexact_splits.maf'
    out_othersFilePath = os.path.splitext(alignmentFile)[0]\
                            + '_inexactSplitsRemoved.maf'
    for readID, alnObjList in getMultiMAFEntries_all(alignmentFile):


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='MAF file')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
