"""
Input:
    - a tab separated file (qgene.qry.rgene.ranno.ref.*.out)
    - an alignment file (the whole genome-to-genome alignment) 
    - a .gff annotation file of reference
    - a .gff annotation file of query

    content of the tab separated file
        $1: oik chromosome (aligned part)
        $2: start
        $3: end
        $4: strand
        $5: lancelet chromosome (aligned part)
        $6: start
        $7: end
        $8: oik chromosome (overlapping annotation) 
        $9: start
        $10: end
        $11: geneID
        $12: strand
        $13: lanc chromosome (overlapping annotation)
        $14: start
        $15: end
        $16: geneID
        $17: strand
        $18: lanc chromosome (the whole "gene" annotation)
        $19: start
        $20: end
        $21: strand
        $22: geneID
        $23: oik chromosome (the whole "gene" annotation)
        $24: start
        $25: end
        $26: strand
        $27: geneID

Output:
    - .png file
"""
import argparse
import subprocess
import csv
import os


def main(tabFile, alignmentFile, refAnnoFile, qryAnnoFile, outputDirPath):
    refGeneAnnoSet = set()
    qryGeneAnnoSet = set()
    with open(tabFile) as f:
        tsvFileContent = csv.reader(f, delimiter="\t")
        for line in tsvFileContent:
            refGeneAnnoSet.add((line[17], line[18], line[19]))
            qryGeneAnnoSet.add((line[22], line[23], line[24]))

    # for r in refGeneAnnoSet:
    #     print("ref: ", r)
    #
    # for q in qryGeneAnnoSet:
    #     print("qry: ", q)
    #
    # print(len(qryGeneAnnoSet))
    assert len(qryGeneAnnoSet) == 1, "There are multiple query gene annotations."

    refGeneAnnoList = list(refGeneAnnoSet)
    refRanges = ""
    for refAnno in refGeneAnnoList:
        refRanges += " -1 " + refAnno[0][4:] + ":" + refAnno[1] + "-" + refAnno[2]

    qryGeneAnnoList = list(qryGeneAnnoSet)
    qryRange = (
        " -2 "
        + qryGeneAnnoList[0][0][4:]
        + ":"
        + qryGeneAnnoList[0][1]
        + "-"
        + qryGeneAnnoList[0][2]
    )

    print(refRanges)
    print(qryRange)
    pngFile = ".".join(os.path.basename(tabFile).split(".")[3:-1]) + ".png"
    subprocess.run(
        [
            "python",
            "/Users/nakagawamariko/biohazard/oikopleura/last/last-dotplot_mariko_1513.py",
            "--sort1=3",
            "--strands1=1",
            "--border-color=silver",
            "--border-pixels=5",
            "--rot1=v",
            "--labels1=2",
            "--labels2=2",
            "--fontsize=10",
            "-a",
            refAnnoFile,
            "-b",
            qryAnnoFile,
            refRanges,
            qryRange,
            alignmentFile,
            outputDirPath + "/" + pngFile,
        ]
    )


if __name__ == "__main__":
    """
    File Parsing
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("tabFile", help="a tab separated file")
    parser.add_argument("alignmentFile", help="a whole genome-to-genome alignment file")
    parser.add_argument("refAnnoFile", help="a .gff annotation file of reference")
    parser.add_argument("qryAnnoFile", help="a .gff annotation file of query")
    parser.add_argument("outputDirPath", help="a path of the output directory")
    args = parser.parse_args()
    """
    MAIN
    """
    try:
        main(
            args.tabFile,
            args.alignmentFile,
            args.refAnnoFile,
            args.qryAnnoFile,
            args.outputDirPath,
        )
    except AssertionError as e:
        print("AssertionError: ", e)
