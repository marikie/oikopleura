#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAST_DIR="$SCRIPT_DIR"

LAST_DIR="${LAST_DIR_OVERRIDE:-$LAST_DIR}"

PATH="$LAST_DIR:$PATH"

config_file="$SCRIPT_DIR/dwl_config.yaml"
# Load YAML configuration using yq
if [ ! -f "$config_file" ]; then
    echo "Configuration file not found!" 1>&2
    exit 1
fi
# Function to get config values using yq
get_config() {
    yq eval "$1" "$config_file"
}

# Function to derive organism full name from NCBI Datasets summary JSON
# - Writes summary JSON to "$base_genomes/<orgFullName>/<accession>.json" when configured
# - Base name: reports[0].organism.organism_name (spaces -> underscores)
# - If infraspecific_names exists, append all values joined by '_'
get_org_full_name_from_id() {
    local accession="$1"
    local tmp_json
    tmp_json=$(mktemp) || {
        echo "Error: Unable to create temporary file for $accession summary." >&2
        return 1
    }

    # Require jq
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: 'jq' is required but not found in PATH." >&2
        rm -f "$tmp_json"
        return 1
    fi

    # Fetch summary JSON
    if ! datasets summary genome accession "$accession" > "$tmp_json"; then
        echo "Error: Failed to run 'datasets summary' for $accession" >&2
        rm -f "$tmp_json"
        return 1
    fi

    # Parse organism name
    local base_name
    base_name=$(jq -r 'try .reports[0].organism.organism_name catch ""' "$tmp_json")
    if [ -z "$base_name" ] || [ "$base_name" = "null" ]; then
        echo "Warning: '.reports[0].organism.organism_name' not found in temporary summary; using accession $accession" >&2
        base_name="$accession"
    fi
    base_name=${base_name// /_}

    # Parse infraspecific names (optional)
    local infra
    infra=$(jq -r 'try ([.reports[0].organism.infraspecific_names[]] | map(tostring) | join("_")) catch ""' "$tmp_json")
    infra=${infra// /_}

    local calculated_full_name
    if [ -n "$infra" ] && [ "$infra" != "null" ]; then
        calculated_full_name="${base_name}_${infra}"
    else
        calculated_full_name="$base_name"
    fi

    # Determine final JSON location
    local destination_json=""
    if [ -n "$base_genomes" ] && [ "$base_genomes" != "null" ]; then
        local dest_dir="$base_genomes/$calculated_full_name"
        if ! mkdir -p "$dest_dir"; then
            echo "Error: Unable to create directory $dest_dir for storing summary JSON." >&2
            rm -f "$tmp_json"
            return 1
        fi
        destination_json="$dest_dir/${accession}.json"
    else
        destination_json="${accession}.json"
    fi

    if ! mv "$tmp_json" "$destination_json"; then
        echo "Warning: Failed to move summary JSON to $destination_json; attempting to copy instead." >&2
        if ! cp "$tmp_json" "$destination_json"; then
            echo "Error: Unable to place summary JSON for $accession." >&2
            rm -f "$tmp_json"
            return 1
        fi
        rm -f "$tmp_json"
    fi

    echo "$calculated_full_name"
}

# Parse positional arguments
DATE="$1"
org1ID="$2"
org2ID="$3"
org3ID="$4"
org1FullName="$5"
org2FullName="$6"
org3FullName="$7"


# Check minimally required arguments (DATE and 3 accessions)
if [ -z "$DATE" ] || [ -z "$org1ID" ] || [ -z "$org2ID" ] || [ -z "$org3ID" ]; then
    echo "$(get_config '.errors.arg_count' | sed "s/{arg_num}/$(get_config '.settings.required_args')/g")" >&2
   echo "$(get_config '.errors.usage')" >&2
   exit 1
fi

base_genomes=$(get_config '.paths.base_genomes')
if [ -z "$base_genomes" ] || [ "$base_genomes" = "null" ]; then
    echo "Error: .paths.base_genomes is not set in dwl_config.yaml" >&2
    exit 1
fi

if [ ! -d "$base_genomes" ]; then
    mkdir -p "$base_genomes" || {
        echo "Error: Unable to create base genomes directory at $base_genomes" >&2
        exit 1
    }
fi

# Auto-generate org full names from NCBI Datasets summary if not provided
if [ -z "$org1FullName" ]; then
    org1FullName=$(get_org_full_name_from_id "$org1ID") || exit 1
    echo "Derived org1FullName: $org1FullName"
else
    org1FullName="${org1FullName// /_}"  # Replace spaces with underscores
    echo "Using provided org1FullName: $org1FullName"
fi
if [ -z "$org2FullName" ]; then
    org2FullName=$(get_org_full_name_from_id "$org2ID") || exit 1
    echo "Derived org2FullName: $org2FullName"
else
    org2FullName="${org2FullName// /_}"  # Replace spaces with underscores
    echo "Using provided org2FullName: $org2FullName"
fi
if [ -z "$org3FullName" ]; then
    org3FullName=$(get_org_full_name_from_id "$org3ID") || exit 1
    echo "Derived org3FullName: $org3FullName"
else
    org3FullName="${org3FullName// /_}"  # Replace spaces with underscores
    echo "Using provided org3FullName: $org3FullName"
fi

cd "$base_genomes" || {
    echo "Error: Cannot change directory to $base_genomes" >&2
    exit 1
}
for orgFullName in $org1FullName $org2FullName $org3FullName; do
    if [ ! -d "$orgFullName" ]; then
        mkdir "$orgFullName"
    fi
done

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

fasta_pat1=$(get_config '.patterns.fasta' | sed "s/{org_id}/$org1ID/g")
fasta_pat2=$(get_config '.patterns.fasta' | sed "s/{org_id}/$org2ID/g")
fasta_pat3=$(get_config '.patterns.fasta' | sed "s/{org_id}/$org3ID/g")

org1FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org1FullName/$fasta_pat1" | head -n1)
org2FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org2FullName/$fasta_pat2" | head -n1)
org3FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org3FullName/$fasta_pat3" | head -n1)

# Fallback to first *.fna if accession-specific pattern not found
if [ -z "$org1FASTA" ]; then org1FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org1FullName/*.fna" | head -n1); fi
if [ -z "$org2FASTA" ]; then org2FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org2FullName/*.fna" | head -n1); fi
if [ -z "$org3FASTA" ]; then org3FASTA=$(compgen -G "$(get_config '.paths.base_genomes')/$org3FullName/*.fna" | head -n1); fi

echo "org1FASTA: ${org1FASTA:-NOT_FOUND}"
echo "org2FASTA: ${org2FASTA:-NOT_FOUND}"
echo "org3FASTA: ${org3FASTA:-NOT_FOUND}"

for f in "$org1FASTA" "$org2FASTA" "$org3FASTA"; do
    if [ -z "$f" ]; then
        echo "Error: Could not determine FASTA file path(s). Please ensure .fna files exist in the respective genome directories." >&2
        exit 1
    fi
done

# Check if GFF file exists in org1 (auto-detect)
gffFilePath="$(get_config '.paths.base_genomes')/$org1FullName/genomic.gff"

if [ -e "$gffFilePath" ]; then
    org1GFF="$gffFilePath" # set $org1GFF as the path to the gff file
    echo "GFF file found: $org1GFF"
else
    org1GFF="NO_GFF_FILE" # set a special flag to $org1GFF
    echo "No GFF file found for $org1FullName. Please download the GFF file manually."
fi

# Run downstream pipeline (no checkInnerGroupIdt argument anymore)
bash "$LAST_DIR/trisbst_3spc.sh" "$DATE" "$org1FASTA" "$org2FASTA" "$org3FASTA" "$org1GFF"
