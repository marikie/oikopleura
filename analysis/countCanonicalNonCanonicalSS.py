'''
Calculate the rate of non-canonical splicing signals.
Only count exact splicings.
If multiple reads cross the same junction,
count the junction as "1."

Input: an alignment file (MAF format)
Output: counts of canonical and non-canonical splicing signals
'''
import argparse
from getAlignmentObjs import getMultiMAFEntries
from getSplicingSignalsDistOfExactSplicings import convert2CoorOnOppositeStrand
import sys


def main(alignmentFile):
    intronCoords_SS_dict = {}

    print('Getting all introns...')
    for readID, alignments in getMultiMAFEntries(alignmentFile):
        # pre-sorting...
        # adjust all coordinates to + strand's coordinates
        for aln in alignments:
            if aln.rStrand == '+':
                pass
            else:
                aln.rStart, aln.rEnd = convert2CoorOnOppositeStrand(aln)
        # sort according to read's start position
        alignments.sort(key=lambda aln: aln.rStart)

        # determining the order of alignments...
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
            # go to next readID
            continue

        for aln1, aln2 in zip(alignments, alignments[1:]):
            # if two separate alignments are continuous on the read
            if aln2.rStart - aln1.rEnd == 0:
                # print('exact split')
                # add the intron to the intronCoords_SS_dict
                intronCoords = ((aln1.gChr, aln1.gEnd+1),
                                (aln2.gChr, aln2.gStart))
                ss = (aln1.don, aln2.acc)
                if intronCoords not in intronCoords_SS_dict:
                    intronCoords_SS_dict[intronCoords] = [ss]
                else:
                    intronCoords_SS_dict[intronCoords].append(ss)

    print('counting canonical and non-canonical introns...')
    canonical = 0
    non_canonical = 0
    intronCoords_set = set()
    for intronCoords, sslist in intronCoords_SS_dict.items():
        # print('{} {}'.format(intronCoords, sslist))
        if intronCoords in intronCoords_set:
            # go to next intron
            continue
        else:
            # add intronCoords to intronCoords_set
            intronCoords_set.add(intronCoords)
            # count intron which has only 1 type of splicing signal
            if len(set(sslist)) == 1:
                # canonical splicing signal
                if sslist[0] == ('GT', 'AG') or sslist[0] == ('CT', 'AC'):
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
