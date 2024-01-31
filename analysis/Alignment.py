from itertools import chain


def dictFromStrings(strings):
    """
    from Alignments.py inside JSA. written by Anish Shrestha
    used for Alignment() object initiation when parsing from maf
    """
    pairs = [i.split("=") for i in strings]
    return dict(pairs)


def cigarParts(beg, alignmentColums, end):
    """
    From maf-convert.py inside LAST. written by M.C.Frith.
    """
    if beg:
        yield str(beg) + "H"

    # (doesn't handle translated alignments)
    # uses "read-ahead" technique, aiming to be as fast as possible
    isActive = True
    for x, y in alignmentColums:
        break
    else:
        isActive = False
    while isActive:
        size = 1
        # xxx assumes no gap-gap columns, ignores ambiguous bases

        if x == y:
            for x, y in alignmentColums:
                if x != y:
                    break
                size += 1
            else:
                isActive = False
            yield str(size) + "="
        elif x == "-":
            for x, y in alignmentColums:
                if x != "-":
                    break
                size += 1
            else:
                isActive = False
            yield str(size) + "I"
        elif y == "-":
            for x, y in alignmentColums:
                if y != "-":
                    break
                size += 1
            else:
                isActive = False
            yield str(size) + "D"
        else:
            for x, y in alignmentColums:
                if x == y or x == "-" or y == "-":
                    break
                size += 1
            else:
                isActive = False
            yield str(size) + "X"

    if end:
        yield str(end) + "H"


