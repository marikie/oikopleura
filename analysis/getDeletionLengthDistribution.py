'''
Input: a pickled dictionary (key: readID, value: a list of Alignment objects)
Output: a column of numbers (deletion length distribution)
'''
import pickle
import argparse
import re

def main(pickleFile):
    with open(pickleFile, 'rb') as f:
        readID_alignments_dict = pickle.load(f)
        for alignments in readID_alignments_dict.values():
            for aln in alignments:
                cigarListIter = iter(re.split(r'(\D)', aln.cigar))
                for num, letter in zip(cigarListIter,cigarListIter):
                    if letter=='D': print(num)
                    else: pass

if __name__ == '__main__':
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
