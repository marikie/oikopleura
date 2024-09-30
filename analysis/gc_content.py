from Bio import SeqIO
from Bio.SeqUtils import GC
import argparse

def calculate_gc_content(fasta_file):
    total_seq = ""
    for record in SeqIO.parse(fasta_file, "fasta"):
        total_seq += str(record.seq)
    gc_content = GC(total_seq)
    print(f"Total GC content: {gc_content:.2f}%")

# Example usage
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate GC content of sequences in a FASTA file.")
    parser.add_argument("fasta_file", help="Path to the input FASTA file")
    args = parser.parse_args()
    fasta_file = args.fasta_file
    calculate_gc_content(fasta_file)