class Alignment:
    def __init__(self, **kwargs):
        """
        coordinates are in inbetween coordinates
        """
        self.score = kwargs["score"]
        self.sense = kwargs["sense"]
        self.mismap = kwargs["mismap"]
        self.don = kwargs["don"]
        self.acc = kwargs["acc"]

        self.cigar = kwargs["cigar"]

        self.gChr = kwargs["gChr"]
        self.gStart = kwargs["gStart"]
        self.gEnd = kwargs["gEnd"]
        self.gStrand = kwargs["gStrand"]
        self.gLength = kwargs["gLength"]
        self.gSeq = kwargs["gSeq"]

        self.rID = kwargs["rID"]
        self.rStart = kwargs["rStart"]
        self.rEnd = kwargs["rEnd"]
        self.rLength = kwargs["rLength"]
        self.rStrand = kwargs["rStrand"]
        self.rSeq = kwargs["rSeq"]

    @classmethod
    def fromMAFEntry(cls, mafEntry):
        # mafEntry becomes
        # [['a', 'score=...', ...],['s','chr', ...],['s',...]]
        lines = list(map(str.split, mafEntry))

        """
        get "a" line(s) info:
        i.e. score, mismap, sense, don, acc
        """
        # extract the line(s) starting with "a"
        aLines = [i[1:] for i in lines if i[0] == "a"]
        # {'score': 625, 'mismap': 1e-10, 'sense':-4.8 ,...}
        namesAndValues = dictFromStrings(chain(*aLines))
        score = int(namesAndValues["score"])
        mismap = float(namesAndValues["mismap"])
        if "sense" in namesAndValues:
            sense = float(namesAndValues["sense"])
        else:
            sense = None
        if "don" in namesAndValues:
            don = namesAndValues["don"]
        else:
            don = None
        if "acc" in namesAndValues:
            acc = namesAndValues["acc"]
        else:
            acc = None

        """
        get "s" lines info
        """
        sLines = [i for i in lines if i[0] == "s"]
        if not sLines:
            raise Exception("empty alignment")
        if not len(sLines) == 2:
            raise Exception("not pairwise alignment")

        refLine = sLines[0]
        queryLine = sLines[1]

        """
        coordinates are 0-based (which means inbetween)
        """
        gChr = refLine[1]
        gStart = int(refLine[2])
        gEnd = gStart + int(refLine[3])
        gStrand = refLine[4]
        gLength = int(refLine[5])
        gSeq = refLine[6]

        rID = queryLine[1]
        rStrand = queryLine[4]
        rStart = int(queryLine[2])
        rEnd = rStart + int(queryLine[3])
        rLength = int(queryLine[5])
        rSeq = queryLine[6]

        """
        construct CIGAR
        """
        alignmentColums = zip(refLine[-1].upper(), queryLine[-1].upper())
        cigar = "".join(
            cigarParts(rStart, iter(alignmentColums), int(queryLine[5]) - rEnd - 1)
        )

        return cls(
            score=score,
            sense=sense,
            mismap=mismap,
            don=don,
            acc=acc,
            cigar=cigar,
            gChr=gChr,
            gStart=gStart,
            gEnd=gEnd,
            gStrand=gStrand,
            gLength=gLength,
            gSeq=gSeq,
            rID=rID,
            rStart=rStart,
            rEnd=rEnd,
            rLength=rLength,
            rStrand=rStrand,
            rSeq=rSeq,
        )

    def __str__(self):
        toReturn = (
            " ".join(
                [
                    "score=" + str(self.score),
                    "sense=" + str(self.sense),
                    "mismap=" + str(self.mismap),
                    "don=" + str(self.don),
                    "acc=" + str(self.acc),
                ]
            )
            + "\n"
        )
        toReturn += self.cigar + " "
        toReturn += "read length: " + str(self.rLength) + "\n"

        maxLength_ID = len(max([self.gChr, self.rID], key=len))
        maxLength_start = len(max([str(self.gStart), str(self.rStart)], key=len))
        maxLength_end = len(max([str(self.gEnd), str(self.rEnd)], key=len))

        toReturn += self.gChr.ljust(maxLength_ID, " ") + " "
        toReturn += str(self.gStart).rjust(maxLength_start, " ") + " "
        toReturn += str(self.gEnd).rjust(maxLength_end, " ") + " "
        toReturn += " ".join([self.gStrand, self.gSeq]) + "\n"

        toReturn += self.rID.ljust(maxLength_ID, " ") + " "
        toReturn += str(self.rStart).rjust(maxLength_start, " ") + " "
        toReturn += str(self.rEnd).rjust(maxLength_end, " ") + " "
        toReturn += " ".join([self.rStrand, self.rSeq]) + "\n"
        return toReturn

    def _MAF(self):
        # 'a' line
        toReturn = "a "
        toReturn += " ".join(["score=" + str(self.score), "mismap=" + str(self.mismap)])
        if self.sense:
            toReturn += " sense=" + str(self.sense)
        if self.don:
            toReturn += " don=" + self.don
        if self.acc:
            toReturn += " acc=" + self.acc
        toReturn += "\n"
        maxLength_ID = len(max([self.gChr, self.rID], key=len))
        maxLength_start = len(max([str(self.gStart), str(self.rStart)], key=len))
        maxLength_end = len(max([str(self.gEnd), str(self.rEnd)], key=len))
        maxLength_length = len(max([str(self.gLength), str(self.rLength)], key=len))

        # 's' line: genome
        toReturn += "s "
        toReturn += self.gChr.ljust(maxLength_ID, " ") + " "
        toReturn += str(self.gStart).rjust(maxLength_start, " ") + " "
        toReturn += str(self.gEnd - self.gStart).rjust(maxLength_end, " ") + " "
        toReturn += self.gStrand + " "
        toReturn += str(self.gLength).rjust(maxLength_length, " ") + " "
        toReturn += self.gSeq + "\n"

        # 's' line: query
        toReturn += "s "
        toReturn += self.rID.ljust(maxLength_ID, " ") + " "
        toReturn += str(self.rStart).rjust(maxLength_start, " ") + " "
        toReturn += str(self.rEnd - self.rStart).rjust(maxLength_end, " ") + " "
        toReturn += self.rStrand + " "
        toReturn += str(self.rLength).rjust(maxLength_length, " ") + " "
        toReturn += self.rSeq + "\n\n"

        return toReturn

    # To make it possible to use as a key of a dictionary
    # Make it hashable based on the query
    def __hash__(self):
        return hash((self.rID, self.rStart, self.rEnd, self.rStrand))

    def __eq__(self, other):
        return (self.rID, self.rStart, self.rEnd, self.rStrand) == (
            other.rID,
            other.rStart,
            other.rEnd,
            other.rStrand,
        )
