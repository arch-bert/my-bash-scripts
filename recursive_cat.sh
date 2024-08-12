#!/bin/bash

# Function to print the file tree excluding the .git directory
print_tree() {
    tree
}

# Function to print files recursively excluding the .git directory and specified directories
print_files_recursively() {
    local dir="$1"
    local prefix="$2"
    shift 2
    local ignore_dirs=("$@")

    for file in "$dir"/*; do
        if [ -d "$file" ]; then
            local skip=false
            for ignore in "${ignore_dirs[@]}"; do
                if [[ "$file" == *"$ignore"* ]]; then
                    skip=true
                    break
                fi
            done

            if [[ "$skip" == false && "$file" != *".git"* ]]; then
                echo "${prefix}${file##*/}:"
                print_files_recursively "$file" "$prefix|   " "${ignore_dirs[@]}"
            fi
        elif [ -f "$file" ]; then
            if [[ ! -s "$file" ]]; then
                echo "<empty file>"
            else
                # Skip PDF files
                if [[ "$file" == *.pdf ]]; then
                    continue
                fi

                # Check for data files (.csv)
                if [[ "$file" == *.csv ]]; then
                    echo "--------------------------------------------"
                    echo "Contents of ${file} (first few rows):"
                    echo "--------------------------------------------"
                    head -n 10 "$file"
                    echo
                # Ignore machine code files (.pyc, executables, xlsx)
                elif [[ "$file" != *.pyc ]] && [[ "$file" != *.xlsx ]] && [[ "$file" != *"/bin/"* ]]; then  # Add more conditions as needed
                    echo "--------------------------------------------"
                    echo "Contents of ${file}:"
                    echo "--------------------------------------------"
                    cat "$file"
                    echo
                fi
            fi
        fi
    done
}

# Print the file tree
tree_output=$(print_tree)

# Get ignore directories from arguments
ignore_dirs=("$@")

# Capture the output of print_files_recursively to a variable
files_output=$(print_files_recursively . "" "${ignore_dirs[@]}")

# Copy file contents to clipboard
{
    echo "File Tree:"
    echo "$tree_output"
    echo
    echo "$files_output"
} | pbcopy

echo "Output copied to clipboard."