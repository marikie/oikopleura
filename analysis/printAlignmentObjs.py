'''
Input: a pickled dictionary (key: readID, value: a list of Alignment objects)
Output: print readID and alignments
'''
import pickle
import argparse

def main(pickleFile):
    with open(pickleFile, 'rb') as f:
        readID_alignments_dict = pickle.load(f)
        for readID, alignments in readID_alignments_dict.items():
            print('< {} >'.format(readID))
            for aln in alignments: print(aln)

if __name__=='__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('pickleFile', help='a picke file: a dictionary, key: readID, value: a list\
                        of Alignment objects')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.pickleFile)
