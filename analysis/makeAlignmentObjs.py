'''
Input: an alignment file (MAF format)
Output: a pickled dictionary (key: readID, value: a list of Alignment objects)
'''
from Alignment import Alignment
from itertools import groupby
import argparse
import pickle
from Util import getMultiMAFEntries


def main(alignmentFile):
    # alignments must be in MAF format.
    '''
    key: readID(str)
    value: a list of Alignment objects
    '''
    readID_alignments_dict = {}
    for readID, alnList in getMultiMAFEntries(alignmentFile):
        # print(readID)
        # for aln in alnList: print(aln)
        if readID in readID_alignments_dict:
            readID_alignments_dict[readID].append(alnList)
        else:
            readID_alignments_dict[readID] = [alnList]

    '''
    pickle readID_alignments_dict
    '''
    with open('./readID_alignments_dict_'+''.join(alignmentFile.split('/')[-1].split('.')[0:-1])
              + '.pickle', 'wb') as f:
        pickle.dump(readID_alignments_dict, f)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads to reference \
                        in MAF format')
    args = parser.parse_args()
    '''
    main
    '''
    main(args.alignmentFile)
