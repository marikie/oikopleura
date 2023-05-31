'''
Input: a .json file
Output: print keys
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
        for key in d.keys():
            print(key)
