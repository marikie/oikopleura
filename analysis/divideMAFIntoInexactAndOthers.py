'''
Input: MAF file
Output: two MAF files
    - _inexact_splits
    - _inexactSplitsRemoved
'''
import argparse
import os
from itertools import pairwise
from Util import getMultiMAFEntries_all
from Util import isExactSplit


def inexactExist(alnObjList):
    inexactFlag = False
    for aln1, aln2 in pairwise(alnObjList):
        if not isExactSplit('+', aln1, aln2):
            inexactFlag = True
        else:
            pass
    if inexactFlag:
        return True
    else:
        return False


def main(alignmentFile):
    '''
    if there is one or more inexact splits in the alnObjList,
    add to containsInexact
    otherwise add to others
    '''
    out_inexactFilePath = os.path.splitext(alignmentFile)[0]\
                            + '_inexact_splits.maf'
    out_othersFilePath = os.path.splitext(alignmentFile)[0]\
                            + '_inexactSplitsRemoved.maf'
    # refresh files
    with open(out_inexactFilePath, 'w'):
        pass
    with open(out_othersFilePath, 'w'):
        pass

    for readID, alnObjList in getMultiMAFEntries_all(alignmentFile):
        # PREREQUISITE:
        # alnObjList is already ordered according to + strand read's coord
        if len(alnObjList) == 1:
            with open(out_othersFilePath, 'a') as othersFile:
                othersFile.write(alnObjList[0]._MAF())
                othersFile.flush()
        else:
            if inexactExist(alnObjList):
                with open(out_inexactFilePath, 'a') as inexactFile:
                    for alnObj in alnObjList:
                        inexactFile.write(alnObj._MAF())
            else:
                with open(out_othersFilePath, 'a') as othersFile:
                    for alnObj in alnObjList:
                        othersFile.write(alnObj._MAF())


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
