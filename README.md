# flatten.sh

A Bash script that decompresses archives and flattens directory structures.

## Description

`flatten.sh` is a utility script that:
- Decompresses various archive formats in a specified directory
- Moves all files from subdirectories to the root directory
- Removes empty directories
- Provides a summary of actions before execution and requires user confirmation
- Shows a progress bar during execution

Supported archive formats: `.tar.gz`, `.tgz`, `.tar`, `.gz`, `.zip`, `.rar`, `.7z`

## Prerequisites

- Bash shell
- Required utilities:
  - `tar` (for .tar, .tar.gz, .tgz)
  - `gunzip` (for .gz)
  - `unzip` (for .zip)
  - `unrar` (for .rar)
  - `7z` (for .7z)

Install these on Debian/Ubuntu:
```bash
sudo apt-get install tar gzip unzip unrar p7zip-full
Installation
Save the script as flatten.sh
Make it executable:
bash
chmod +x flatten.sh
Usage
Run in current directory:
bash
./flatten.sh
Run in specific directory:
bash
./flatten.sh /path/to/directory
The script will:
Show a summary of planned actions (archives to extract, files to move, directories to remove)
Ask for confirmation (y/n)
Process files with verbose output and progress bar
Skip processing itself (flatten.sh) if present in the target directory
Features
Pre-execution summary of all planned actions
User confirmation required before proceeding
Progress bar showing completion percentage
Verbose output detailing each action
Handles multiple archive types
Automatically uses current directory if no path provided
Preserves original file names (note: may overwrite duplicates)
Example Output
Directory specified: /home/user/test
Changing to directory: /home/user/test

Planned Actions Summary:
------------------------
Archives to extract: 2
  - test.zip
  - docs.tar.gz
Files to move: 1
  - folder/file.txt
Directories to remove: 1
  - folder/
Total tasks: 4

Do you want to proceed? (y/n): y
Starting new processing iteration...
Found archive file: test.zip
Processing file: test.zip
Extracting zip archive: test.zip
Removing original archive: test.zip
Progress: [############--------------------------------------] 25%
...
Progress: [##################################################] 100%
Extraction and reorganization complete!
Limitations
Overwrites files with duplicate names (last extracted/moved wins)
Requires appropriate permissions in target directory
Only supports specified archive formats
Directory removal only occurs if directories are empty after file movement
License
This script is provided as-is with no warranty. Feel free to modify and distribute as needed.

This README provides:
- A brief description
- Prerequisites and installation instructions
- Usage examples
- Feature list
- Sample output
- Limitations
- Basic licensing info
