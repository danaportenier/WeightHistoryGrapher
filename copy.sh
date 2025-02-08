#!/bin/bash

# Specify the output file path
output_file="$HOME/Desktop/combined_file.txt"

# Initialize the file count
file_count=0

# Clear the output file if it exists
> "$output_file"

# Function to copy file contents
copy_file_contents() {
    local file="$1"
    echo "Copying: $file"
    echo "==== Contents of $file ====" >> "$output_file"
    cat "$file" >> "$output_file"
    echo -e "\n\n" >> "$output_file"
    file_count=$((file_count + 1))
}

# Export the function so it can be used by find's -exec
export -f copy_file_contents
export output_file

# Find and copy contents of all .swift files
find . -type f -name "*.swift" -exec bash -c 'copy_file_contents "$0"' {} \;

# Output the total number of files copied
echo "Total number of files copied: $file_count"
