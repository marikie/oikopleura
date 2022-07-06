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
    ! Assuming intronStart and intronEnd are on the same strand of chromosome
Output:
    - a json file with the same format as input
    - clusters which have introns on both strands of chromosome
'''
import argparse
import json


def onBothStrands(intronList):
    strandSet = set()
    for intron in intronList:
        # assuming strands of intronStart and intronEnd are the same
        try:
            if not (intron['intronStart']['strand'] ==
                    intron['intronEnd']['strand']):
                raise Exception
        except Exception:
            print('intronStart and intronEnd are on different strands')
            print(intron)
        strandSet.add(intron['intronStart']['strand'])
    if len(strandSet) == 2:
        return True
    else:
        return False


def main(intronJsonFile, outputJsonFile):
    # load the input file
    with open(intronJsonFile, 'r') as f:
        all_introns = json.load(f)
    # choose introns on both strands of chromosome
    clusters_both_strands = {}
    for clusterID, intronList in all_introns.items():
        if onBothStrands(intronList):
            clusters_both_strands[clusterID] = intronList

    # dump in the outputJsonFile
    with open(outputJsonFile, 'w') as f:
        json.dump(clusters_both_strands, f, indent=2)


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
