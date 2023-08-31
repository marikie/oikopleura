'''
Input:
    A result dir path of searchAlignmentSegmentsClose2EachOther.py
Output:
    For each dir under the input dir,
    read .maf files in /MAF dir,
    and output .png files in /PNG dir.
'''

import argparse
import subprocess
import os


def makeDotPlotFiles(inputDirPath, annoFile_Reference, annoFile_Query):
    p_ls_inDir = subprocess.run(['ls', inputDirPath], capture_output=True)

    subDirs = p_ls_inDir.stdout.decode('utf-8').strip().split('\n')

    for subdir in subDirs:
        outputDirPath = inputDirPath + '/' + subdir + '/PNG'
        p_ls_outDir = subprocess.run(['ls', outputDirPath],
                                     capture_output=True)
        if p_ls_outDir.returcode != 0:
            # make outDir
            subprocess.run(['mkdir', outputDirPath])
        else:
            pass

        # ls subdir/MAF
        p_ls_maf = subprocess.run(['ls', inputDirPath + '/' + subdir + '/MAF'],
                                  capture_output=True)
        mafFiles = p_ls_maf.stdout.decode('utf-8').strip().split('\n')
        if mafFiles[0] != '':
            for maffile in mafFiles:
                pngfile = os.path.splitext(maffile)[0] + '.png'
                # make .png file
                subprocess.run(['python',
                                '../last/last-dotplot_mariko.py',
                                '--sort1=3',
                                '--strands1=1',
                                '--border-color=silver',
                                '--border-pixels=5',
                                '--rot1=v',
                                '--labels1=2',
                                '--labels2=2',
                                '--font-size=10',
                                '-a',
                                annoFile_Reference,
                                '-b',
                                annoFile_Query,
                                maffile,
                                outputDirPath + '/' + pngfile
                                ])
        else:
            pass



subprocess.run(['python',
                '../last/last-dotplot_mariko.py',
                '--labels1=3',
                '--labels2=3',
                '-a',
                annoFile_1,
                '-b',
                annoFile_2,
                outputDirPath + '/' + outputFileName_maf,
                outputDirPath + '/' + outputFileName_png])


if __name__ == '__main__':
    '''
    File Parsing
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('inputDirPath',
                        help='path of the directory, which is \
                        the result directory of \
                        searchAlignedSegmentsClose2EachOther.py')
    args = parser.parse_args()
    '''
    MAIN
    '''
    makeDotPlotFiles(args.inputDirPath)
