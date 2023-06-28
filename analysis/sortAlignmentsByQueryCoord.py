'''
Sort .maf file entries by the coordinates of queries

Input: .maf file
Output: .maf file
'''
import argparse
from Util import getMAFBlock
from Util import convert2CoorOnOppositeStrand
from Alignment import Alignment
import os


def plusStrandStart(aln):
    if aln.rStrand == '+':
        return aln.rStart
    else:
        return convert2CoorOnOppositeStrand(aln)[0]


def minusStrandEnd(aln):
    if aln.rStrand == '+':
        return aln.rEnd
    else:
        return convert2CoorOnOppositeStrand(aln)[1]

    
def main(alignmentFile):
    alnFileHandle = open(alignmentFile)
    # get all the MAF entries
    print('getting all alignments')
    mafEntries_all = []
    for mafEntry in getMAFBlock(alnFileHandle):
        mafEntries_all.append(Alignment.fromMAFEntry(mafEntry))

    # sort mafEntries_all by query's "+ strand" coordinate
    print('sorting alignment entries')
    mafEntries_all.sort(key=lambda x: (x.rID, plusStrandStart(x),
                                       minusStrandEnd(x)))
    # write in outFile
    print('writing in the output file')
    outFilePath = os.path.splitext(alignmentFile)[0] + '_sortedByQuery.maf'
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
