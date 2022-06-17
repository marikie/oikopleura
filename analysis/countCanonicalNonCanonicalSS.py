'''
Calculate the rate of non-canonical splicing signals.
Only count exact splicings.
If multiple reads cross the same junction,
count the junction as "1."

Input: an alignment file (MAF format)
Output: counts of canonical and non-canonical splicing signals
'''
import argparse
from Util import getMultiMAFEntries
from Util import convert2CoorOnOppositeStrand
from Util import getIntronCoord
import sys


def main(alignmentFile):
    intronCoords_SS_dict = {}

    print('Putting introns into a dict...')
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
            # adjust all coordinates to + strand's coordinates
            for aln in alignments:
                if aln.rStrand == '-':
                    aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        # if the last alignment has donor and doesn't have acceptor
        # or the first alignment doesn't have donor and has acceptor
        elif (alignments[-1].don and not alignments[-1].acc)\
                or (not alignments[0].don and alignments[0].acc):
            # set readStrand to '-'
            readStrand = '-'
            # reverse the alignments list
            alignments.reverse()
            # adjust all coordinates to - strand's coordinates
            for aln in alignments:
                if aln.rStrand == '+':
                    aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        else:
            # go to next readID
            # (do NOT append to alignments_list)
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the reaad
            # (checking only "Exact Splits")
            # do NOT append alignments with inexact splits
            if aln2.rStart - aln1.rEnd == 0:
                intronStart, intronEnd = getIntronCoord(readStrand, aln1, aln2)
                # add to dict
                intronCoords = (intronStart, intronEnd)
                ss = (aln1.don, aln2.acc)
                if intronCoords not in intronCoords_SS_dict:
                    intronCoords_SS_dict[intronCoords] = [ss]
                else:
                    intronCoords_SS_dict[intronCoords].append(ss)

    print('counting canonical and non-canonical introns...')
    canonical = 0
    non_canonical = 0
    for intronCoords, sslist in intronCoords_SS_dict.items():
        sslist_upper = list(map(lambda t: (t[0].upper(), t[1].upper()),
                                sslist))
        # count intron which has only 1 type of splicing signal
        if len(set(sslist_upper)) == 1:
            # canonical splicing signal
            if sslist_upper[0] == ('GT', 'AG') or sslist[0] == ('CT', 'AC'):
                canonical += 1
            # non-canonical splicing signal
            else:
                non_canonical += 1
        # introns which have >= 2 types of splicing signals
        else:
            print('{} {}'.format(intronCoords, sslist), file=sys.stderr)

    # print the result
    print('\n\n')
    print('canonical introns: {}'.format(canonical))
    print('non-canonical introns: {}'.format(non_canonical))


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
