#!/bin/bash

# Check if TMSU is installed
if ! command -v tmsu &> /dev/null
then
    echo "Error: TMSU is not installed. Please install it first."
    exit 1
fi

# Initialize TMSU database if it doesn't exist
if [ ! -f ".tmsu/db" ]
then
    tmsu init
fi

# Global variable for tag style
TAG_STYLE=""

# Function to clean tag names based on chosen style
clean_tag_name() {
    case "$TAG_STYLE" in
        "simple")
            # Convert to lowercase, replace spaces and symbols with single hyphen
            echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9-]//g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
            ;;
        "lowercase")
            # Convert to lowercase but preserve underscores and hyphens
            echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9_-]//g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
            ;;
        "preserve")
            # Preserve case and symbols, only remove problematic characters
            echo "$1" | tr ' ' '-' | sed 's/[^a-zA-Z0-9_-]//g'
            ;;
        "letters")
            # Convert to lowercase and remove all special characters
            echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g'
            ;;
    esac
}

# Function to process each file
process_file() {
    local file="$1"
    local base_dir="$2"
    
    # Skip if it's a directory
    if [ -d "$file" ]
    then
        return
    fi
    
    # Skip hidden files and the .tmsu directory
    if [[ "$file" == .* ]] || [[ "$file" == */.* ]]
    then
        return
    fi
    
    # Get the relative path from the base directory
    local rel_path="${file#$base_dir/}"
    
    # Get directory path without the filename
    local dir_path=$(dirname "$rel_path")
    
    # Skip if we're at the root
    if [ "$dir_path" = "." ]
    then
        return
    fi
    
    # Convert directory structure to tags
    local tags=""
    local IFS='/'
    read -ra DIRS <<< "$dir_path"
    
    for dir in "${DIRS[@]}"
    do
        # Clean the tag name
        local clean_tag=$(clean_tag_name "$dir")
        if [ ! -z "$clean_tag" ]
        then
            tags+="$clean_tag "
        fi
    done
    
    # Remove trailing space
    tags="${tags% }"
    
    # Skip if no tags
    if [ -z "$tags" ]
    then
        return
    fi
    
    echo "Tagging: $file"
    echo "Tags: $tags"
    tmsu tag --tags "$tags" "$file"
}

# Function to get user's preferred tag style
choose_tag_style() {
    while true
    do
        echo "Choose tag formatting style:"
        echo "1) Simple (lowercase with hyphens, e.g., 'course-materials')"
        echo "2) Preserve (keep original case and symbols, e.g., 'Course_Materials')"
        echo "3) Lowercase (lowercase with original symbols, e.g., 'course_materials')"
        echo "4) Letters only (lowercase, no symbols, e.g., 'coursematerials')"
        read -p "Enter choice (1, 2, 3, or 4): " choice
        
        case $choice in
            1)
                TAG_STYLE="simple"
                echo "Using simple tag style: lowercase with hyphens"
                break
                ;;
            2)
                TAG_STYLE="preserve"
                echo "Using preserved tag style: original format"
                break
                ;;
            3)
                TAG_STYLE="lowercase"
                echo "Using lowercase tag style: lowercase with original symbols"
                break
                ;;
            4)
                TAG_STYLE="letters"
                echo "Using letters-only style: lowercase, no symbols"
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    
    # Show examples
    echo -e "\nExample directory paths and resulting tags:"
    echo "1. Course_Materials/Lab-01/Exercise_A"
    echo -n "   Tags: "
    local example1="Course_Materials/Lab-01/Exercise_A"
    local IFS='/'
    read -ra DIRS <<< "$example1"
    local tags=""
    for dir in "${DIRS[@]}"
    do
        tags+="$(clean_tag_name "$dir") "
    done
    echo "${tags% }"
    
    echo "2. Python 3/Data_Analysis/CSV Files"
    echo -n "   Tags: "
    local example2="Python 3/Data_Analysis/CSV Files"
    read -ra DIRS <<< "$example2"
    tags=""
    for dir in "${DIRS[@]}"
    do
        tags+="$(clean_tag_name "$dir") "
    done
    echo -e "${tags% }\n"
}

# Main script
main() {
    local start_dir="$1"
    
    # If no directory specified, use current directory
    if [ -z "$start_dir" ]
    then
        start_dir="."
    fi
    
    # Convert to absolute path
    start_dir=$(cd "$start_dir"; pwd)
    
    echo "Starting to tag files from: $start_dir"
    
    # Get user's preferred tag style
    choose_tag_style
    
    echo "This will create tags based on directory structure."
    echo "Press CTRL+C to cancel or ENTER to continue..."
    read
    
    # Process all files recursively
    find "$start_dir" -type f | while read -r file
    do
        process_file "$file" "$start_dir"
    done
    
    echo "Finished tagging files."
    echo "You can now use 'tmsu files <tag>' to find your files."
}

# Show usage if --help is specified
if [ "$1" = "--help" ]
then
    echo "Usage: $0 [directory]"
    echo "If no directory is specified, the current directory will be used."
    echo "This script will create TMSU tags based on the directory structure."
    echo "You can choose between four tag formatting styles:"
    echo "1. Simple: lowercase with hyphens (course-materials)"
    echo "2. Preserve: original format (Course_Materials)"
    echo "3. Lowercase: lowercase with original symbols (course_materials)"
    echo "4. Letters only: lowercase, no symbols (coursematerials)"
    exit 0
fi

# Run main function
main "$1"
