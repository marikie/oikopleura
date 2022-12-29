'''
Input: MAF file
Output: MAF file
    - only non-spliced alignments
    - sorted by ref coord
'''
import argparse
import os
from Util import getMultiMAFEntries_all


def main(alignmentFile):
    non_spliced_list = []
    for alnObjList in getMultiMAFEntries_all(alignmentFile):
        if len(alnObjList) == 1:
            non_spliced_list.append(alnObjList[0])

    # sort
    non_spliced_list.sorted(key=lambda alnObj: (alnObj.gChr,
                                                alnObj.gStart,
                                                alnObj.gEnd))

    # write in outFile
    outFilePath = os.path.splitext(alignmentFile)[0]\
                    + '_non-spliced_only.maf'
    with open(outFilePath, 'w') as f:
        for alnObj in non_spliced_list:
            f.write(alnObj._MAF())
            f.flush()


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
