#!/bin/bash

# Check if TMSU is installed
command -v tmsu >/dev/null 2>&1 || { echo "Error: TMSU is not installed. Please install it first."; exit 1; }

# Initialize TMSU database if it doesn't exist
[[ ! -f ".tmsu/db" ]] && tmsu init

# Global variables
TAG_STYLE=""
VERBOSE=false
DRY_RUN=false
EXTENSION_STYLE="dot" # can be "dot" or "prefix"

# Function to clean tag names based on chosen style
clean_tag_name() {
    local input="$1"
    [[ -z "$input" ]] && return

    case "$TAG_STYLE" in
        "simple")
            # Allow dots, convert spaces and underscores to hyphens
            echo "$input" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9.-]//g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
            ;;
        "lowercase")
            # Allow dots, preserve underscores and hyphens
            echo "$input" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9._-]//g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
            ;;
        "preserve")
            # Allow dots, preserve case
            echo "$input" | tr ' ' '-' | sed 's/[^a-zA-Z0-9._-]//g'
            ;;
        "letters")
            # Convert to lowercase and remove special characters, but preserve dots
            echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.]//g'
            ;;
    esac
}

# Function to get file extension
get_extension() {
    local filename="$1"
    local ext="${filename##*.}"
    [[ "$ext" != "$filename" ]] && echo "$ext" || echo ""
}

# Function to format extension tag
format_extension_tag() {
    local ext="$1"
    [[ -z "$ext" ]] && return
    
    case "$EXTENSION_STYLE" in
        "dot")
            echo ".$ext"
            ;;
        "prefix")
            echo "ext-$ext"
            ;;
    esac
}

# Function to get filename without extension
get_filename_without_ext() {
    local filename="$1"
    local basename="${filename##*/}"
    echo "${basename%.*}"
}

# Function to process each file
process_file() {
    local file="$1"
    local base_dir="$2"
    
    # Skip directories, hidden files, and .tmsu directory
    [[ -d "$file" || "$file" == .* || "$file" == */.* ]] && return
    
    # Get the relative path from the base directory
    local rel_path="${file#$base_dir/}"
    local dir_path=$(dirname "$rel_path")
    [[ "$dir_path" = "." ]] && return
    
    # Initialize tags array
    local tags=()
    
    # Process directory structure
    local IFS='/'
    read -ra DIRS <<< "$dir_path"
    for dir in "${DIRS[@]}"; do
        local clean_tag=$(clean_tag_name "$dir")
        [[ -n "$clean_tag" ]] && tags+=("$clean_tag")
    done
    
    # Add filename as tag
    local filename=$(get_filename_without_ext "$file")
    local clean_filename=$(clean_tag_name "$filename")
    [[ -n "$clean_filename" ]] && tags+=("$clean_filename")
    
    # Add extension as tag
    local extension=$(get_extension "$file")
    if [[ -n "$extension" ]]; then
        local ext_tag=$(format_extension_tag "$extension")
        tags+=("$ext_tag")
    fi
    
    # Skip if no tags
    [[ ${#tags[@]} -eq 0 ]] && return
    
    # Join tags with spaces
    local tag_string=$(IFS=' '; echo "${tags[*]}")
    
    if $VERBOSE; then
        echo "File: $file"
        echo "Tags: $tag_string"
    fi
    
    if ! $DRY_RUN; then
        tmsu tag --tags "$tag_string" "$file" 2>/dev/null || {
            echo "Error tagging: $file"
            return 1
        }
    fi
}

# Function to choose extension style
choose_extension_style() {
    while true; do
        cat << EOF

Choose extension tagging style:
1) Dot notation (.pdf, .mp3, .txt)
2) Prefix notation (ext-pdf, ext-mp3, ext-txt)
EOF
        read -p "Enter choice (1-2): " choice
        
        case $choice in
            1) EXTENSION_STYLE="dot"; break ;;
            2) EXTENSION_STYLE="prefix"; break ;;
            *) echo "Invalid choice. Please enter 1 or 2." ;;
        esac
    done
    
    echo -e "\nUsing $EXTENSION_STYLE style for extension tags"
}

