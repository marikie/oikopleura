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
    - introns that have reads >= threshold value
'''
import argparse
import json


def main(inputJasonFile, outputJsonFile, threshold):
    # load the input file
    with open(inputJasonFile, 'r') as f:
        all_introns = json.load(f)
    # choose introns with reads >= threshold
    introns_with_enough_reads = {}
    for intronCoord, intronInfo in all_introns.items():
        if len(intronInfo['readIDs']) >= threshold:
            introns_with_enough_reads[intronCoord] = intronInfo
    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(introns_with_enough_reads, f, indent=2)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('intronJsonFile',
                        help='a json file containing intron info')
    parser.add_argument('outputJsonFile',
                        help='an output json file')
    parser.add_argument('threshold',
                        help='a threshold value of the number of reaads (int)',
                        type=int)
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.intronJsonFile, args.outputJsonFile, args.threshold)
