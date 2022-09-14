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
    - a jason file with the same format as input
    - introns whose splicing signals are either GT-AG or GA-AG
'''
import argparse
import json


def isGTAG_GAAG(splicingSingalList):
    if ((splicingSingalList[0].upper() == 'GT' and
         splicingSingalList[1].upper() == 'AG') or
        (splicingSingalList[0].upper() == 'GA' and
         splicingSingalList[1].upper() == 'AG')):
        return True
    else:
        return False


def main(inputJasonFile, outputJsonFile):
    # load the input file
    with open(inputJasonFile, 'r') as f:
        all_introns = json.load(f)
    # choose introns whose splicing signals are
    # either GT-AG or GA-AG
    introns_GTAG_GAAG = {}
    for intronCoord, intronInfo in all_introns.items():
        if isGTAG_GAAG(intronInfo['splicingSignal']):
            introns_GTAG_GAAG[intronCoord] = intronInfo
        else:
            pass
    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(introns_GTAG_GAAG, f, indent=2)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('intronJsonFile',
                        help='a json file containing intron info')
    parser.add_argument('outputJsonFile',
                        help='an output json file')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.intronJsonFile, args.outputJsonFile)
