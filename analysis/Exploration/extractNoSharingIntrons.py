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
    - clusters which have introns that don't have sharing start and
      end positions
'''
import argparse
import json


def match(intron_1, intron_2):
    '''
    check if intron_1's start or end position
    matches intron_2's start or end position
    '''
    i_1_start = tuple(intron_1['intronStart'].values())
    i_1_end = tuple(intron_1['intronEnd'].values())
    i_2_start_end = (tuple(intron_2['intronStart'].values()),
                     tuple(intron_2['intronEnd'].values()))
    if ((i_1_start in i_2_start_end) or
            (i_1_end in i_2_start_end)):
        return True
    else:
        return False


def hasUniqueIntron(intronList):
    '''
    If there is an intron whose start and end positions doesn't
    match with any other introns in the list,
    return True, otherwise return False
    '''
    no_match = False
    for i, intron in enumerate(intronList):
        for k, intron_c in enumerate(intronList):
            if k == i:
                # do not compare the same element
                # go to next intron_c
                continue
            else:
                if match(intron, intron_c):
                    # go to next intron
                    break
                # if there is no match
                else:
                    # do nothing and go check next intron_c
                    pass
        else:
            no_match = True
            break
    return no_match


def main(inputJasonFile, outputJsonFile):
    # load input file
    with open(inputJasonFile, 'r') as f:
        all_introns = json.load(f)
    # choose introns that don't have sharing
    # start and end positions
    clusters_with_uniqueIntrons = {}
    for clusterID, intronList in all_introns.items():
        if hasUniqueIntron(intronList):
            clusters_with_uniqueIntrons[clusterID] = intronList

    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(clusters_with_uniqueIntrons, f, indent=2)


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
