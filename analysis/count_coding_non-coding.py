"""
Input:
        - A .bed file with the count of CDS overlap at the last column
        - A .tsv file with the list of sbst and original trinuc counts for each sbstType

Output:
        - A tsv file with the list of sbst, original trinuc, coding, non-coding counts for each sbstType
"""

import pandas as pd
import collections as col
import argparse
import os


def check_counts(tsv_df):
    for index, row in tsv_df.iterrows():
        mut_num = row["mutNum"]
        coding_count = row["coding"]
        non_coding_count = row["non-coding"]
        mut_type = row["mutType"]

        if mut_num != coding_count + non_coding_count:
            raise ValueError(
                f"Error in row {index} for mutType {mut_type}: mutNum ({mut_num}) does not equal coding ({coding_count}) + non-coding ({non_coding_count})"
            )
    else:
        print("* All rows: mutNum == coding + non-coding")


def makeAnnoTsv(bedFile, tsvFile, outputFilePath):
    # read bed file
    bed_df = pd.read_csv(bedFile, sep="\t")

    # read tsv file
    tsv_df = pd.read_csv(tsvFile, sep="\t")

    # Initialize a dictionary to store counts for each pattern in the 8th column
    coding_counts = col.Counter()
    nonCoding_counts = col.Counter()

    # Iterate over each row in the DataFrame
    for row in bed_df.itertuples(index=False):
        pattern = row[7]  # Get the pattern from the 8th column
        is_coding = int(row[-1]) > 0  # Check if the last column indicates coding

        if is_coding:
            coding_counts[pattern] += 1
        else:
            nonCoding_counts[pattern] += 1

    # Add 'coding' and 'non-coding' columns to tsv_df
    tsv_df["coding"] = tsv_df["mutType"].apply(lambda t: coding_counts.get(t, 0))
    tsv_df["non-coding"] = tsv_df["mutType"].apply(lambda t: nonCoding_counts.get(t, 0))

    check_counts(tsv_df)
    # Save the updated DataFrame to the output file
    tsv_df.to_csv(outputFilePath, sep="\t")


def get_default_output_file_names(tsvFile):
    # file name without extension
    tsvFileName = os.path.splitext(os.path.basename(tsvFile))[0]
    # Get the path before the filename at the end
    path_before_filename = os.path.dirname(tsvFile)
    outFileName = f"{tsvFileName}_annot.tsv"
    outFilePath = os.path.join(path_before_filename, outFileName)
    return outFilePath


if __name__ == "__main__":
    """
    parse arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "bedFile", help="a .bed file with the count of CDS overlap at the last column"
    )
    parser.add_argument(
        "tsvFile",
        help="a .tsv file with the list of sbst and original trinuc counts for each sbstType",
    )
    parser.add_argument(
        "-o",
        "--outputFilePath",
        help="a .tsv file with the list of sbst, original trinuc, coding, non-coding counts for each sbstType",
    )
    args = parser.parse_args()

    bedFile = args.bedFile
    tsvFile = args.tsvFile
    outputFilePath = args.outputFilePath or get_default_output_file_names(tsvFile)

    makeAnnoTsv(bedFile, tsvFile, outputFilePath)
