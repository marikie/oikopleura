'''
Input:
    - a json file containing intron info
    {intronSTRING: {
        'intronStart': {
            'chr': str,
            'pos': int,
            'strand': str
        },
        'intronEnd': {
            'chr': str,
            'pos': int,
            'strand': str
        },
        'splicingSignal': [
            str,
            str
        ],
        'readIDs': [
            str, ...
        ]
    }, ...}
Output:
    - a json file containing a list of clusters
    - a cluster contains overlapping introns
'''
import argparse
import json
from Util import toSTR


def main(intronJsonFile, outputJsonFile):
    # load JSON file
    print('--- loading the json file')
    with open(intronJsonFile, 'r') as f:
        introns = json.load(f)
    # store intron_dict into a list
    print('--- storing dict into a list')
    intronList_plus = []
    intronList_minus = []
    for intron_dict in introns.values():
        if (intron_dict['intronStart']['strand'] !=
            intron_dict['intronEnd']['strand']):
            # do NOT add to the list
            # go to next intron_dict
            continue
        else:
            if intron_dict['intronStart']['strand'] == '+':
                intronList_plus.append(intron_dict)
            else:
                intronList_minus.append(intron_dict)
    # sort intronList
    print('--- sorting the intron lists')
    intronList_plus.sort(key=lambda d: (d['intronStart']['chr'],
                                        d['intronStart']['pos'],
                                        d['intronEnd']['chr'],
                                        d['intronEnd']['pos']))
    intronList_minus.sort(key=lambda d: (d['intronStart']['chr'],
                                         d['intronStart']['pos'],
                                         d['intronEnd']['chr'],
                                         d['intronEnd']['pos']))
    # cluster overlapping introns on the plus strand of chromosome
    overlapping_introns_plus = {}
    k = 0
    for i, intron in enumerate(intronList_plus):
        while (intronList_plus[k]['intronStart']['pos'] <
               intronList_plus[i]['intronEnd']['pos']):


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
