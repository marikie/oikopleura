'''
Input:
    - a .json file of splits (introns)
        {'intronCoord': {
            'intronStart': {
                'chr': str,
                'pos': int,
                'strand': str
            },
            'intronEnd':{
                'chr': str,
                'pos': int,
                'strand': str
            },
            'intronLength': int,
            'splicingSignal': [
                'GT',
                'AG'
            ],
            'readIDs': [
                ...
            ],
            alignments: [
                [alignments],
                [alignments]
            ]
         }, ... }
    - a .maf alignment file including both split and non-split alignments
Output:
    - a .json file
        {'intronCoord': {
            'intronLength': int,
            'splicingSignal': ['GT', 'AG'],
            'numOfReads': int,
            'otherIntrons': [
                {'intronCoord': str,
                'intronLength': int,
                'splicingSignal': ['GT', 'AG'],
                'numOfReads': int,
                'readIDs': [...]
                },
                {}, ...
            ],
            'donSideNonSplitReads': {
                'numOfReads': int,
                'readIDs': [...]
                },
            'accSideNonSplitReads': {
                'numOfReads': int,
                'readIDs': [...]
                }
            'readIDs': [...]
            },
            ...
        }
'''
import argparse
import json
from Util import getMultiMAFEntries_all
from Util import getIntronCoord


def getIntronList(intronJsonFile):
    print('--- Reading intronJsonFile')
    # load the intronJsonFile
    with open(intronJsonFile, 'r') as f:
        intron_dict = json.load(f)

    print('---Sorting intron_list')
    # make a list of values
    # and sort
    intron_list = sorted(list(intron_dict.values()),
                         key=lambda x:
                         ((x['intronStart']['chr'], x['intronStart']['pos']),
                           x['intronStart']['strand']),
                          (x['intronEnd']['chr'], x['intronEnd']['pos'],
                           x['intronEnd']['strand']))
    return intron_list


def getAlignmentList(alignmentFile):
    print('--- Reading alignmentFile')
    alignment_list = []
    for readID, alnObjList in getMultiMAFEntries_all(alignmentFile):
        # prerequisite:
        # alnObjList is already sorted
        # according to + strand's coordinates

        # if the read is non-split 
        if len(alnObjList)==1:
            aln = alnObjList[0]
            alnStart = (aln.gChr, aln.gStart)
            alnEnd = (aln.gChr, aln.gEnd)
            alnLeft = min([alnStart, alnEnd],
                          key=lambda a: (a[0], a[1]))
            alnRight = max([alnStart, alnEnd],
                          key=lambda a: (a[0], a[1]))
            alignment_list.append((readID,
                                   alnObjList,
                                   (alnLeft, alnRight),
                                   (None, None)))
        # if the read is split
        else:
            '''
            only get 'Exact Splits'
            '''
            # get the order of alignments
            # if the first alignment has donor and doesn't have acceptor
            # or the last alignment doesn't have donor and has acceptor
            if (alnObjList[0].don and not alnObjList[0].acc)\
                    or (not alnObjList[-1].don and alnObjList[-1].acc):
                # set readStrand to '+'
                readStrand = '+'
            # if the last alignment has donor and doesn't have acceptor
            # or the first alignment doesn't have donor and has acceptor
            elif (alnObjList[-1].don and not alnObjList[-1].acc)\
                    or (not alnObjList[0].don and alnObjList[0].acc):
                # set readStrand to '-'
                readStrand = '-'
                # reverse the alignments list
                alnObjList.reverse()
            else:
                # go to next readID
                # (do NOT append to alignments_list)
                continue

            for aln1, aln2 in zip(alnObjList, alnObjList[1:]):
                # if two separate alignments are continuous on the reaad
                # (checking only "Exact Splits")
                # do NOT append alignments with inexact splits
                if aln2.rStart - aln1.rEnd == 0:
                    alnStart = (aln1.gChr, aln1.gStart)
                    alnEnd = (aln2.gChr, aln2.gEnd)
                    alnLeft = min([alnStart, alnEnd],
                                  key=lambda a: (a[0], a[1]))
                    alnRight = max([alnStart, alnEnd],
                                  key=lambda a: (a[0], a[1]))
                    intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                    alignment_list.append((readID,
                                           [aln1, aln2],
                                           (alnLeft, alnRight),
                                           (intronStart, intronEnd)))
        print('--- Sorting alignment_list')
        # sort alignment_list
        alignment_list.sort(key=lambda x: ((x[2][0][0], x[2][0][1]),
                                           (x[2][1][0], x[2][1][1])))

        return alignment_list


def getAlternativeSpilcingGroups(intron_list, alignment_list, ourputFile):
    print('--- Making alternative alignment info')

    j = 0
    for i in range(len(intron_list)):
        while()


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('intronJsonFile',
                        help='a .json file containing intron info')
    parser.add_argument('alignmentFile',
                        help='a .maf file containing alignments')
    parser.add_argument('outputFileName',
                        help='name of the output .json file')
    args = parser.parse_args()

    '''
    Load intronJsonFile and sort the intron data
    '''
    intron_list = getIntronList(args.intronJsonFile)

    '''
    Load alignmentFile and sort the alignment data
    '''
    alignment_list = getAlignmentList(args.alignmentFile)

    '''
    Get alternative splicing info
    '''
    getAlternativeSpilcingGroups(intron_list, alignment_list, args.outputFile)
