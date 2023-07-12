'''
Input: a fasta file

Search lines start with "@",
then add "/number" (eg. /1) at the end of the lines

Output: print out
'''
import argparse


def main(fastaFile, number):
    with open(fastaFile) as f:
        for line in f:
            if line.startswith('@'):
                print(line.split()[0] + '\\'
                      + str(number))
            else:
                print(line)


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('fastaFile',
                        help='a .fasta file')
    parser.add_argument('number',
                        help='a number to add at the end',
                        type=int)
    args = parser.parse_args()
    '''
    M A I N
    '''
    main(args.fastaFile, args.number)
