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

p1 = subprocess.run(['ls', outputDirPath], capture_output=True)
# print('after subprocess')
# print(p1.returncode)

# sub directories
multiCDSOnOneSeg_DirPath = outputDirPath + '/multiCDSOnOneSeg'
nonCDSOnRef_CDSOnQuery_DirPath = outputDirPath + '/nonCDSOnRef_CDSOnQuery'
cdsOnRef_nonCDSOnQuery_DirPath = outputDirPath + '/cdsOnRef_nonCDSOnQuery'
nonCDSOnRef_nonCDSOnQuery_DirPath = outputDirPath \
    + '/nonCDSOnRef_nonCDSOnQuery'
sameOnRef_sameOnQuery_DirPath = outputDirPath + '/sameOnRef_sameOnQuery'
sameOnRef_diffOnQuery_DirPath = outputDirPath + '/sameOnRef_diffOnQuery'
diffOnRef_sameOnQuery_DirPath = outputDirPath + '/diffOnRef_sameOnQuery'
diffOnRef_diffOnQuery_DirPath = outputDirPath + '/diffOnRef_diffOnQuery'

if p1.returncode != 0:
    # make dirs
    subprocess.run(['mkdir', outputDirPath])

    subprocess.run(['mkdir', multiCDSOnOneSeg_DirPath])
    subprocess.run(['mkdir', nonCDSOnRef_CDSOnQuery_DirPath])
    subprocess.run(['mkdir', cdsOnRef_nonCDSOnQuery_DirPath])
    subprocess.run(['mkdir', sameOnRef_sameOnQuery_DirPath])
    subprocess.run(['mkdir', sameOnRef_diffOnQuery_DirPath])
    subprocess.run(['mkdir', diffOnRef_sameOnQuery_DirPath])
    subprocess.run(['mkdir', diffOnRef_diffOnQuery_DirPath])

    subprocess.run(['mkdir', multiCDSOnOneSeg_DirPath + '/MAF'])
    subprocess.run(['mkdir', nonCDSOnRef_CDSOnQuery_DirPath + '/MAF'])
    subprocess.run(['mkdir', cdsOnRef_nonCDSOnQuery_DirPath + '/MAF'])
    subprocess.run(['mkdir', sameOnRef_sameOnQuery_DirPath + '/MAF'])
    subprocess.run(['mkdir', sameOnRef_diffOnQuery_DirPath + '/MAF'])
    subprocess.run(['mkdir', diffOnRef_sameOnQuery_DirPath + '/MAF'])
    subprocess.run(['mkdir', diffOnRef_diffOnQuery_DirPath + '/MAF'])
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
