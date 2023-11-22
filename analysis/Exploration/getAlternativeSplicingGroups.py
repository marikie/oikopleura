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
            },
            ...
        }
'''
import argparse
import json
from Util import getMultiMAFEntries_all
from Util import getIntronCoord


def getIntronDict(intronJsonFile):
    print('--- Reading intronJsonFile')
    # load the intronJsonFile
    with open(intronJsonFile, 'r') as f:
        intron_dict = json.load(f)

    print('--- Organizing intron_dict')
    for intronCoord, intronInfo in intron_dict.items():
        # add 'numOfReads'
        intron_dict[intronCoord]['numOfReads'] = len(intronInfo['readIDs'])
        # delete 'readIDs' and 'alignments'
        del intron_dict[intronCoord]['readIDs']
        del intron_dict[intronCoord]['alignments']

    print('--- Sorting intron_dict')
    # sort by intron end coord
    dict(sorted(intron_dict.items(),
         key=lambda x:
         (x[1]['intronEnd']['chr'], x[1]['intronEnd']['pos'])))

    return intron_dict


def getAlignmentLists(alignmentFile):
    print('--- Reading alignmentFile')
    alignment_list = []

    for readID, alnObjList in getMultiMAFEntries_all(alignmentFile):
        # prerequisite:
        # alnObjList is already sorted
        # according to + strand's coordinates

        # if the read is non-split
        if len(alnObjList) == 1:
            aln = alnObjList[0]
            alignment_list.append((readID,
                                   [aln],
                                   (aln, aln),
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
                    aln1_start = (aln1.gChr, aln1.gStart)
                    aln1_end = (aln1.gChr, aln1.gEnd)
                    aln2_start = (aln2.gChr, aln2.gStart)
                    aln2_end = (aln2.gChr, aln2.gEnd)
                    leftCoor = min([aln1_start, aln1_end,
                                    aln2_start, aln2_end],
                                   key=lambda a: (a[0], a[1]))
                    rightCoor = max([aln1_start, aln1_end,
                                     aln2_start, aln2_end],
                                    key=lambda a: (a[0], a[1]))
                    if (leftCoor == aln1_start or leftCoor == aln1_end):
                        leftAln = aln1
                    else:
                        leftAln = aln2
                    if (rightCoor == aln1_start or rightCoor == aln1_end):
                        rightAln = aln1
                    else:
                        rightAln = aln2

                    intronStart, intronEnd = getIntronCoord(readStrand,
                                                            aln1, aln2)
                    alignment_list.append((readID,
                                           [aln1, aln2],
                                           (leftAln, rightAln),
                                           (intronStart, intronEnd)))
        print('--- Sorting alignment_list')
        # sort alignment_list by the rightCoor
        alignment_list.sort(key=lambda x: (x[2][1][0], x[2][1][1]))

        return alignment_list


def rightStart(alignmentTuple):
    '''
    returns the start pos of the right-side alignment
    '''
    return (alignmentTuple[2][1].gChr, alignmentTuple[2][1].gStart)


def rightEnd(alignmentTuple):
    '''
    returns the end pos of the right-side alignment
    '''
    return (alignmentTuple[2][1].gChr, alignmentTuple[2][1].gEnd)


def leftStart(alignmentTuple):
    '''
    returns the start pos of the left-side alignment
    '''
    return (alignmentTuple[2][0].gChr, alignmentTuple[2][0].gStart)


def start(intronInfo):
    '''
    returns the start pos of the intron
    '''
    return (intronInfo['intronStart']['chr'],
            intronInfo['intronStart']['pos'])


def end(intronInfo):
    '''
    returns the end pos of the intron
    '''
    return (intronInfo['intronEnd']['chr'],
            intronInfo['intronEnd']['pos'])


def alignedPartsOverlap(alignmentTuple, intronInfo):
    '''
    returns True if there is an alignment overlapping with the intron
    returns False if there is no alignment overlapping with the intron
    '''
    def diff(coord1, coord2):
        assert coord1[0] == coord2[0]
        return coord1[1]-coord2[1]

    overlap = False
    intronStart = (intronInfo['intronStart']['chr'],
                   intronInfo['intronStart']['pos'])
    intronEnd = (intronInfo['intronEnd']['chr'],
                 intronInfo['intronEnd']['pos'])
    intronLeft = min(intronStart, intronEnd)
    intronRight = max(intronStart, intronEnd)
    for aln in alignmentTuple[1]:
        alnStart = (aln.gChr, aln.gStart)
        alnEnd = (aln.gChr, aln.gEnd)
        alnLeft = min(alnStart, alnEnd)
        alnRight = max(alnStart, alnEnd)
        s1 = diff(intronLeft, alnLeft)*diff(intronRight, alnRight)
        s2 = diff(intronLeft, alnRight)*diff(intronRight, alnLeft)
        if intronLeft <= alnRight

def getAlternativeSpilcingGroups(intron_dict, alignment_list, outputFile):
    '''
    alignment_list: a list of (readID, [aln1, aln2], (leftAlnObj, rightAlnObj),
                               (intronStart, intronEnd))
    '''
    print('--- Grouping alignments')

    bookMark = 0
    i = 0
    for intronName, targetIntron in intron_dict.items():
        while (bookMark < len(alignment_list) and
               rightEnd(alignment_list[bookMark]) < start(targetIntron)):
            bookMark += 1
            i = bookMark
            while (bookMark < len(alignment_list) and
                   rightStart(alignment_list[bookMark]) < end(targetIntron)):
                if (alignedPartsOverlap(alignment_list[i], targetIntron)):
                    # add to dict
                    pass
                bookMark += 1
                i = bookMark
            while (i < len(alignment_list) and
                   leftStart(alignment_list[i]) < end(targetIntron)):
                if (alignedPartsOverlap(alignment_list[i], targetIntron)):
                    # add to dict
                    pass
                i += 1


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
    intron_dict = getIntronDict(args.intronJsonFile)

    '''
    Load alignmentFile and sort the alignment data
    '''
    alignment_list = getAlignmentLists(args.alignmentFile)

    '''
    Get alternative splicing info
    '''
    getAlternativeSpilcingGroups(intron_dict, alignment_list, args.outputFile)
