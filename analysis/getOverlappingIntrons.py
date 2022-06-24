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


def leftTuple(intron_dict):
    return min((intron_dict['intronStart']['chr'],
                intron_dict['intronStart']['pos'],
                intron_dict['intronStart']['strand']),
               (intron_dict['intronEnd']['chr'],
                intron_dict['intronEnd']['pos'],
                intron_dict['intronEnd']['strand']))


def rightTuple(intron_dict):
    return max((intron_dict['intronStart']['chr'],
                intron_dict['intronStart']['pos'],
                intron_dict['intronStart']['strand']),
               (intron_dict['intronEnd']['chr'],
                intron_dict['intronEnd']['pos'],
                intron_dict['intronEnd']['strand']))


def left(intron_dict):
    '''
    return leftmost (smallest) position
    '''
    leftmostPos = min(intron_dict['intronStart']['pos'],
                      intron_dict['intronEnd']['pos'])
    return leftmostPos


def right(intron_dict):
    '''
    return rightmost (largest) position
    '''
    rightmostPos = max(intron_dict['intronStart']['pos'],
                       intron_dict['intronEnd']['pos'])
    return rightmostPos


def toIntronCoord(intron_dict):
    return ((intron_dict['intronStart']['chr'],
             intron_dict['intronStart']['pos'],
             intron_dict['intronStart']['strand']),
            (intron_dict['intronEnd']['chr'],
             intron_dict['intronEnd']['pos'],
             intron_dict['intronEnd']['strand']))


def simple(intron_dict):
    '''
    delete 'readIDs' and add 'reads',
    which contains the number of reads supporting
    the intron
    '''
    intron_dict['reads'] = len(intron_dict.pop('readIDs'))
    return intron_dict


def intronLen(intron_dict):
    '''
    return intron length
    (assuming intron start and end are on the same chromosome)
    '''
    return right(intron_dict) - left(intron_dict)


def main(intronJsonFile, outputJsonFile):
    # load JSON file
    print('--- loading the json file')
    with open(intronJsonFile, 'r') as f:
        introns = json.load(f)
    # store intron_dict into a list
    print('--- storing dict into a list')
    intronList = []
    for intron_dict in introns.values():
        # if trans-splicing
        if (intron_dict['intronStart']['strand'] !=
            intron_dict['intronEnd']['strand'] or
            intron_dict['intronStart']['chr'] !=
                intron_dict['intronEnd']['chr']):
            # do NOT add to the list
            # go to next intron_dict
            continue
        # if intron is too long
        elif (intronLen(intron_dict) > 100):
            # do NOT add to the list
            # go to next intron_dict
            continue
        else:
            intronList.append(intron_dict)
    # sort intronList
    print('--- sorting the intron lists')
    intronList.sort(key=lambda d: (leftTuple(d), rightTuple(d)))
    # print(intronList)

    # cluster overlapping introns
    print('--- clustering the introns')
    overlapping_introns = {}
    k = 0
    for i, intron in enumerate(intronList):
        if i != k:
            # go to next i
            continue
        else:
            k = i+1
            # print(i)
            # print(intronList[i])
            # print(right(intronList[i]))
            while (k < len(intronList)
                    and intronList[k]['intronStart']['chr'] ==
                   intronList[i]['intronStart']['chr']
                    and left(intronList[k]) < right(intronList[i])):
                # print(i, k)
                # print(intronList[k])
                # print(left(intronList[k]))
                leftmostIntron = toSTR(toIntronCoord(intron))
                if leftmostIntron not in overlapping_introns:
                    overlapping_introns[leftmostIntron] = \
                            [simple(intronList[i]), simple(intronList[k])]
                else:
                    overlapping_introns[leftmostIntron].append(
                        simple(intronList[k]))
                k += 1
    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(overlapping_introns, f, indent=2)


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
