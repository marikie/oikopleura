'''
* Assuming no overlapped segments on the query
Search aligned segments that are close to each other (<= allowedLen)
on the query's chromosom.
Input: .maf file sorted by query's + strand coordinate
Output: maf files in directories below
            - multiCDSOnOneSeg/MAF
            - nonCDSOnRef_CDSOnQuery/MAF
            - cdsOnRef_nonCDSOnQuery/MAF
            - nonCDSOnRef_nonCDSOnQuery/MAF
            - sameOnRef_sameOnQuery/MAF
            - sameOnRef_diffOnQuery/MAF
            - diffOnRef_sameOnQuery/MAF
            - diffOnRef_diffOnQuery/MAF
'''

import argparse
import subprocess
import pprint as p
# import pandas as pd
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


def getGeneIDsOfOneSeg(opt, aln, annoFile):
    '''
    Returns a set of tuples: (geneID, productName(protein name))
    Elements in the set overlap with input "aln"
    '''
    if opt == 'ref':
        assert aln.gStrand == '+', 'aln.gStrand is supposed be +'
        # get geneName on reference
        # aln.gChr, aln.gStart, aln.gEnd, aln.gStrand(always +)
        annotation = gffpd.read_gff3(annoFile)
        # set coord from inbetween to 1-base
        aln_1base_gStart = aln.gStart + 1
        aln_1base_gEnd = aln.gEnd
        print('seqID: ', aln.gChr)
        print('aln_1base_rStart: ', aln_1base_gStart)
        print('aln_1base_rEnd: ', aln_1base_gEnd)
        overlappings = annotation.overlaps_with(seq_id=aln.gChr, type='CDS',
                                                start=aln_1base_gStart,
                                                end=aln_1base_gEnd)
        ovl_attrcols = overlappings.attributes_to_columns()
        ovl_attrcols_filtered = ovl_attrcols.filter(items=['gene'])
        gene_list = ovl_attrcols_filtered.values.tolist()
        print(type(gene_list))
        p.pprint(gene_list)
        gene_set = set([tuple(glist) for glist in gene_list])

    elif opt == 'query':
        # get geneName on query
        annotation = gffpd.read_gff3(annoFile)
        # set to + strand coord
        alnrStart, alnrEnd = setToPlusCoord(aln)
        # set coord from inbetween to 1-base
        aln_1base_rStart = alnrStart + 1
        aln_1base_rEnd = alnrEnd
        print('seqID: ', aln.rID)
        print('aln_1base_rStart: ', aln_1base_rStart)
        print('aln_1base_rEnd: ', aln_1base_rEnd)
        overlappings = annotation.overlaps_with(seq_id=aln.rID, type='CDS',
                                                start=aln_1base_rStart,
                                                end=aln_1base_rEnd)
        p.pprint(overlappings.df)
        ovl_attrcols = overlappings.attributes_to_columns()
        ovl_attrcols_filtered = ovl_attrcols.filter(items=['Name'])
        cds_list = ovl_attrcols_filtered.values.tolist()
        print('cds_list: ', end='')
        p.pprint(cds_list)
        cds_tuple_list = [tuple(cdslist) for cdslist in cds_list]
        print('cds_tuple_list: ', end='')
        p.pprint(cds_tuple_list)
        gene_tuple_list = []
        for cdstuple in cds_tuple_list:
            genetuple = tuple()
            for cds in cdstuple:
                gene = '.'.join(cds.split('.')[0:-2])
                # print(gene)
                genetuple = genetuple + (gene,)
                # print(genetuple)
            gene_tuple_list.append(genetuple)
        gene_set = set(gene_tuple_list)

    else:
        raise ValueError('opt should be either "ref" or "query"')

    print('gene_set: ', end='')
    p.pprint(gene_set)
    return gene_set


