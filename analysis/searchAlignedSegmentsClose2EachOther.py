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
    if (0 <= diff and diff <= allowedLen):
        return True
    else:
        return False


def close2EachOther(end, chr, alnStart, allowedLen):
    if (end[0] == chr and isClose(end[1], alnStart, allowedLen)):
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
        currStart, currEnd = setToPlusCoord(aln)
        
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
                # set prevEnd
                prevEnd = (currChr, currEnd)
                closeSegList = [currAln]
    else:
        if len(closeSegList) > 1:
            yield closeSegList
        else:
            pass


def makeDotplotFiles(alignmentFile, annoFile, annoOf,
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
        lastEnd = setToPlusCoord(closeSegGroup[-1])[1]

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
                if annoOf == 1:
                    subprocess.run(['last-dotplot',
                                    '--labels1=3',
                                    '--labels2=3',
                                    '-a',
                                    annoFile,
                                    outputDirPath + '/' + outputFileName_maf,
                                    outputDirPath + '/' + outputFileName_png])
                elif annoOf == 2:
                    subprocess.run(['last-dotplot',
                                    '--labels1=3',
                                    '--labels2=3',
                                    '-b',
                                    annoFile,
                                    outputDirPath + '/' + outputFileName_maf,
                                    outputDirPath + '/' + outputFileName_png])
                else:
                    raise Exception


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file \
                                sorted by query coordinates')
    parser.add_argument('annotationFile',
                        help='an annotation file')
    parser.add_argument('annoOf',
                        help='1: annotation for the 1st (horizontal) genome, \
                              2: annotation for the 2nd (vertical) genome',
                        type=int)
    parser.add_argument('allowedLen',
                        help='allowed length between aligned segments',
                        type=int)
    parser.add_argument('outputDirPath',
                        help='path of the output directory')
    args = parser.parse_args()
    '''
    MAIN
    '''
    makeDotplotFiles(args.alignmentFile, args.annotationFile, args.annoOf,
                     args.allowedLen, args.outputDirPath)
