#!/bin/bash

# If no directory provided, use current directory
if [ $# -eq 0 ]; then
    target_dir="$(pwd)"
    echo "No directory specified. Using current directory: $target_dir"
else
    target_dir="$1"
    echo "Directory specified: $target_dir"
fi

# Check if directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

# Change to the specified directory
echo "Changing to directory: $target_dir"
cd "$target_dir" || exit 1

# Arrays to store planned actions
declare -a archives_to_extract
declare -a files_to_move
declare -a dirs_to_remove

# Function to calculate planned actions
plan_actions() {
    for file in *; do
        if [ -f "$file" ] && [ "$file" != "flatten.sh" ]; then
            case "$file" in
                *.tar.gz|*.tgz|*.tar|*.gz|*.zip|*.rar|*.7z)
                    archives_to_extract+=("$file")
                    ;;
            esac
        fi
    done

    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != "*/" ]; then
            while IFS= read -r -d '' file; do
                files_to_move+=("$file")
            done < <(find "$dir" -type f -mindepth 1 -print0)
            while IFS= read -r -d '' dir_empty; do
                dirs_to_remove+=("$dir_empty")
            done < <(find "$dir" -type d -empty -print0)
        fi
    done
}

# Function to display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\rProgress: ["
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%" "$percent"
}

# Calculate planned actions
plan_actions

# Calculate total tasks
total_tasks=$(( ${#archives_to_extract[@]} + ${#files_to_move[@]} + ${#dirs_to_remove[@]} ))

# Display summary and get confirmation
echo -e "\nPlanned Actions Summary:"
echo "------------------------"
echo "Archives to extract: ${#archives_to_extract[@]}"
for archive in "${archives_to_extract[@]}"; do
    echo "  - $archive"
done
echo "Files to move: ${#files_to_move[@]}"
# Fixed the for loop syntax here
if [ ${#files_to_move[@]} -gt 0 ]; then
    for ((i=0; i<${#files_to_move[@]}; i++)); do
        echo "  - ${files_to_move[$i]}"
    done
fi
echo "Directories to remove: ${#dirs_to_remove[@]}"
for dir in "${dirs_to_remove[@]}"; do
    echo "  - $dir"
done
echo "Total tasks: $total_tasks"
echo -e "\nDo you want to proceed? (y/n): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled by user"
    exit 0
fi

# Function to extract files based on extension
extract_and_remove() {
    local file="$1"
    echo "Processing file: $file"
    case "$file" in
        *.tar.gz|*.tgz)
            echo "Extracting tar.gz/tgz archive: $file"
            tar -xzf "$file" && echo "Removing original archive: $file" && rm "$file"
            ;;
        *.tar)
            echo "Extracting tar archive: $file"
            tar -xf "$file" && echo "Removing original archive: $file" && rm "$file"
            ;;
        *.gz)
            echo "Extracting gz archive: $file"
            gunzip "$file" && echo "Successfully extracted: $file"
            ;;
        *.zip)
            echo "Extracting zip archive: $file"
            unzip "$file" && echo "Removing original archive: $file" && rm "$file"
            ;;
        *.rar)
            echo "Extracting rar archive: $file"
            unrar x "$file" && echo "Removing original archive: $file" && rm "$file"
            ;;
        *.7z)
            echo "Extracting 7z archive: $file"
            7z x "$file" && echo "Removing original archive: $file" && rm "$file"
            ;;
        *)
            echo "Skipping unsupported file type: $file"
            return 1
            ;;
    esac
}

# Main processing loop with progress
current_task=0
while true; do
    echo "Starting new processing iteration..."
    # Extract all archived files except flatten.sh
    archived_files=false
    for file in *; do
        if [ -f "$file" ] && [ "$file" != "flatten.sh" ]; then
            case "$file" in
                *.tar.gz|*.tgz|*.tar|*.gz|*.zip|*.rar|*.7z)
                    echo "Found archive file: $file"
                    extract_and_remove "$file"
                    archived_files=true
                    ((current_task++))
                    show_progress "$current_task" "$total_tasks"
                    ;;
            esac
        fi
    done

    # Move files from subdirectories to current directory
    moved_files=false
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != "*/" ]; then
            echo "Processing directory: $dir"
            # Move all files from subdirectory
            find "$dir" -type f -mindepth 1 -exec sh -c 'echo "Moving file: {} to ."; mv "{}" .; echo "$((${current_task}+1))"' \; | while read -r new_task; do
                current_task=$new_task
                show_progress "$current_task" "$total_tasks"
            done
            # Remove empty directories
            find "$dir" -type d -empty -exec sh -c 'echo "Removing empty directory: {}"; rmdir "{}"; echo "$((${current_task}+1))"' \; | while read -r new_task; do
                current_task=$new_task
                show_progress "$current_task" "$total_tasks"
            done
            moved_files=true
        fi
    done

    # If no archives were extracted and no files were moved, we're done
    if [ "$archived_files" = false ] && [ "$moved_files" = false ]; then
        echo -e "\nNo more archives to extract or directories to flatten"
        break
    fi
done

echo -e "\nExtraction and reorganization complete!"
