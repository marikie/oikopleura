'''
Input:
    a pickle file of a dict
    key: readID
    value: a list of alignment list
'''
import argparse
import pickle


def main(alignmentPickleFile, input_readID):
    with open(alignmentPickleFile, 'rb') as f:
        readID_alignments = pickle.load(f)

#    print(readID_alignments)
#    for readID, ListofAlnList in readID_alignments.items():
#        print(readID)
#        for alnList in ListofAlnList:
#            for aln in alnList:
#                print(aln._MAF())

    for alnList in readID_alignments[input_readID]:
        for aln in alnList:
            print(aln._MAF())


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentPickleFile',
                        help='a pickle file of a dict\
                        whose key is readID and value\
                        is a list of alignment list')
    parser.add_argument('readID',
                        help='readID')
    args = parser.parse_args()

    '''
    Main
    '''
    main(args.alignmentPickleFile, args.readID)
