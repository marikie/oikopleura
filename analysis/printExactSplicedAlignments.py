'''
Input: an alignment file (MAF format)
Output:
    - print out alignments of reads that are spliced-aligned without unaligned
    segments in the middle
'''
from makeAlignmentObjs import getMultiMAFEntries
from collections import namedtuple
import argparse
import pickle


def main(alignmentFile):
    start_end = namedtuple('start_end', ['start', 'end'])
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # start and end positions on the + strand of read
        start_end_list = []
        for aln in alignments:
            start_end_list.append(start_end(aln.rStart, aln.rEnd))
            # sort according to start positions
            start_end_list.sort(key=lambda s_e: s_e.start)
            # if there are alignments whose aligned segments on the read
            # is continuous, print all the alignments of the read
            if any([True if start_end_list[i+1].start - start_end_list[i].end == 0
                    else False for i in range(len(start_end_list)-1)]):
                for aln in alignments:
                    print(aln)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='spliced alignments of reads to\
                              reference in MAF format')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
