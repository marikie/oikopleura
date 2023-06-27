'''
Input: .maf file sorted by query coordinates
Output: dotplot.png files
'''

import argparse
from Util import getMAFBlock
from Alignment import Alignment
import subprocess
import os


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


def makeDotplotFiles(alignmentFile, outputDirPath):
    # make a dir
    subprocess.run(['mkdir', outputDirPath])
    # change dir to outputDirPath
    subprocess.run(['cd', outputDirPath])

    for ovlGroup in getOvlGroups(alignmentFile):
        outputFileName = ovlGroup[0].rID + '_' + str(ovlGroup[0].rStart) + '-'\
                            + str(ovlGroup[-1].rEnd) + '.png'
        with open(outputDirPath + '/temp.maf', 'a') as f:
            for aln in ovlGroup:
                f.write(aln._MAF())
            else:
                f.flush()
                # cmd: last-dotplot temp.maf outputFileName
                subprocess.run(['last-dotplot', 'temp.maf', outputFileName])
                subprocess.run(['rm', outputDirPath + '/temp.maf'])


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file \
                                sorted by query coordinates')
    parser.add_argument('outputDirPath',
                        help='path of the output directory')
    args = parser.parse_args()
    '''
    MAIN
    '''
    makeDotplotFiles(args.alignmentFile, args.outputDirPath)
