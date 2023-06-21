'''
Sort .maf file entries by the coordinates of queries

Input: .maf file
Output: .maf file
'''
import argparse
from Util import getMAFBlock
from Alignment import Alignment
import os

def main(alignmentFile):
    alnFileHandle = open(alignmentFile)
    # get all the MAF entries
    print('getting all alignments')
    mafEntries_all = []
    for mafEntry in getMAFBlock(alnFileHandle):
        mafEntries_all.append(Alignment.fromMAFEntry(mafEntry))

    # sort mafEntries_all by query's coordinate
    print('sorting alignment entries')
    mafEntries_all.sort(key=lambda x: (x.rID, x.rStart, x.rEnd))
   
    # write in outFile
    print('writing in the output file')
    outFilePath = os.path.splittext(alignmentFile)[0] + '_sortedByQuery.maf'
    with open(outFilePath, 'w') as f:
        for alnObj in mafEntries_all:
            f.write(alnObj._MAF())
            f.flush()


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
