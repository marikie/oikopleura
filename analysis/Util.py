from Alignment import Alignment
from itertools import groupby


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
    try:
        if not (aln1.gStrand == '+' and aln2.gStrand == '+'):
            raise Exception
    except Exception:
        print('< gStrand = \"-\" >')
        print(aln1)
        print(aln2)

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


def getAlignmentData(alignmentFile):
    '''
    return a list of ((readStrand, aln1, aln2), (intronStart, intronEnd))
    return only 'Exact Splits' and alignments with don-acc pairs
    '''
    alignments_list = []
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
                # alignments_list: list of list
                alignments_list.append(((readStrand, aln1, aln2),
                                        (intronStart, intronEnd)))

    return alignments_list


def toSTR(intronCoords):
    '''
    convert intronCoords into string
    intronCoords == ((sChr(str), sPos(int), sStrand(str)),
                     (eChr(str), ePos(int), eStrand(str))
    -> sChr_sPos_sStrand_eChr_ePos_eStrand
    '''
    startCoord = '_'.join([intronCoords[0][0], str(intronCoords[0][1]),
                           intronCoords[0][2]])
    endCoord = '_'.join([intronCoords[1][0], str(intronCoords[1][1]),
                        intronCoords[1][2]])
    intronCoords_str = '_'.join([startCoord, endCoord])
    return intronCoords_str
