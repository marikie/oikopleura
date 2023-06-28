'''
Input: .maf file sorted by query coordinates
Output: dotplot.png files
'''

import argparse
from Util import getMAFBlock
from Alignment import Alignment
import subprocess
from Util import convert2CoorOnOppositeStrand


def segmentOverlap(a1, b1, a2, b2):
    s1 = (a1 - a2) * (b1 - b2)
    s2 = (a1 - b2) * (b1 - a2)
    # if not no-overlap
    if ((not (s1 > 0 and s2 > 0)) and (not (s1 > 0 and s2 == 0))):
        return True
    else:
        return False


def overlap(alnrID, alnStart, alnEnd, start, end):
    if (alnrID == start[0] and segmentOverlap(alnStart, alnEnd,
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
        # set coord to + strand coord
        if aln.rStrand == '-':
            # convert coord to + strand coord
            alnStart, alnEnd = convert2CoorOnOppositeStrand(aln)
        else:
            alnStart, alnEnd = (aln.rStart, aln.rEnd)

        if not start:
            start = (aln.rID, alnStart)
        if not end:
            end = (aln.rID, alnEnd)
        
        if overlap(aln.rID, alnStart, alnEnd, start, end):
            # add to ovlList
            ovlList.append(aln)
            if (end[0] == aln.rID and end[1] < alnEnd):
                # update "end"
                end = (aln.rID, alnEnd)
            else:
                pass
        else:
            if len(ovlList) > 1:
                # add ovlList to allGroupsList
                yield ovlList
            else:
                # print('ovlList <= 1')
                pass
            # new start, end, ovlList
            start = (aln.rID, alnStart)
            end = (aln.rID, alnEnd)
            ovlList = [aln]
    else:
        if len(ovlList) > 1:
            yield ovlList
        else:
            pass


def makeDotplotFiles(alignmentFile, outputDirPath):
    p1 = subprocess.run(['ls', outputDirPath], check=False)
    if p1.returncode != 0:
        # make a dir
        subprocess.run(['mkdir', outputDirPath])

    for ovlGroup in getOvlGroups(alignmentFile):
        if ovlGroup[0].rStrand == '-':
            # convet to + strand coord
            firstStart = convert2CoorOnOppositeStrand(ovlGroup[0])[0]
        else:
            firstStart = ovlGroup[0].rStart

        if ovlGroup[-1].rStrand == '-':
            # convert to + strand coord
            lastEnd = convert2CoorOnOppositeStrand(ovlGroup[-1])[1]
        else:
            lastEnd = ovlGroup[-1].rEnd

        outputFileName_png = ovlGroup[0].rID + '_' + str(firstStart) \
                            + '-' \
                            + str(lastEnd) + '.png'
        outputFileName_maf = ovlGroup[0].rID + '_' + str(firstStart) \
                            + '-' \
                            + str(lastEnd) + '.maf'
        with open(outputDirPath + '/' + outputFileName_maf, 'a') as f:
            for aln in ovlGroup:
                f.write(aln._MAF())
            else:
                # f.write('---- group end ----\n')
                f.flush()
                # cmd: last-dotplot temp.maf outputFileName
                subprocess.run(['last-dotplot',
                                '--labels1=3',
                                '--labels2=3',
                                outputDirPath + '/' + outputFileName_maf,
                                outputDirPath + '/' + outputFileName_png])


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
