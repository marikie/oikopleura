'''
Input: an alignment file (MAF format)
Output: a pickled dictionary (key: readID, value: a list of Alignment objects)
'''
from Alignment import Alignment
from itertools import groupby
import argparse

def filterComments(lines):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    ignores lines in a maf file begining with #
    '''
    for l in lines:
        if l.startswith('#'):
            pass
        else: yield l

def getMAFBlock(mafLines):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    takes in raw lines from a mafFile, filters comment lines,
    return a list containing lines of a maf block
    i.e. ['a ...', 's ...', 's ...']
    '''
    for k, groupedLines in groupby(filterComments(mafLines), str.isspace):
        if not k:
            mafBlock = [l for l in groupedLines]
            # print(mafBlock)
            yield mafBlock

def getMultiMAFEntries(mafLines):
    '''
    from Alignments.py in JSA. written by Anish Shrestha.
    takes in mafEntries in list of strings (line) form.
    If a query has multiple entries:
    constructs Alignment objects, and yields them.
    '''
    for rid, mafEntries in groupby(getMAFBlock(mafLines), lambda x: x[2].split()[1]):
        mafEntries = list(mafEntries)
        alnObjectList = []
        if len(mafEntries) > 1:
            for mafEntry in mafEntries:
                alnObjectList.append(Alignment.fromMAFEntry(mafEntry))
            yield(rid, alnObjectList)

def main(alignmentFile):
    alnFileHandle = open(alignmentFile,'r') # alignments must be in MAF format.
    '''
    key: readID(str)
    value: a list of Alignment objects
    '''
    readID_alignments_dict = {}
    for readID, alnList in getMultiMAFEntries(alnFileHandle):
        #print(readID)
        #for aln in alnList: print(aln)
        readID_alignments_dict[readID] = alnList

    '''
    pickle readID_alignments_dict
    '''
    with open('./readID_alignments_dict_'+''.join(alignmentFile.split('/')[-1].split('.')[0:-1])
              + '.pickle', 'wb') as f:
        pickle.dump(readID_alignments_dict, f)

    alnFileHandle.close()

if __name__=='__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('alignmentFile', help='spliced alignments of reads to reference in MAF format')
    args = parser.parse_args()
    '''
    main
    '''
    main(args.alignmentFile)
