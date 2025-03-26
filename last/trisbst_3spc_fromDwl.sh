#!/bin/bash

module load yq/4.45.1

config_file="/home/mrk/scripts/last/dwl_config.yaml"

# Load YAML configuration using yq
if [ ! -f "$config_file" ]; then
    echo "Configuration file not found!" 1>&2
    exit 1
fi

# Function to get config values using yq
get_config() {
    yq eval "$1" "$config_file"
}

# Get required arguments count from config
argNum=$(get_config '.settings.required_args')
if [ $# -ne $argNum ]; then
    echo "$(get_config '.errors.arg_count' | sed "s/{arg_num}/$argNum/g")" 1>&2
    echo "$(get_config '.errors.usage')" 1>&2
    exit 1
fi

DATE=$1
org1ID=$2
org2ID=$3
org3ID=$4
org1FullName=$5
org2FullName=$6
org3FullName=$7

cd $(get_config '.paths.base_genomes')
for orgFullName in $org1FullName $org2FullName $org3FullName; do
    if [ ! -d "$orgFullName" ]; then
        mkdir "$orgFullName"
    fi
done

# download from NCBIdatase
base_genomes=$(get_config '.paths.base_genomes')
includes=$(get_config '.download.includes'|tr -d ' '|tr '\n' ','|sed 's/,$//')
echo "includes: $includes"

# Create arrays
ids=("$org1ID" "$org2ID" "$org3ID")
names=("$org1FullName" "$org2FullName" "$org3FullName")

# Iterate over both arrays using an index
for i in {0..2}; do
    orgID=${ids[$i]}
    orgFullName=${names[$i]}
    if [ ! -e "$base_genomes/$orgFullName/ncbi_dataset.zip" ]; then
        echo "$(get_config '.messages.download' | sed "s/{org_full}/$orgFullName/g")"
        cd "$base_genomes/$orgFullName"
        
        # Run download and check if it succeeded
        if ! datasets download genome accession "$orgID" --include "$includes"; then
            echo "Error: Failed to download genome for $orgFullName (ID: $orgID)" >&2
            echo "Exiting process..." >&2
            exit 1
        fi
        
        # Verify the downloaded file exists and is not empty
        if [ ! -s "ncbi_dataset.zip" ]; then
            echo "Error: Download completed but ncbi_dataset.zip is empty or missing for $orgFullName" >&2
            echo "Exiting process..." >&2
            exit 1
        fi
        
        echo "Successfully downloaded genome for $orgFullName"
    else
        echo "$(get_config '.messages.already_downloaded' | sed "s/{org_full}/$orgFullName/g")"
    fi
done

echo "All downloads completed successfully"

# move files and delete unnecessary directories
echo "$(get_config '.messages.move_files')"
function processGenomeData() {
    local orgFullName=$1
    local orgID=$2

    cd "$(get_config '.paths.base_genomes')/$orgFullName" || {
        echo "Error: Cannot change directory to $orgFullName" >&2
        return 1
    }

    if [ -z "$(ls *.fna 2>/dev/null)" ]; then
        echo "Processing genome data for $orgFullName..."
        
        # Unzip with error checking
        if ! unzip ncbi_dataset.zip; then
            echo "Error: Failed to unzip data for $orgFullName" >&2
            return 1
        fi

        cd ncbi_dataset/data || {
            echo "Error: Cannot access data directory for $orgFullName" >&2
            return 1
        }

        # Move files with error checking
        mv $(ls -p | grep -v /) "$(get_config '.paths.base_genomes')/$orgFullName" || {
            echo "Error: Failed to move files for $orgFullName" >&2
            return 1
        }

        cd "$orgID" || {
            echo "Error: Cannot access $orgID directory" >&2
            return 1
        }

        mv * "$(get_config '.paths.base_genomes')/$orgFullName" || {
            echo "Error: Failed to move $orgID files" >&2
            return 1
        }

        cd "$(get_config '.paths.base_genomes')/$orgFullName" || return 1
        rm -r ncbi_dataset || {
            echo "Warning: Could not remove ncbi_dataset directory" >&2
        }

        echo "Successfully processed genome data for $orgFullName"
    else
        echo "Genome files already exist for $orgFullName"
    fi
}

# Process each genome sequentially
for i in {0..2}; do
    orgFullName=${names[$i]}
    orgID=${ids[$i]}
    
    echo "Processing genome $((i+1)) of 3: $orgFullName"
    if ! processGenomeData "$orgFullName" "$orgID"; then
        echo "Error: Failed to process genome data for $orgFullName" >&2
        echo "Exiting process..." >&2
        exit 1
    fi
done

echo "All genome data processed successfully"

org1FASTA="$(get_config '.paths.base_genomes')/$org1FullName/$(ls $(get_config '.paths.base_genomes')/$org1FullName | grep $org1ID)"
org2FASTA="$(get_config '.paths.base_genomes')/$org2FullName/$(ls $(get_config '.paths.base_genomes')/$org2FullName | grep $org2ID)"
org3FASTA="$(get_config '.paths.base_genomes')/$org3FullName/$(ls $(get_config '.paths.base_genomes')/$org3FullName | grep $org3ID)"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org3FASTA: $org3FASTA"

echo "Running trisbst_3spc.sh"
echo "bash $(get_config '.paths.scripts.last')/trisbst_3spc.sh $DATE $org1FASTA $org2FASTA $org3FASTA"
bash $(get_config '.paths.scripts.last')/trisbst_3spc.sh $DATE $org1FASTA $org2FASTA $org3FASTA