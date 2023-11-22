'''
THIS CODE INCLUDES A BUG.
QUALITY LINE ALSO SOMETIMES STARTS WITH '@'!!

Input: a fastq file

Search lines start with "@",
then add "/number" (eg. /1) at the end of the IDs

Output: print out
'''
import argparse


def main(fastqFile, number):
    with open(fastqFile) as f:
        for line in f:
            if line.startswith('@'):
                print(line.split()[0] + '/'
                      + str(number) + ' '
                      + ' '.join(line.split()[1:]))
            else:
                print(line.rstrip())


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('fastqFile',
                        help='a .fastq file')
    parser.add_argument('number',
                        help='a number to add at the end',
                        type=int)
    args = parser.parse_args()
    '''
    M A I N
    '''
    main(args.fastqFile, args.number)
