'''
Input:
    - a json file containing clusters of introns
    {clusterID(leftmost intron): [
        {
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
        'splicingSignal':{
            str,
            str
        },
        'reads': int
        },
        {}, ...
    ], ...}
Output:
    - a json file with the same format as input
    - clusters that all introns have reads >= threshold value
'''
import argparse
import json


def allHaveEnoughReads(intronList, threshold):
    '''
    If all intron have reads >= threshold,
    return True, otherwise return False
    '''
    ifAllEnough = False
    for intron in intronList:
        if intron['reads'] < threshold:
            break
    else:
        ifAllEnough = True
    return ifAllEnough


def main(inputJasonFile, outputJsonFile, threshold):
    # load the input file
    with open(inputJasonFile, 'r') as f:
        all_introns = json.load(f)
    # choose clusters that all introns have reads > threshold
    clusters_with_enough_reads = {}
    for clusterID, intronList in all_introns.items():
        if allHaveEnoughReads(intronList, threshold):
            clusters_with_enough_reads[clusterID] = intronList
    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(clusters_with_enough_reads, f, indent=2)


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
