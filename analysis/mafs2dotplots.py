"""
Input:
    path to the directory which has sub-directories that have /MAF directory under
Output:
    For each sub dir under the input dir,
    read .maf files in /MAF dir,
    and output _geneID.png and _protein.png files in /PNG dir.

"""

import argparse
import subprocess
import os


def makeDotPlotFiles(inputDirPath, annoFile_Reference, annoFile_Query):
    p_ls_inDir = subprocess.run(["ls", inputDirPath], capture_output=True)

    subDirs = p_ls_inDir.stdout.decode("utf-8").strip().split("\n")

    for subdir in subDirs:
        outputDirPath = inputDirPath + "/" + subdir + "/PNG"
        p_ls_outDir = subprocess.run(["ls", outputDirPath], capture_output=True)
        if p_ls_outDir.returncode != 0:
            # make outDir
            subprocess.run(["mkdir", outputDirPath])
        else:
            pass

        # ls subdir/MAF
        p_ls_maf = subprocess.run(
            ["ls", inputDirPath + "/" + subdir + "/MAF"], capture_output=True
        )
        mafFiles = p_ls_maf.stdout.decode("utf-8").strip().split("\n")
        # print(mafFiles)
        if mafFiles[0] != "":
            for maffile in mafFiles:
                pngfile_geneID = os.path.splitext(maffile)[0] + "_geneID.png"
                pngfile_protein = os.path.splitext(maffile)[0] + "_protein.png"
                maffilePath = inputDirPath + "/" + subdir + "/MAF/" + maffile
                # make _geneID.png file
                subprocess.run(
                    [
                        "last-dotplot",
                        "--sort1=3",
                        "--strands1=1",
                        "--border-color=silver",
                        "--border-pixels=5",
                        "--rot1=v",
                        "--labels1=2",
                        "--labels2=2",
                        "--fontsize=10",
                        "-a",
                        annoFile_Reference,
                        "-b",
                        annoFile_Query,
                        maffilePath,
                        outputDirPath + "/" + pngfile_geneID,
                    ]
                )
                # make _protein.png file
                subprocess.run(
                    [
                        "python",
                        "../last/last-dotplot_mariko.py",
                        "--sort1=3",
                        "--strands1=1",
                        "--border-color=silver",
                        "--border-pixels=5",
                        "--rot1=v",
                        "--labels1=2",
                        "--labels2=2",
                        "--fontsize=10",
                        "-a",
                        annoFile_Reference,
                        "-b",
                        annoFile_Query,
                        maffilePath,
                        outputDirPath + "/" + pngfile_protein,
                    ]
                )
        else:
            pass


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "inputDirPath",
        help="path of the directory, which has sub-directories having /MAF directory below",
    )
    parser.add_argument(
        "annoFile_Reference",
        help="path of an annotation file of \
                        the reference",
    )
    parser.add_argument(
        "annoFile_Query",
        help="path of an annotation file of \
                        the query",
    )
    args = parser.parse_args()
    """
    MAIN
    """
    makeDotPlotFiles(args.inputDirPath, args.annoFile_Reference, args.annoFile_Query)
