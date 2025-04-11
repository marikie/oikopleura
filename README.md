# Let's investigate evolutionary substitution trends across diverse taxonomic groups ─=≡Σ((( つ•̀ω•́)つ !

## Introduction

We aim to observe single-base substitution trends across diverse organisms, taking into account the influence of neighboring bases. To do this, we obtain reference genomes for three closely related species (_Species A_, _Species B_, and _Species C_) from NCBI ([https://www.ncbi.nlm.nih.gov/datasets](https://www.ncbi.nlm.nih.gov/datasets)), designating _Species A_ as the outgroup in their phylogenetic relationship.

Pairwise alignments will be performed between _Species A_ and _Species B_, and between _Species A_ and _Species C_. These two sets of alignments will then be merged into a multiple sequence alignment. We will examine all trinucleotides and infer substitutions in _Species B_ and _Species C_ based on the principle of parsimony.

We also applied two filtering strategies. The first omits isolated alignments using the maf-linked method ([https://gitlab.com/mcfrith/last/-/blob/main/doc/maf-linked.rst](https://gitlab.com/mcfrith/last/-/blob/main/doc/maf-linked.rst)). The second filters out aligned columns with an error probability (i.e., the probability that a base should be aligned to a different part of the genome) greater than 0.01, as described in last-split ([https://gitlab.com/mcfrith/last/-/blob/main/doc/last-split.rst](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-split.rst)).

## How to run the pipeline

### 1. Install Dependencies

#### Install NCBI Datasets command-line tools

[https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)

#### Install LAST

[https://gitlab.com/mcfrith/last](https://gitlab.com/mcfrith/last)

#### Install yq

[https://github.com/mikefarah/yq](https://github.com/mikefarah/yq)

#### Install R libraries

* stringr
* RColorBrewer
* showtext

### 2. Run The Pipeline

#### 1. Set variables in configuration files

* In `./last/dwl_config.yaml`, set the absolute paths:

```yaml
# Directory paths
paths:
  base_genomes: "/absolute/path/to/your/directory" # Change this to your desired genome storage path
  scripts:
    last: "/absolute/path/to/your/last/directory" # Change this to your last directory
```

* In `./last/sbst_config.yaml`, set the absolute paths:

```yaml
# Directory paths
paths:
  # Change the paths of your directories and the one to store results
  out_dir: "/absolute/path/to/your/results/directory" # Change this to your desired output path
  scripts:
    last: "/absolute/path/to/your/last" # Change this to your last directory
    analysis: "/absolute/path/to/your/analysis" # Change this to your analysis directory
    r: "/absolute/path/to/your/R" # Change this to your R directory
```

* In `./last/trisbst_3spc_fromDwl.sh`, set the paths:

```bash
config_file="/absolute/path/to/your/dwl_config.yaml" # Change this to your config file
```

* In `./last/trisbst_3spc.sh`, set the paths:

```bash
config_file="/absolute/path/to/your/sbst_config.yaml" # Change this to your config file
```


#### 2. Run the script under the `./last` directory  

#### To start from downloading genomes:

Run the following script:

```bash
./trisbst_3spc_fromDwl.sh <today's date> <org1 accession ID> <org2 accession ID> <org3 accession ID> <org1 full name> <org2 full name> <org3 full name>
```

※ The org1 should be the outgroup among the three genomes.  
※ The accession ID is the NCBI accession ID. (e.g. GCA_023078555.1)  
※ The full names should be the genus in small letters followed by the species name starting with a capital letter followed by small letters (e.g. ulvaProlifera)  

#### If the genomes are already downloaded:

Run:

```bash
./trisbst_3spc.sh <today's date> <path to the org1 reference fasta file> <path to the org2 reference fasta file> <path to the org3 reference fasta file>
```

※ The parent directory of the reference fasta files should be the same as the full names of the species. (e.g. /path/to/your/directory/ulvaProlifera/GCF_023078555.1_Upr_v1.0_genomic.fna)