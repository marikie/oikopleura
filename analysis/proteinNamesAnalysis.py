# I will first read the uploaded TSV (Tab-Separated Values) file to understand its structure
# and then proceed to analyze the last column of the file.

import pandas as pd

# Load the TSV file
file_path = "~/biohazard/data/lanc_oik_last/lanc_oik_oikCDS_oikGene_lancCDS_lancGene_consistent_20231228.out"

# Assuming there is no header in the file
data = pd.read_csv(file_path, sep="\t", header=None)

# Analyzing the last column of the dataset

# Extract the last column
last_column = data.iloc[:, -1]

# Basic analysis
unique_descriptions = last_column.nunique()
most_frequent_descriptions = last_column.value_counts().head(10)

print("The number of unique descriptions: ", unique_descriptions)
print(most_frequent_descriptions)
