'''
Input: .maf file sorted by query coordinates
Output: dotplot.png files
'''

import argparse
from Util import getMAFBlock
from Alignment import Alignment


def segmentOverlap(a1, b1, a2, b2):
    s1 = (a1 - a2) * (b1 - b2)
    s2 = (a1 - b2) * (b1 - a2)
    # if not no-overlap
    if not (s1 > 0 and s2 > 0):
        return True
    else:
        return False


def overlap(aln, start, end):
    if (aln.rID == start[0] and segmentOverlap(aln.rStart, aln.rEnd,
                                               start[1], end[1])):
        return True
    else:
        return False


def getOvlGroups(alignmentFile):
    alnFileHandle = open(alignmentFile)

    start = None
    end = None
    ovlList = []
    for mafEntry in getMAFBlock(alnFileHandle):
        aln = Alignment.fromMAFEntry(mafEntry)

        if not start:
            start = (aln.rID, aln.rStart)
        if not end:
            end = (aln.rID, aln.rEnd)
        
        if overlap(aln, start, end):
            # add to ovlList
            ovlList.append(aln)
            if (end[0] == aln.rID and end[1] < aln.rEnd):
                # update "end"
                end = (aln.rID, aln.rEnd)
            else:
                pass
        else:
            if len(ovlList) > 1:
                # add ovlList to allGroupsList
                yield ovlList
            else:
                pass
            # new start, end, ovlList
            start = (aln.rID, aln.rStart)
            end = (aln.rID, aln.rEnd)
            ovlList = [aln]
    else:
        if len(ovlList) > 1:
            yield ovlList
        else:
            pass


def makeDotplotFiles(alignmentFile):
    for ovlList in getOvlGroups(alignmentFile):
        for i, aln in enumerate(ovlList):
            if i == 0:
                print('Group start:')
            else:
                pass
            print(aln._MAF())


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file \
                                sorted by query coordinates')
    args = parser.parse_args()
    '''
    MAIN
    '''
    makeDotplotFiles(args.alignmentFile)
