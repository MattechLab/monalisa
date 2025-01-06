#!/bin/bash

# Ensure the target directory exists
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$(realpath "$script_dir/")"
mkdir -p "$target_dir"

# Function to download using curl or wget
download_file() {
    file_id="$1"
    output="$2"
    download_url="https://drive.google.com/uc?export=download&id=${file_id}"

    if command -v curl &> /dev/null; then
        echo "Downloading $output with curl..."
        if curl -L "https://drive.usercontent.google.com/download?id=${file_id}&confirm=xxx" -o "$output"; then
            echo "Successfully downloaded $output using curl."
        else
            echo "Curl failed to download $output."
            return 1
        fi
    elif command -v wget &> /dev/null; then
        echo "Downloading $output with wget..."
        if wget --no-check-certificate -O "$output" "$download_url"; then
            echo "Successfully downloaded $output using wget."
        else
            echo "Wget failed to download $output."
            return 1
        fi
    else
        echo "Neither curl nor wget is installed. Please install one of them and try again."
        exit 1
    fi
}

# List of files to download with their corresponding file_ids and output names
file_ids=("11p1lUw4pcj_xp1kPuKv3LO_cfcyYlnw_" "12sYtd-KfkZYM8IBzg_DGXsxT3n_uHSLf" "1dd8I74Hy4Hb97SF-fHBIkrZP_JzwpMa0")
outputs=("bodyCoil.dat" "brainScan.dat" "surfaceCoil.dat")

# Iterate over the file_ids and outputs arrays
for i in "${!file_ids[@]}"; do
    file_id="${file_ids[$i]}"
    output="$target_dir/${outputs[$i]}"
    echo "Starting download of $output..."
    if ! download_file "$file_id" "$output"; then
        echo "Failed to download $output. Skipping."
    fi
done

# Confirm completion
echo "All downloads completed!"
