# ─=≡Σ((( つ•̀ω•́)つ
## Introduction
Let’s investigate evolutionary substitution trends across diverse taxonomic groups!

## How to run the pipeline

### 1. Clone the repository
### 2. Install the dependencies
### 3. Run the pipeline
* Set the variable in the `./last/dwl_config.yaml` file
```yaml
# Change the base_genomes path to the path where you want to store the genomes
base_genomes: "/path/to/your/directory"
```
* Set the variable in the `./last/sbst_config.yaml` file
```yaml
# Change the out_dir path to the path where you want to store the results
out_dir: "/path/to/your/results/directory"
```
* Run the script under the `./last` directory  

If you want to start from downloading the genomes, run `trisbst_3spc_fromDwl.sh`.  
※ The org1 should be the outgroup among the three genomes.  
※ The accession ID is the NCBI accession ID. (e.g. GCA_023078555.1)  
※ The full names should be the genus in small letters followed by the species name starting with a capital letter followed by small letters (e.g. ulvaProlifera)  

```bash
./trisbst_3spc_fromDwl.sh <today's date> <org1 accession ID> <org2 accession ID> <org3 accession ID> <org1 full name> <org2 full name> <org3 full name>
```
If you already have the genomes downloaded, run `trisbst_3spc.sh`.  
```bash
./trisbst_3spc.sh <today's date> <path to the org1 reference fasta file> <path to the org2 reference fasta file> <path to the org3 reference fasta file>
```



