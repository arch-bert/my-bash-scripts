#!/bin/bash

# Function to print the file tree excluding the .git directory
print_tree() {
    tree -d
}

# Function to print files recursively, excluding specified directories and certain file types
print_files_recursively() {
    local dir="$1"
    local prefix="$2"
    shift 2
    local ignore_dirs=(".git" "$@")  # Always ignore the .git directory

    for file in "$dir"/*; do
        # Check if the file is a directory
        if [ -d "$file" ]; then
            local skip=false
            # Check if the directory is in the ignore list
            for ignore in "${ignore_dirs[@]}"; do
                if [[ "$file" == *"$ignore"* ]]; then
                    skip=true
                    break
                fi
            done

            if [[ "$skip" == false ]]; then
                # echo "${prefix}${file##*/}/"
                print_files_recursively "$file" "$prefix|   " "${ignore_dirs[@]}"
            fi

        # Check if the file is a regular file
        elif [ -f "$file" ]; then
            # Skip specific file types
            if [[ "$file" == *.pdf || "$file" == *.png || "$file" == *.jpg || "$file" == *.jpeg || "$file" == *.gif || "$file" == *.pyc || "$file" == *.xlsx || "$file" == *.exe ]]; then
                continue
            fi

            if [[ ! -s "$file" ]]; then
                echo "${prefix}<empty file>"
            else
                # Special handling for CSV files (print first 10 lines)
                if [[ "$file" == *.csv ]]; then
                    echo "--------------------------------------------"
                    echo "Contents of ${file} (first few rows):"
                    echo "--------------------------------------------"
                    head -n 10 "$file"
                    echo
                else
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

# Print the file tree excluding .git directory
tree_output=$(print_tree)

# Get ignore directories from script arguments (passed in as $1, $2, etc.)
ignore_dirs=("$@")

# Print the files recursively excluding specified directories (and always .git)
files_output=$(print_files_recursively . "" "${ignore_dirs[@]}")

# Combine the tree and file contents and copy to clipboard
{
    echo "File Tree:"
    echo "$tree_output"
    echo
    echo "$files_output"
} | pbcopy

echo "Output copied to clipboard."