# EvoSubster: Let's investigate evolutionary substitution trends across diverse taxonomic groups ─=≡Σ((( つ•̀ω•́)つ !

## Introduction

We aim to observe single-base and double-base substitution trends across diverse organisms, taking into account the influence of neighboring bases. 

Our pipeline’s input should be NCBI genome accession IDs of three closely related species of your choice (we
suggest >80% identity of orthologous DNA): species A as an outgroup, species B, and species C. It downloads
the corresponding genomic FASTA files and, when available, gene annotations.

Pairwise alignments will be performed between _Species A_ and _Species B_, and between _Species A_ and _Species C_. These two sets of alignments will then be merged into a multiple sequence alignment. Our pipeline infers substitutions in _Species B_ and _Species C_ based on the principle of parsimony, and outputs visualizations.

## How to run the pipeline

### 1. Prerequisites

Install the following command-line tools before running any scripts:
- #### NCBI Datasets command-line tools [(https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)

- #### LAST [(https://gitlab.com/mcfrith/last)](https://gitlab.com/mcfrith/last)

- #### yq [(https://github.com/mikefarah/yq)](https://github.com/mikefarah/yq)

- #### jq [(https://jqlang.org)](https://jqlang.org)

- #### R (≥4.0) with the following libraries:
    * stringr
    * RColorBrewer
    * showtext
    * jsonlite
    * curl
    * dplyr
    * ggplot2
    * rlang
    * sysfonts

- #### Python3 (3.8 or later) with standard library modules

### 2. Git Clone the Repository

```bash
git clone https://github.com/marikie/EvoSubster.git scripts
```

### 3. Run The Pipeline

#### 1. Set variables in configuration files

* In `scripts/last/dwl_config.yaml`, set the absolute paths:

```yaml
paths:
  # Change the path to the directory to store downloaded genomes
  base_genomes: "/absolute/path/to/genomes"
```

* In `scripts/last/sbst_config.yaml`, set the absolute paths. (This can be overridden with the `--out-dir` flag, later. See below for more details.):

```yaml
paths:
  # Change the path to the directory to store outputs
  out_dir: "/absolute/path/to/outputs"
```

#### 3. Run the script under the `scripts/last` directory  

#### To start from downloading genomes:

Run the following script:

```text
./trisbst_3spc_fromDwl.sh <today's> <org1 accession ID> <org2 accession ID> <org3 accession ID> [--out-dir /absolute/path/to/outputs]
```

※ The org1 should be the outgroup among the three genomes.  
※ The accession ID is the NCBI accession ID. (e.g. GCA_023078555.1)  
※ The `--out-dir` flag is optional. If not provided, the outputs will be stored in the directory specified in `scripts/last/sbst_config.yaml`.

#### If the genomes are already downloaded:

You can also run the pipeline directly from the downloaded genomes by running the following script:

```text
./trisbst_3spc.sh <today's date> <path to the org1 reference fasta file> <path to the org2 reference fasta file> <path to the org3 reference fasta file> <path to the org1 reference gff file|NO_GFF_FILE> [--out-dir /absolute/path/to/outputs]
```

※ If org1 annotation (GFF file) is unavailable, enter "NO_GFF_FILE"; otherwise, provide the GFF file path.