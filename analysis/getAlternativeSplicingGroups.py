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


def getAlignmentLists(alignmentFile):
    print('--- Reading alignmentFile')
    nonSplit_alignment_list = []
    split_alignment_list = []

    for readID, alnObjList in getMultiMAFEntries_all(alignmentFile):
        # prerequisite:
        # alnObjList is already sorted
        # according to + strand's coordinates

        # if the read is non-split 
        if len(alnObjList)==1:
            aln = alnObjList[0]
            alnStart = (aln.gChr, aln.gStart)
            alnEnd = (aln.gChr, aln.gEnd)
            leftCoor = min([alnStart, alnEnd],
                          key=lambda a: (a[0], a[1]))
            rightCoor = max([alnStart, alnEnd],
                          key=lambda a: (a[0], a[1]))
            nonSplit_alignment_list.append((readID,
                                            aln,
                                            (leftCoor, rightCoor)))
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
                    aln1_start = (aln1.gChr, aln1.gStart)
                    aln1_end = (aln1.gChr, aln1.gEnd)
                    aln2_start = (aln2.gChr, aln2.gStart)
                    aln2_end = (aln2.gChr, aln2.gEnd)
                    leftPos = min([aln1_start, aln1_end, aln2_start, aln2_end],
                                  key=lambda a: (a[0], a[1]))
                    if (leftPos == aln1_start or leftPos == aln1_end):
                        alnLeft = aln1
                        alnRight = aln2
                    else:
                        alnLeft = aln2
                        alnRight = aln1
                    intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                    split_alignment_list.append((readID,
                                                (aln1, aln2),
                                                (alnLeft, alnRight),
                                                (intronStart, intronEnd)))
        print('--- Sorting nonSplit_alignment_list')
        # sort nonSplit_alignment_list
        nonSplit_alignment_list.sort(key=lambda x: (x[2][0], x[2][1]))
        print('--- Sorting split_alignment_list')
        # sort split_alignment_list
        split_alignment_list.sort(key=lambda x: ((x[2][0].gChr, min(x[2][0].gStart, x[2][0].gEnd)),
                                                 (x[2][1].gChr, min(x[2][1].gStart, x[2][1].gEnd))))

        return nonSplit_alignment_list, split_alignment_list


def getAlternativeSpilcingGroups(intron_list, nonSplit_alignment_list, split_alignment_list, outputFile):
    '''
    nonSplit_alignment_list: a list of (readID, alnObj, (leftCoor, rightCoor))
    split_alignment_list: a list of (readID, (aln1, aln2), (alnLeft, alnRight), (intronStart, intronEnd))
    '''
    print('--- Processing non-split alignments')

    print('--- Processing split alignments')

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
    nonSplit_alignment_list, split_alignment_list = getAlignmentLists(args.alignmentFile)

    '''
    Get alternative splicing info
    '''
    getAlternativeSpilcingGroups(intron_list, nonSplit_alignment_list, split_alignment_list, args.outputFile)
