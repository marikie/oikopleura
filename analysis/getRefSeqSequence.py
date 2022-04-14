'''
Input:
    - a fasta file of a reference genome
    - chromsom name (str)
    - sequence start (int)
    - sequence end (int)
Output:
    - the sequence
'''
import argparse
from Bio import SeqIO

def main(fastaFile, chrName, start, end):
    refg_dict = SeqIO.to_dict(SeqIO.parse(fastaFile, 'fasta'))
    print(refg_dict[chrName].seq[start:(end+1)])

if __name__=='__main__':
    '''
    Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('fastaFile', help='a fasta file of a reference genome')
    parser.add_argument('chrName', help='chromesome name')
    parser.add_argument('start', type=int, help='starting position')
    parser.add_argument('end', type=int, help='ending position')

    args = parser.parse_args()
    '''
    MAIN
    '''
    main(args.fastaFile, args.chrName,  args.start, args.end)
