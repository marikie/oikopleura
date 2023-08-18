'''
* Assuming no overlapped segments on the query
Search aligned segments that are close to each other (<= allowedLen)
on the query's chromosom.
Input: .maf file sorted by query's + strand coordinate
Output: sameOnRef_sameOnQuery/mafFiles, diffOnRef_sameOnQuery/mafFiles,
        sameOnRef_diffOnQuery/mafFiles, diffOnRef_diffOnQuery/mafFiles
'''

import argparse
import subprocess
# import pprint as p
import pandas as pd
import gffpandas.gffpandas as gffpd
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


def addMAF2Dir(closeSegGroup, outputDirPathAndFileName):
    with open(outputDirPathAndFileName, 'w') as f:
        for aln in closeSegGroup:
            f.write(aln._MAF())
        f.flush()


def getGeneIDs_anno(opt, aln, annoFile):
    '''
    Returns a set of tuples: (parentID, productName(protein name))
    Elements in the set overlap with input "aln"
    '''
    setOfGenes = set()
    if opt == 'ref':
        # get geneName on reference
        # aln.gChr, aln.gStart, aln.gEnd, aln.gStrand(always +)
        annotation = gffpd.read_gff3(annoFile)
        # set coord from inbetween to 1-base
        aln_1base_gStart = aln.gStart + 1
        aln_1base_gEnd = aln.gEnd
        overlappings = annotation.overlaps_with(seq_id=aln.gChr, type='CDS',
                                                start=aln_1base_gStart,
                                                end=aln_1base_gEnd)
        ovl_attrcolums = overlappings.attributes_to_columns()




    elif opt == 'query':
        # get geneName on query
        annotation = gffpd.read_gff3(annoFile)
    else:
        raise ValueError('opt should be either "ref" or "query"')

    return geneName
def outputMAFFiles(alignmentFile, annoFile_Ref, annoFile_Query,
                    allowedLen, outputDirPath):
    # print('before subprocess')
    p1 = subprocess.run(['ls', outputDirPath], capture_output=True)
    # print('after subprocess')
    # print(p1.returncode)

    # sub directories
    nonCDSOnRef_CDSOnQuery_DirPath = outputDirPath + '/nonCDSOnRef_CDSOnQuery'
    CDSOnRef_nonCDSOnQuery_DirPath = outputDirPath + '/CDSOnRef_nonCDSOnQuery'
    nonCDSOnRef_nonCDSOnQuery_DirPath = outputDirPath \
        + '/nonCDSOnRef_nonCDSOnQuery'
    sameOnRef_sameOnQuery_DirPath = outputDirPath + '/sameOnRef_sameOnQuery'
    sameOnRef_diffOnQuery_DirPath = outputDirPath + '/sameOnRef_diffOnQuery'
    diffOnRef_sameOnQuery_DirPath = outputDirPath + '/diffOnRef_sameOnQuery' 
    diffOnRef_diffOnQuery_DirPath = outputDirPath + '/diffOnRef_diffOnQuery'

    if p1.returncode != 0:
        # make a dirs
        subprocess.run(['mkdir', outputDirPath])
        subprocess.run(['mkdir', sameOnRef_sameOnQuery_DirPath])
        subprocess.run(['mkdir', sameOnRef_diffOnQuery_DirPath])
        subprocess.run(['mkdir', diffOnRef_sameOnQuery_DirPath])
        subprocess.run(['mkdir', diffOnRef_diffOnQuery_DirPath])
    else:
        pass


    for closeSegGroup in getCloseSegs(alignmentFile, allowedLen):
        # set the outputFileName
        # convet to + strand coord
        firstElemStart = setToPlusCoord(closeSegGroup[0])[0]
        # print('firstStart: ', firstElemStart)
        lastElemEnd = setToPlusCoord(closeSegGroup[-1])[1]
        # print('lastEnd: ', lastElemEnd)
        mafFileName = closeSegGroup[0].rID + '_' + str(firstElemStart) \
                            + '-' \
                            + str(lastElemEnd) + '.maf'

        
        genesOnRef = set()
        genesOnQuery = set()
        for aln in closeSegGroup:
            geneIdsOnRef, annoRef = getGeneIDs_anno('ref', aln, annoFile_Ref)
            geneIdsOnQuery, annoRef = getGeneIDs_anno('query', aln,
                                                      annoFile_Query)
            
            genesOnRef.add(geneIdsOnRef)
            genesOnQuery.add(geneIdsOnQuery)

        if (len(genesOnRef) == 0 and len(genesOnQuery) != 0):
            # add maf file to nonCDSOnRef_CDSOnQuery
            outputDirPathAndmafFileName = nonCDSOnRef_CDSOnQuery_DirPath \
                                            + '/' + mafFileName
        elif (len(genesOnRef) != 0 and len(genesOnQuery) == 0):
            # add maf file to CDSOnRef_nonCDSOnQuery
            outputDirPathAndmafFileName = CDSOnRef_nonCDSOnQuery_DirPath \
                                            + '/' + mafFileName
        elif (len(genesOnRef) == 0 and len(genesOnQuery) == 0):
            # add maf file to nonCDSOnRef_nonCDSOnQuery
            outputDirPathAndmafFileName = nonCDSOnRef_nonCDSOnQuery_DirPath \
                                            + '/' + mafFileName

        elif (len(genesOnRef) == 1 and len(genesOnQuery) == 1):
            # add maf file to sameOnRef_sameOnQuery
            outputDirPathAndmafFileName = sameOnRef_sameOnQuery_DirPath \
                                            + '/' + mafFileName
        elif (len(genesOnRef) == 1 and len(genesOnQuery) != 1):
            # add maf file to sameOnRef_diffOnQuery
            outputDirPathAndmafFileName = sameOnRef_diffOnQuery_DirPath \
                                            + '/' + mafFileName
        elif (len(genesOnRef) != 1 and len(genesOnQuery) == 1):
            # add maf file to diffOnRef_sameOnQuery
            outputDirPathAndmafFileName = diffOnRef_sameOnQuery_DirPath \
                                            + '/' + mafFileName
        else:
            # add maf file to diffOnRef_diffOnQuery 
            outputDirPathAndmafFileName = diffOnRef_diffOnQuery_DirPath \
                                            + '/' + mafFileName
        
        addMAF2Dir(closeSegGroup, outputDirPathAndmafFileName)








