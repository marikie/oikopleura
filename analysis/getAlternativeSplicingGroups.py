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
from Util import getMultiMAFEntries_all


def getIntronList(intronJsonFile):
    pass


def getAlignmentList(alignmentFile):
    pass


def getAlternativeSpilcingGroups(intron_list, alignment_list, ourputFile):
    pass


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
