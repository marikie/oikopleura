import csv
import pandas as pd


def read_file(file_path):
    # Read TSV file into DataFrame
    df = pd.read_csv(file_path, sep="\t")

    # Calculate SbstPerOrig column
    df["SbstPerOrig"] = (df["mutNum"] / df["totalRootNum"]) * 100

    # Select only mutType and SbstPerOrig columns
    return df[["mutType", "SbstPerOrig"]]


######################################
# M A I N
######################################
dataDict = {}
with open("~/biohazard/data/dataList.tsv", "r") as f:
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        if not row["orgName"] or row["orgName"].startswith("#"):
            continue
        dataDict[row["orgName"]] = {"file": row["file"], "taxon": row["taxon"]}


dfList = []
for orgName, data in dataDict.items():
    df = read_file(data["file"])
    dfList.append((orgName, df))
