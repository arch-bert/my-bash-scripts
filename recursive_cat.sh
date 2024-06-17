#!/bin/bash

# Function to print the file tree excluding the .git directory
print_tree() {
    tree
}

# Function to print files recursively excluding the .git directory
print_files_recursively() {
    local dir="$1"
    local prefix="$2"

    for file in "$dir"/*; do
        if [ -d "$file" ] && [[ "$file" != *".git"* ]]; then
            echo "${prefix}${file##*/}:"
            print_files_recursively "$file" "$prefix|   "
        elif [ -f "$file" ]; then
            # Check for data files (.csv)
            if [[ "$file" == *.csv ]]; then
                echo "--------------------------------------------"
                echo "Contents of ${file} (first few rows):"
                echo "--------------------------------------------"
                head -n 10 "$file"
                echo
            # ignore machine code files (.pyc, executables, xlsx)
            elif [[ "$file" != *.pyc ]] && [[ "$file" != *.xlsx ]] && [[ "$file" != *"/bin/"* ]]; then  # Add more conditions as needed
                echo "--------------------------------------------"
                echo "Contents of ${file}:"
                echo "--------------------------------------------"
                cat "$file"
                echo
            fi
        fi
    done
}

# Print the file tree
echo "File Tree:"
print_tree
echo

# Print file contents
print_files_recursively . ""