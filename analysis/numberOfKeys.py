'''
Input:
    a json file
Output:
    the number of keys in the input json file (int)
'''
import argparse
import json

if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('jsonFile',
                        help='a json file')
    args = parser.parse_args()
    '''
    MAIN
    '''
    with open(args.jsonFile, 'r') as f:
        d = json.load(f)
        print(len(d.keys()))
