'''
Input: an alignment file (MAF format)
Output:
    Exact Splicing: reads that are spliced-aligned without unaligned
                    segments in the middle
    - print tsv: donor acceptor #splicing events with that donor-acceptor
     (only exact splicings)
'''
from getAlignmentObjs import getMultiMAFEntries
from collections import namedtuple, defaultdict
import argparse
import sys


def convert2CoorOnOppositeStrand(alnObj):
    '''
    Convert start and end coordinates of a read
    to start and end coordinates on the reverse strand of read's coordinates
    '''
    start = alnObj.rLength - alnObj.rEnd
    end = alnObj.rLength - alnObj.rStart
    return (start, end)


def main(alignmentFile):
    don_acc = namedtuple('don_acc', ['don', 'acc'])
    don_acc_count_dict = defaultdict(lambda: 0)

    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # adjust all coordinates to + strand's coordinates
        for aln in alignments:
            if aln.rStrand == '+':
                pass
            else:
                aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)

        # sort according to read's start position
        alignments.sort(key=lambda aln: aln.rStart)
        # if the first alignment has donor and doesn't have acceptor
        # or the last alignment doesn't have donor and has acceptor
        if (alignments[0].don and not alignments[0].acc)\
                or (not alignments[-1].don and alignments[-1].acc):
            # do nothing
            pass
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # reverse the alignments list
            alignments.sort(reverse=True, key=lambda aln: aln.rStart)
            # adjust all coordinates to - strand's coordinates
            for aln in alignments:
                aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        else:
            # print to stderr
            for aln in alignments:
                print(aln, file=sys.stderr)
            # go to next readID
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the read
            if aln2.rStart - aln1.rEnd == 0:
                # increment the count of its donor and acceptor
                don_acc_count_dict[don_acc(aln1.don, aln2.acc)] += 1

    print('donor\tacceptor\tcount')
    for don_acc, count in don_acc_count_dict.items():
        print(f'{don_acc.don}\t{don_acc.acc}\t{count}')


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
