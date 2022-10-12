'''
Input: a jason file with the following format
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
Output:
    - two json files with the same format as input
    - 1: linear splicings (splits on the same chromosome and strand)
      2: trans splicings (splits on different chromosomes or strands)
'''
import argparse
import json


def isLinear(intronInfo):
    if (intronInfo['intronStart']['chr'] == intronInfo['intronEnd']['chr'] and
        intronInfo['intronStart']['strand'] == intronInfo['intronEnd']['strand']):
        return True
    else:
        return False


def main(inputJasonFile):
    # load the input file
    with open(inputJasonFile, 'r') as f:
        all_introns = json.load(f)
    # linear splits -> linearSplits
    # trans splits -> transSplits
    linearSplits = {}
    transSplits = {}
    for intronCoord, intronInfo in all_introns.items():
        if isLinear(intronInfo):
            linearSplits[intronCoord] = intronInfo
        else:
            transSplits[intronCoord] = intronInfo

    # output files
    linearFile = ''.join(inputJasonFile.split('.')[0:-1])+'_linear.json'
    transFile = ''.join(inputJasonFile.split('.')[0:-1])+'_trans.json'
    # dump in output files
    with open(linearFile, 'w') as f:
        json.dump(linearSplits, f, indent=2)
    with open(transFile, 'w') as f:
        json.dump(transSplits, f, indent=2)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('intronJsonFile',
                        help='a json file containing intron info')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.intronJsonFile)
