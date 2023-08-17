'''
* Assuming no overlapped segments on the query
Input: .maf file sorted by query's + strand coordinate
Output: dotplot.png files
'''

import argparse
import subprocess
from Util import getMAFBlock
from Util import convert2CoorOnOppositeStrand
from Alignment import Alignment


def setToPlusCoord(aln):
    if aln.rStrand == '-':
        # convert coord to + strand coord
        alnStart, alnEnd = convert2CoorOnOppositeStrand(aln)
    else:
        # do nothing
        alnStart, alnEnd = (aln.rStart, aln.rEnd)
    return alnStart, alnEnd


def isClose(prevEnd, currStart, allowedLen):
    diff = currStart - prevEnd
    print('diff: ', diff)
    if (0 <= diff and diff <= allowedLen):
        return True
    else:
        return False


def close2EachOther(end, chr, alnStart, allowedLen):
    if (end[0] == chr and (isClose(end[1], alnStart, allowedLen))):
        return True
    else:
        return False


def getCloseSegs(alignmentFile, allowedLen):
    alnFileHandle = open(alignmentFile)

    prevEnd = None
    allowedLen = 50
    closeSegList = []
    for mafEntry in getMAFBlock(alnFileHandle):
        currAln = Alignment.fromMAFEntry(mafEntry)
        currChr = currAln.rID
        # set coord to + strand coord
        currStart, currEnd = setToPlusCoord(currAln)
        
        # the 1st mafEntry
        if (not prevEnd):
            prevEnd = (currChr, currEnd)
            closeSegList.append(currAln)
            # go to next mafEntry
            continue

        if close2EachOther(prevEnd, currChr, currStart, allowedLen):
            # add to closeSegList
            closeSegList.append(currAln)
            # update prevEnd
            prevEnd = (currChr, currEnd)
        else:
            if len(closeSegList) > 1:
                # add ovlList to allGroupsList
                yield closeSegList
            else:
                pass
            # set prevEnd
            prevEnd = (currChr, currEnd)
            closeSegList = [currAln]
    else:
        if len(closeSegList) > 1:
            yield closeSegList
        else:
            pass


def makeDotplotFiles(alignmentFile, annoFile_1, annoFile_2,
                     allowedLen, outputDirPath):
    # print('before subprocess')
    p1 = subprocess.run(['ls', outputDirPath], capture_output=True)
    # print('after subprocess')
    # print(p1.returncode)
    if p1.returncode != 0:
        # make a dir
        subprocess.run(['mkdir', outputDirPath])

    for closeSegGroup in getCloseSegs(alignmentFile, allowedLen):
        # convet to + strand coord
        firstStart = setToPlusCoord(closeSegGroup[0])[0]
        print('firstStart: ', firstStart)
        lastEnd = setToPlusCoord(closeSegGroup[-1])[1]
        print('lastEnd: ', lastEnd)

        outputFileName_png = closeSegGroup[0].rID + '_' + str(firstStart) \
                            + '-' \
                            + str(lastEnd) + '.png'
        outputFileName_maf = closeSegGroup[0].rID + '_' + str(firstStart) \
                            + '-' \
                            + str(lastEnd) + '.maf'
        with open(outputDirPath + '/' + outputFileName_maf, 'a') as f:
            for aln in closeSegGroup:
                f.write(aln._MAF())
            else:
                # f.write('---- group end ----\n')
                f.flush()
                # cmd: last-dotplot temp.maf outputFileName
                subprocess.run(['python ~/scripts/last/last-dotplot_mariko.py',
                                '--labels1=3',
                                '--labels2=3',
                                '-a',
                                annoFile_1,
                                '-b',
                                annoFile_2,
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
    parser.add_argument('annotationFile_1',
                        help='an annotation file for the 1st \
                                (horizontal) genome')
    parser.add_argument('annotationFile_2',
                        help='an annotation file for the 2nd \
                                (vertical) genome')
    parser.add_argument('allowedLen',
                        help='allowed length between aligned segments',
                        type=int)
    parser.add_argument('outputDirPath',
                        help='path of the output directory')
    args = parser.parse_args()
    '''
    MAIN
    '''
    makeDotplotFiles(args.alignmentFile, args.annotationFile_1,
                     args.annotationFile_2,
                     args.allowedLen, args.outputDirPath)
