'''
Input:
    - a TE_CDS_tableFile
      (a combined file of .gff and RepMask.out)
    - a .maf file
Output:
    - output.out
        Find splits that have TE and CDS on both intron start
        and intron end. Print out MAF entries and TE&CDS rows.
            - MAF entries from .maf file
            - TE & CDS rows from the combined file
    - output.maf
        MAF entries of such splits as above
'''
import argparse
import csv
from Util import getMultiMAFEntries
from Util import getIntronCoord


def getTE_CDS_TableData(te_cds_tableFile):
    pass


def getAlignmentData(alignmentFile):
    pass


def getTE_CDSsplits(te_cds_Data, alignments_list, outputFileName):
    pass


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('te_cds_tableFile',
                        help='an output file of RepeatMasker')
    parser.add_argument('alignmentFile',
                        help='a .maf file')
    parser.add_argument('outputFileName',
                        help='output-file-path/output-file-name-without-\
                        filename-extension')
    args = parser.parse_args()
    '''
    Read the cds file
    '''
    te_cds_Data = getTE_CDS_TableData(args.te_cds_tableFile)
    '''
    Read the alignment file
    '''
    alignments_list = getAlignmentData(args.alignmentFile)
    '''
    Get TE-TE splits
    '''
    getTE_CDSsplits(te_cds_Data, alignments_list, args.outputFileName)
