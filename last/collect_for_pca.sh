#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/sbst_config.yaml"
DWL_CONFIG_FILE="$SCRIPT_DIR/dwl_config.yaml"

usage() {
    echo "Usage: $0 <DATE> <org1ID> <org2ID> <org3ID> <org1Short> <org2Short> <org3Short> <org1Full> <org2Full> <org3Full> <outDir>" >&2
    exit 1
}

if [ $# -ne 11 ]; then
    usage
fi

DATE=$1
orgIDs=($2 $3 $4)
shortNames=($5 $6 $7)
orgDirs=($8 $9 ${10})
outDirPath=$11

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: sbst_config.yaml not found at $CONFIG_FILE" >&2
    exit 1
fi

get_config() {
    yq eval "$1" "$CONFIG_FILE"
}

baseGenomes=""
if [ -f "$DWL_CONFIG_FILE" ]; then
    baseGenomes=$(yq eval '.paths.base_genomes' "$DWL_CONFIG_FILE" 2>/dev/null || echo "")
fi

pcaRoot=$(get_config '.paths.pca_analysis')
if [ -z "$pcaRoot" ] || [ "$pcaRoot" = "null" ]; then
    echo "Error: .paths.pca_analysis is not set in sbst_config.yaml" >&2
    exit 1
fi

if [[ "$pcaRoot" != /* ]]; then
    baseOutDir=$(get_config '.paths.out_dir')
    if [ -z "$baseOutDir" ] || [ "$baseOutDir" = "null" ]; then
        echo "Error: .paths.out_dir is not set in sbst_config.yaml" >&2
        exit 1
    fi
    pcaRoot="$baseOutDir/$pcaRoot"
fi

if [ ! -d "$pcaRoot" ]; then
    mkdir -p "$pcaRoot"
fi

pcaTsvDir="$pcaRoot/tsv"
pcaMetadataDir="$pcaRoot/metadata"
pcaResultsDir="$pcaRoot/results"

mkdir -p "$pcaTsvDir" "$pcaMetadataDir" "$pcaResultsDir"

link_tsv_files() {
    local accession=$1
    local short=$2
    local pattern="${accession}_${short}_${DATE}*.tsv"

    shopt -s nullglob
    local matches=("$outDirPath"/$pattern)
    shopt -u nullglob

    if [ ${#matches[@]} -eq 0 ]; then
        echo "Warning: TSV files matching $pattern not found in $outDirPath" >&2
        return
    fi

    for src in "${matches[@]}"; do
        local name=$(basename "$src")
        ln -sf "$src" "$pcaTsvDir/$name"
    done
}

link_metadata_json() {
    local accession=$1
    local dirName=$2
    local candidates=()

    if [ -n "$baseGenomes" ] && [ -d "$baseGenomes" ]; then
        candidates+=("$baseGenomes/$dirName/${accession}.json")
        candidates+=("$baseGenomes/$dirName/${accession}/${accession}.json")
    fi

    candidates+=("$outDirPath/${accession}.json")

    local jsonFile=""
    for path in "${candidates[@]}"; do
        if [ -f "$path" ]; then
            jsonFile="$path"
            break
        fi
    done

    if [ -z "$jsonFile" ]; then
        echo "Warning: Metadata JSON for $accession not found" >&2
        return
    fi

    ln -sf "$jsonFile" "$pcaMetadataDir/${accession}.json"
}

for idx in 0 1 2; do
    link_tsv_files "${orgIDs[$idx]}" "${shortNames[$idx]}"
    link_metadata_json "${orgIDs[$idx]}" "${orgDirs[$idx]}"
done

# Optionally run PCA automation if script exists and environment variable is set
PCA_AUTO_SCRIPT="$SCRIPT_DIR/../analysis/pca_auto.py"
if [ "${RUN_PCA_AUTO:-0}" -eq 1 ] && [ -f "$PCA_AUTO_SCRIPT" ]; then
    echo "--- running pca_auto.py"
    python "$PCA_AUTO_SCRIPT" \
        --tsv_dir "$pcaTsvDir" \
        --metadata_dir "$pcaMetadataDir" \
        --output_dir "$pcaResultsDir"
fi
