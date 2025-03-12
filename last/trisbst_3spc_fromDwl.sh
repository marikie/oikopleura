#!/bin/bash

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

cd $(get_config '.paths.base_genome')
for orgFullName in $org1FullName $org2FullName $org3FullName; do
    if [ ! -d "$orgFullName" ]; then
        mkdir "$orgFullName"
    fi
done

# download from NCBIdatase
base_genome=$(get_config '.paths.base_genome')
includes=$(get_config '.download.includes' | tr '\n' ',' | sed 's/,$//')

# Create arrays
ids=("$org1ID" "$org2ID" "$org3ID")
names=("$org1FullName" "$org2FullName" "$org3FullName")

# Iterate over both arrays using an index
for i in {0..2}; do
    orgID=${ids[$i]}
    orgFullName=${names[$i]}
    if [ ! -e "$base_genome/$orgFullName/ncbi_dataset.zip" ]; then
        echo "$(get_config '.messages.download' | sed "s/{org_full}/$orgFullName/g")"
        cd "$base_genome/$orgFullName"
        datasets download genome accession "$orgID" --include "$includes" &
    else
        echo "$(get_config '.messages.already_downloaded' | sed "s/{org_full}/$orgFullName/g")"
    fi
done
wait

# move files and delete unnecessary directories
echo "$(get_config '.messages.move_files')"
function processGenomeData() {
    local orgFullName=$1
    local orgID=$2

    cd "$(get_config '.paths.base_genomes')/$orgFullName"
    if [ -z "$(ls *.fna 2>/dev/null)" ]; then
        unzip ncbi_dataset.zip
        wait
        cd ncbi_dataset/data
        mv $(ls -p | grep -v /) "$(get_config '.paths.base_genomes')/$orgFullName"
        cd "$orgID"
        mv * "$(get_config '.paths.base_genomes')/$orgFullName"
        cd "$(get_config '.paths.base_genomes')/$orgFullName"
        rm -r ncbi_dataset
    fi
}
processGenomeData $org1FullName $org1ID &
processGenomeData $org2FullName $org2ID &
processGenomeData $org3FullName $org3ID &
wait

org1FASTA="$(get_config '.paths.base_genomes')/$org1FullName/$(ls $(get_config '.paths.base_genomes')/$org1FullName | grep $org1ID)"
org2FASTA="$(get_config '.paths.base_genomes')/$org2FullName/$(ls $(get_config '.paths.base_genomes')/$org2FullName | grep $org2ID)"
org3FASTA="$(get_config '.paths.base_genomes')/$org3FullName/$(ls $(get_config '.paths.base_genomes')/$org3FullName | grep $org3ID)"
echo "org1FASTA: $org1FASTA"
echo "org2FASTA: $org2FASTA"
echo "org3FASTA: $org3FASTA"

echo "Running trisbst_3spc.sh"
echo "bash $(get_config '.paths.scripts.last')/trisbst_3spc.sh $DATE $org1FASTA $org2FASTA $org3FASTA $org1FullName $org2FullName $org3FullName $(get_config '.paths.data')"
bash $(get_config '.paths.scripts.last')/trisbst_3spc.sh $DATE $org1FASTA $org2FASTA $org3FASTA $org1FullName $org2FullName $org3FullName $(get_config '.paths.data')