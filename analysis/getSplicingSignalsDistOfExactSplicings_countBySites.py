'''
Input: an alignment file (MAF format)
Output:
    Exact Splicing: reads that are spliced-aligned without unaligned
                    segments in the middle
    Count by sites: if there are multiple reads crossing an intron, count
                    its splicing signals only once.
    - print tsv: donor acceptor #splicing events with that donor-acceptor
     (only exact splicings)
'''
from Util import getMultiMAFEntries
from Util import getIntronCoord
from collections import defaultdict
import argparse
import sys


def main(alignmentFile):
    intronCoords_SS_dict = {}
    don_acc_count_dict = defaultdict(lambda: 0)

    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # prerequisite:
        # alignments are already sorted
        # according to + strand's coordinates

        readStrand = None
        # get the order of alignments
        # if the first alignment has donor and doesn't have acceptor
        # or the last alignment doesn't have donor and has acceptor
        if (alignments[0].don and not alignments[0].acc)\
                or (not alignments[-1].don and alignments[-1].acc):
            # set readStrand to '+'
            readStrand = '+'
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
        else:
            # go to next readID
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the read
            # (checking only "Exact Splits")
            if aln2.rStart - aln1.rEnd == 0:
                intronCoord = getIntronCoord(readStrand, aln1, aln2)
                # add to dict
                ss = (aln1.don, aln2.acc)
                # print(ss)
                if intronCoord not in intronCoords_SS_dict:
                    intronCoords_SS_dict[intronCoord] = [ss]
                else:
                    intronCoords_SS_dict[intronCoord].append(ss)

    for intronCoord, ssList in intronCoords_SS_dict.items():
        ssList_upper = list(map(lambda t: (t[0].upper(), t[1].upper()),
                                list(ssList)))
        # if there is only 1 type of splicing signal, count
        if len(set(ssList_upper)) == 1:
            # add to dict
            don_acc_count_dict[ssList_upper[0]] += 1
        # error if there are >= 2 types of splicing signals
        else:
            print('{} {}'.format(intronCoord, ssList_upper), file=sys.stderr)

    print('donor\tacceptor\tcount')
    for don_acc, count in sorted(don_acc_count_dict.items(),
                                 key=lambda x: x[1], reverse=True):
        print(f'{don_acc[0]}\t{don_acc[1]}\t{count}')


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile',
                        help='a .maf alignment file')
    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.alignmentFile)