def outputMAFFiles(alignmentFile, annoFile_Ref, annoFile_Query,
                   allowedLen, outputDirPath):
    # print('before subprocess')
    p1 = subprocess.run(['ls', outputDirPath], capture_output=True)
    # print('after subprocess')
    # print(p1.returncode)

    # sub directories
    multiCDSOnOneSeg_DirPath = outputDirPath + '/multiCDSOnOneSeg'
    nonCDSOnRef_CDSOnQuery_DirPath = outputDirPath + '/nonCDSOnRef_CDSOnQuery'
    cdsOnRef_nonCDSOnQuery_DirPath = outputDirPath + '/cdsOnRef_nonCDSOnQuery'
    nonCDSOnRef_nonCDSOnQuery_DirPath = outputDirPath \
        + '/nonCDSOnRef_nonCDSOnQuery'
    sameOnRef_sameOnQuery_DirPath = outputDirPath + '/sameOnRef_sameOnQuery'
    sameOnRef_diffOnQuery_DirPath = outputDirPath + '/sameOnRef_diffOnQuery'
    diffOnRef_sameOnQuery_DirPath = outputDirPath + '/diffOnRef_sameOnQuery'
    diffOnRef_diffOnQuery_DirPath = outputDirPath + '/diffOnRef_diffOnQuery'

    if p1.returncode != 0:
        # make dirs
        subprocess.run(['mkdir', outputDirPath])

        subprocess.run(['mkdir', multiCDSOnOneSeg_DirPath])
        subprocess.run(['mkdir', nonCDSOnRef_CDSOnQuery_DirPath])
        subprocess.run(['mkdir', cdsOnRef_nonCDSOnQuery_DirPath])
        subprocess.run(['mkdir', nonCDSOnRef_nonCDSOnQuery_DirPath])
        subprocess.run(['mkdir', sameOnRef_sameOnQuery_DirPath])
        subprocess.run(['mkdir', sameOnRef_diffOnQuery_DirPath])
        subprocess.run(['mkdir', diffOnRef_sameOnQuery_DirPath])
        subprocess.run(['mkdir', diffOnRef_diffOnQuery_DirPath])

        subprocess.run(['mkdir', multiCDSOnOneSeg_DirPath + '/MAF'])
        subprocess.run(['mkdir', nonCDSOnRef_CDSOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', cdsOnRef_nonCDSOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', nonCDSOnRef_nonCDSOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', sameOnRef_sameOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', sameOnRef_diffOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', diffOnRef_sameOnQuery_DirPath + '/MAF'])
        subprocess.run(['mkdir', diffOnRef_diffOnQuery_DirPath + '/MAF'])
    else:
        pass

    for closeSegGroup in getCloseSegs(alignmentFile, allowedLen):
        print('-----------------closeSegGroup START--------------------')
        # set the outputFileName
        # convet to + strand coord
        firstElemStart = setToPlusCoord(closeSegGroup[0])[0]
        # print('firstStart: ', firstElemStart)
        lastElemEnd = setToPlusCoord(closeSegGroup[-1])[1]
        # print('lastEnd: ', lastElemEnd)
        mafFileName = closeSegGroup[0].rID + '_' + str(firstElemStart) \
            + '-' + str(lastElemEnd) + '.maf'

        genesOnRef = set()
        genesOnQuery = set()
        multiGenesOnOneSeg = False
        for aln in closeSegGroup:
            print('-----------------ALN START-------------------------')
            print('--- genes on ref')
            geneIdsOfOneSegOnRef = getGeneIDsOfOneSeg('ref', aln, annoFile_Ref)
            print('--- genes on query')
            geneIdsOfOneSegOnQuery = getGeneIDsOfOneSeg('query', aln,
                                                        annoFile_Query)
            if (len(geneIdsOfOneSegOnRef) > 1 or
                    len(geneIdsOfOneSegOnQuery) > 1):
                print('--- multiGenesOnOneSeg ON')
                multiGenesOnOneSeg = True
            genesOnRef.update(geneIdsOfOneSegOnRef)
            genesOnQuery.update(geneIdsOfOneSegOnQuery)
            print('-----------------ALN END---------------------------')

        if multiGenesOnOneSeg:
            # add maf file to multiCDSOnOneSeg
            outputDirPathAndmafFileName = multiCDSOnOneSeg_DirPath \
                                            + '/MAF/' + mafFileName
            print('multiGenesOnOneSeg')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) == 0 and len(genesOnQuery) != 0):
            # add maf file to nonCDSOnRef_CDSOnQuery
            outputDirPathAndmafFileName = nonCDSOnRef_CDSOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('nonCDSOnRef_CDSOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) != 0 and len(genesOnQuery) == 0):
            # add maf file to CDSOnRef_nonCDSOnQuery
            outputDirPathAndmafFileName = cdsOnRef_nonCDSOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('cdsOnRef_nonCDSOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) == 0 and len(genesOnQuery) == 0):
            # add maf file to nonCDSOnRef_nonCDSOnQuery
            outputDirPathAndmafFileName = nonCDSOnRef_nonCDSOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('nonCDSOnRef_nonCDSOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) == 1 and len(genesOnQuery) == 1):
            # add maf file to sameOnRef_sameOnQuery
            outputDirPathAndmafFileName = sameOnRef_sameOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('sameOnRef_sameOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) == 1 and len(genesOnQuery) != 1):
            # add maf file to sameOnRef_diffOnQuery
            outputDirPathAndmafFileName = sameOnRef_diffOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('sameOnRef_diffOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) != 1 and len(genesOnQuery) == 1):
            # add maf file to diffOnRef_sameOnQuery
            outputDirPathAndmafFileName = diffOnRef_sameOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('diffOnRef_sameOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        elif (len(genesOnRef) != 1 and len(genesOnQuery) != 1):
            # add maf file to diffOnRef_diffOnQuery
            outputDirPathAndmafFileName = diffOnRef_diffOnQuery_DirPath \
                                            + '/MAF/' + mafFileName
            print('diffOnRef_diffOnQuery')
            p.pprint(genesOnRef)
            p.pprint(genesOnQuery)
        else:
            raise Exception('len(genesOnRef): ' + str(len(genesOnRef))
                            + 'len(genesOnQuery): ' + str(len(genesOnQuery)))

        addMAF2Dir(closeSegGroup, outputDirPathAndmafFileName)
        print('-----------------closeSegGroup END--------------------')


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
                        help='allowed length between aligned segments \
                                on query',
                        type=int)
    parser.add_argument('outputDirPath',
                        help='path of the output directory')
    args = parser.parse_args()
    '''
    MAIN
    '''
    outputMAFFiles(args.alignmentFile, args.annotationFile_Reference,
                   args.annotationFile_Query,
                   args.allowedLen, args.outputDirPath)