# def makeDotplotFiles(alignmentFile, annoFile_1, annoFile_2,
#                      allowedLen, outputDirPath):
#     # print('before subprocess')
#     p1 = subprocess.run(['ls', outputDirPath], capture_output=True)
#     # print('after subprocess')
#     # print(p1.returncode)
#     if p1.returncode != 0:
#         # make a dir
#         subprocess.run(['mkdir', outputDirPath])
#
#     for closeSegGroup in getCloseSegs(alignmentFile, allowedLen):
#         # convet to + strand coord
#         firstStart = setToPlusCoord(closeSegGroup[0])[0]
#         print('firstStart: ', firstStart)
#         lastEnd = setToPlusCoord(closeSegGroup[-1])[1]
#         print('lastEnd: ', lastEnd)
#
#         outputFileName_png = closeSegGroup[0].rID + '_' + str(firstStart) \
#                             + '-' \
#                             + str(lastEnd) + '.png'
#         outputFileName_maf = closeSegGroup[0].rID + '_' + str(firstStart) \
#                             + '-' \
#                             + str(lastEnd) + '.maf'
#         with open(outputDirPath + '/' + outputFileName_maf, 'a') as f:
#             for aln in closeSegGroup:
#                 f.write(aln._MAF())
#             else:
#                 # f.write('---- group end ----\n')
#                 f.flush()
#                 # cmd: last-dotplot temp.maf outputFileName
#                 subprocess.run(['last-dotplot',
#                                 '--labels1=3',
#                                 '--labels2=3',
#                                 '-a',
#                                 annoFile_1,
#                                 '-b',
#                                 annoFile_2,
#                                 outputDirPath + '/' + outputFileName_maf,
#                                 outputDirPath + '/' + outputFileName_png])
#

if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file \
                                sorted by query coordinates')
    parser.add_argument('annotationFile_Reference',
                        help='an annotation file for the 1st \
                                (horizontal) genome (reference)')
    parser.add_argument('annotationFile_Query',
                        help='an annotation file for the 2nd \
                                (vertical) genome (query)')
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