# Function to get user's preferred tag style
choose_tag_style() {
    while true; do
        cat << EOF
Choose tag formatting style:
1) Simple (lowercase with hyphens, e.g., 'course-materials.2023')
2) Preserve (keep original case and symbols, e.g., 'Course_Materials.2023')
3) Lowercase (lowercase with original symbols, e.g., 'course_materials.2023')
4) Letters only (lowercase with dots, e.g., 'coursematerials.2023')
EOF
        read -p "Enter choice (1-4): " choice
        
        case $choice in
            1) TAG_STYLE="simple"; break ;;
            2) TAG_STYLE="preserve"; break ;;
            3) TAG_STYLE="lowercase"; break ;;
            4) TAG_STYLE="letters"; break ;;
            *) echo "Invalid choice. Please enter 1-4." ;;
        esac
    done
    
    echo -e "\nUsing $TAG_STYLE tag style"
    choose_extension_style
    show_examples
}

# Function to show tag examples
show_examples() {
    echo -e "\nExample paths and resulting tags:"
    local examples=(
        "Course_Materials.2023/Lab-01/Document.pdf"
        "Python 3/Data_Analysis.v2/data.csv"
    )
    
    for example in "${examples[@]}"; do
        echo "Path: $example"
        echo -n "Tags: "
        
        local tags=()
        local IFS='/'
        read -ra PARTS <<< "$example"
        
        # Process directories
        for ((i=0; i<${#PARTS[@]}-1; i++)); do
            local clean_tag=$(clean_tag_name "${PARTS[i]}")
            [[ -n "$clean_tag" ]] && tags+=("$clean_tag")
        done
        
        # Process filename
        local filename=$(get_filename_without_ext "${PARTS[-1]}")
        local clean_filename=$(clean_tag_name "$filename")
        [[ -n "$clean_filename" ]] && tags+=("$clean_filename")
        
        # Add extension
        local extension=$(get_extension "${PARTS[-1]}")
        if [[ -n "$extension" ]]; then
            local ext_tag=$(format_extension_tag "$extension")
            tags+=("$ext_tag")
        fi
        
        # Print tags
        local tag_string=$(IFS=' '; echo "${tags[*]}")
        echo "$tag_string"
        echo
    done
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [directory]
Tag files using TMSU based on directory structure, filenames, and extensions.

Options:
  -h, --help     Show this help message
  -v, --verbose  Show detailed output
  -d, --dry-run  Show what would be done without making changes
  
If no directory is specified, the current directory will be used.

Tag styles available:
1. Simple: lowercase with hyphens (course-materials.2023)
2. Preserve: original format (Course_Materials.2023)
3. Lowercase: lowercase with original symbols (course_materials.2023)
4. Letters only: lowercase with dots (coursematerials.2023)

Extension styles available:
1. Dot notation: .pdf, .mp3, .txt
2. Prefix notation: ext-pdf, ext-mp3, ext-txt
EOF
    exit 0
}

# Main script
main() {
    local start_dir="."
    
    # Process command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_usage ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -d|--dry-run) DRY_RUN=true; shift ;;
            -*) echo "Unknown option: $1"; show_usage ;;
            *) start_dir="$1"; shift ;;
        esac
    done
    
    # Convert to absolute path
    start_dir=$(cd "$start_dir" 2>/dev/null && pwd) || {
        echo "Error: Invalid directory: $start_dir"
        exit 1
    }
    
    echo "Starting directory: $start_dir"
    $DRY_RUN && echo "DRY RUN MODE - No changes will be made"
    
    # Get user's preferred styles
    choose_tag_style
    
    echo "This will create tags based on directory structure, filenames, and extensions."
    read -p "Press ENTER to continue or CTRL+C to cancel..."
    
    # Process all files
    find "$start_dir" -type f -print0 | while IFS= read -r -d '' file; do
        process_file "$file" "$start_dir"
    done
    
    echo -e "\nFinished tagging files."
    echo "Use 'tmsu files <tag>' to find your files."
    echo "Use 'tmsu tags' to see all available tags."
}

# Run main function with all arguments
main "$@"
