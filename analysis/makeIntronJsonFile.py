'''
Make a Jason file about Introns.
Only add alignments whose don and acc are known.
Only add exact splicings.

Input: an alignment file (MAF format)
Output: two json files (canonical and non-canonical)
{'intronCoords': {
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
'''
import argparse
from Util import getMultiMAFEntries
from Util import getIntronCoord
import json


def toSTR(intronCoords):
    '''
    intronCoords == ((sChr(str), sPos(int), sStrand(str)),
                     (eChr(str), ePos(int), eStrand(str))
    '''
    startCoord = '_'.join([intronCoords[0][0], str(intronCoords[0][1]),
                           intronCoords[0][2]])
    endCoord = '_'.join([intronCoords[1][0], str(intronCoords[1][1]),
                        intronCoords[1][2]])
    intronCoords_str = '_'.join([startCoord, endCoord])
    return intronCoords_str


def main(alignmentFile, canonical_out, noncanonical_out):
    intron_can_dict = {}
    intron_non_dict = {}

    print('Putting introns into a dict...')
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # prerequisite:
        # alignments are already sorted
        # according to + strand's coordinates

        readStrand = None
        # get the order of alignments
        # if the first alignment has donor and doesn't have acceptor
        # or the last alignment doesn't have donor and has acceptor
        if (alignments[0].don and not alignments[0].acc)\
                or (not alignments[-1].don and alignments[-1].acc):
            # set readStrand to '+'
            readStrand = '+'
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
        else:
            # go to next readID
            # (do NOT append to alignments_list)
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the reaad
            # (checking only "Exact Splits")
            # do NOT append alignments with inexact splits
            if aln2.rStart - aln1.rEnd == 0:
                intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                # add to dict
                intronCoords = (intronStart, intronEnd)
                intronCoords_str = toSTR(intronCoords)
                ss = (aln1.don, aln2.acc)
                if (intronStart[0] == intronEnd[0] and
                        intronStart[2] == intronEnd[2]):
                    intronLength = intronEnd[1] - intronStart[1]
                else:
                    intronLength = None

                # canonical introns
                if ((aln1.don.upper(), aln2.acc.upper()) == (('GT', 'AG')
                                                             or ('CT', 'AC'))):
                    # print('Here {} {}'.format(aln1.don, aln2.acc))
                    if intronCoords_str not in intron_can_dict:
                        intron_can_dict[intronCoords_str] = \
                                {'intronStart': {'chr': intronStart[0],
                                                 'pos': intronStart[1],
                                                 'strand': intronStart[2]},
                                 'intronEnd': {'chr': intronEnd[0],
                                               'pos': intronEnd[1],
                                               'strand': intronEnd[2]},
                                 'intronLength': intronLength,
                                 'splicingSignal': ss,
                                 'readIDs': [readID],
                                 'alignments': [(aln1._MAF().split('\n')[:-1],
                                                 aln2._MAF().split('\n')[:-1])]
                                 }
                    else:
                        intron_can_dict[intronCoords_str]['readIDs'].append(
                            readID
                        )
                        intron_can_dict[intronCoords_str]['alignments'].append(
                            (aln1._MAF().split('\n')[:-1],
                             aln2._MAF().split('\n')[:-1])
                        )
                # non-canonical introns
                else:
                    if intronCoords_str not in intron_non_dict:
                        intron_non_dict[intronCoords_str] = \
                                {'intronStart': {'chr': intronStart[0],
                                                 'pos': intronStart[1],
                                                 'strand': intronStart[2]},
                                 'intronEnd': {'chr': intronEnd[0],
                                               'pos': intronEnd[1],
                                               'strand': intronEnd[2]},
                                 'intronLength': intronLength,
                                 'splicingSignal': ss,
                                 'readIDs': [readID],
                                 'alignments': [(aln1._MAF().split('\n')[:-1],
                                                 aln2._MAF().split('\n')[:-1])]
                                 }
                    else:
                        intron_non_dict[intronCoords_str]['readIDs'].append(
                            readID
                        )
                        intron_non_dict[intronCoords_str]['alignments'].append(
                            (aln1._MAF().split('\n')[:-1],
                             aln2._MAF().split('\n')[:-1])
                        )
    with open(canonical_out, 'w') as f:
        json.dump(intron_can_dict, f, indent=2)
    with open(noncanonical_out, 'w') as f:
        json.dump(intron_non_dict, f, indent=2)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads to\
                              reference in MAF format')
    parser.add_argument('outputJsonFile_canonical',
                        help='an output file for canonical introns \
                        in JSON format')
    parser.add_argument('outputJsonFile_noncanonical',
                        help='an output file for non-canonical introns \
                        in JSON format')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile, args.outputJsonFile_canonical,
         args.outputJsonFile_noncanonical)
