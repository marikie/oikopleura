from Alignment import Alignment
from itertools import groupby
import sys


def filterComments(lines):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    ignores lines in a maf file begining with #
    '''
    for line in lines:
        if line.startswith('#'):
            pass
        else:
            yield line


def getMAFBlock(mafLines):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    takes in raw lines from a mafFile, filters comment lines,
    return a list containing lines of a maf block
    i.e. ['a ...', 's ...', 's ...']
    '''
    for k, groupedLines in groupby(filterComments(mafLines), str.isspace):
        if not k:
            mafBlock = [line for line in groupedLines]
            # print(mafBlock)
            yield mafBlock


def getMultiMAFEntries(alignmentFile):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    takes in mafEntries in list of strings (line) form.
    If a query has multiple entries:
    constructs Alignment objects, and yields them.
    '''
    alnFileHandle = open(alignmentFile, 'r')
    # alignments must be in MAF format.
    for rid, mafEntries in groupby(getMAFBlock(alnFileHandle),
                                   lambda x: x[2].split()[1]):
        mafEntries = list(mafEntries)
        alnObjectList = []
        if len(mafEntries) > 1:
            for mafEntry in mafEntries:
                alnObjectList.append(Alignment.fromMAFEntry(mafEntry))
            yield (rid, alnObjectList)


def convert2CoorOnOppositeStrand(alnObj):
    '''
    Convert start and end coordinates of a read
    to start and end coordinates on the reverse strand of read's coordinates
    '''
    start = alnObj.rLength - alnObj.rEnd
    end = alnObj.rLength - alnObj.rStart
    return (start, end)


def getIntronCoord(readStrand, aln1, aln2):
    '''
    Get which strand of read is aligned (readStrand) and its two alignments.
    Return intron start coordinates and intron end coodinates.
    The coordinates include strand info too.
    '''
    if (aln1.gStrand != '+' or aln2.gStrand != '+'):
        print('< gStrand = \"-\" >', file=sys.stderr)
        print(aln1, file=sys.stderr)
        print(aln2, file=sys.stderr)
        print('\n\n', file=sys.stderr)

    # assuming aln.gStrand == '+'
    if ((readStrand == '+' and aln1.rStrand == '+') or
            (readStrand == '-' and aln1.rStrand == '-')):
        intronStart = (aln1.gChr, aln1.gEnd, '+')
    else:
        # ((readStrand == '+' and aln1.rStrand == '-') or
        #   (readStrand == '-' and aln1.rStrand == '+'))
        intronStart = (aln1.gChr, aln1.gStart, '-')

    if ((readStrand == '+' and aln2.rStrand == '+') or
            (readStrand == '-' and aln2.rStrand == '-')):
        intronEnd = (aln2.gChr, aln2.gStart, '+')
    else:
        # ((readStrand == '+' and aln1.rStrand == '-') or
        #   (readStrand == '-' and aln1.rStrand == '+'))
        intronEnd = (aln2.gChr, aln2.gEnd, '-')

    return (intronStart, intronEnd)
