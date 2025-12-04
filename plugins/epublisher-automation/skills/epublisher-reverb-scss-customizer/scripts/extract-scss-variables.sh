#!/bin/bash
################################################################################
# extract-scss-variables.sh
#
# Extracts SCSS variable values from Reverb project files.
# Searches through the file resolver hierarchy to find effective values.
#
# Usage:
#   ./extract-scss-variables.sh <project-dir> [category]
#
# Arguments:
#   project-dir - Path to ePublisher project directory
#   category    - Optional: neo, colors, sizes, layout, all (default: neo)
#
# Output:
#   JSON object with variable names and values
#
################################################################################

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

DEBUG="${DEBUG:-0}"

debug_log() {
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "${YELLOW}[DEBUG]${NC} $*" >&2
    fi
}

error_log() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

success_log() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

################################################################################
# File Resolution
################################################################################

find_scss_file() {
    local project_dir="$1"
    local filename="$2"
    local target_name="${3:-}"

    debug_log "Looking for $filename in project: $project_dir"

    # Check locations in priority order (most specific first)
    local file=""

    # 1. Target-specific (if target specified)
    if [[ -n "$target_name" ]]; then
        file="$project_dir/Targets/$target_name/Pages/sass/$filename"
        if [[ -f "$file" ]]; then
            debug_log "Found at target level: $file"
            echo "$file"
            return 0
        fi
    fi

    # 2. Format-level customization
    file="$project_dir/Formats/WebWorks Reverb 2.0/Pages/sass/$filename"
    if [[ -f "$file" ]]; then
        debug_log "Found at format level: $file"
        echo "$file"
        return 0
    fi

    # 3. Stationery format-level (search for *stationery directories)
    for stationery_dir in "$project_dir"/*stationery; do
        if [[ -d "$stationery_dir" ]]; then
            file="$stationery_dir/Formats/WebWorks Reverb 2.0/Pages/sass/$filename"
            if [[ -f "$file" ]]; then
                debug_log "Found at stationery format level: $file"
                echo "$file"
                return 0
            fi
        fi
    done

    # 4. Packaged defaults (.base)
    file="$project_dir/Formats/WebWorks Reverb 2.0.base/Pages/sass/$filename"
    if [[ -f "$file" ]]; then
        debug_log "Found at .base level: $file"
        echo "$file"
        return 0
    fi

    # 5. Stationery .base level
    for stationery_dir in "$project_dir"/*stationery; do
        if [[ -d "$stationery_dir" ]]; then
            file="$stationery_dir/Formats/WebWorks Reverb 2.0.base/Pages/sass/$filename"
            if [[ -f "$file" ]]; then
                debug_log "Found at stationery .base level: $file"
                echo "$file"
                return 0
            fi
        fi
    done

    debug_log "File not found: $filename"
    return 1
}

################################################################################
# Variable Extraction
################################################################################

extract_neo_variables() {
    local scss_file="$1"

    debug_log "Extracting neo variables from: $scss_file"

    grep -E '^\$neo_' "$scss_file" | \
    awk -F': ' '
    BEGIN { print "{"; first = 1 }
    {
        # Extract variable name (remove $)
        name = $1
        gsub(/^\$/, "", name)
        gsub(/;.*$/, "", name)

        # Extract value (remove trailing semicolon and comments)
        value = $2
        gsub(/;.*$/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)

        if (!first) print ","
        printf "  \"%s\": \"%s\"", name, value
        first = 0
    }
    END { print "\n}" }'
}

extract_layout_variables() {
    local scss_file="$1"

    debug_log "Extracting layout color variables from: $scss_file"

    grep -E '^\$_layout_color_' "$scss_file" | \
    awk -F': ' '
    BEGIN { print "{"; first = 1 }
    {
        name = $1
        gsub(/^\$/, "", name)

        value = $2
        gsub(/;.*$/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)

        if (!first) print ","
        printf "  \"%s\": \"%s\"", name, value
        first = 0
    }
    END { print "\n}" }'
}

extract_component_variables() {
    local scss_file="$1"
    local component="$2"

    debug_log "Extracting $component variables from: $scss_file"

    grep -E "^\\\$${component}_" "$scss_file" | \
    awk -F': ' '
    BEGIN { print "{"; first = 1 }
    {
        name = $1
        gsub(/^\$/, "", name)

        value = $2
        gsub(/;.*$/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)

        if (!first) print ","
        printf "  \"%s\": \"%s\"", name, value
        first = 0
    }
    END { print "\n}" }'
}

extract_all_variables() {
    local scss_file="$1"

    debug_log "Extracting all variables from: $scss_file"

    grep -E '^\$[a-z_]+:' "$scss_file" | \
    awk -F': ' '
    BEGIN { print "{"; first = 1 }
    {
        name = $1
        gsub(/^\$/, "", name)

        value = $2
        gsub(/;.*$/, "", value)
        gsub(/^[ \t]+|[ \t]+$/, "", value)

        if (!first) print ","
        printf "  \"%s\": \"%s\"", name, value
        first = 0
    }
    END { print "\n}" }'
}

################################################################################
# Main Logic
################################################################################

main() {
    local project_dir="${1:-}"
    local category="${2:-neo}"

    if [[ -z "$project_dir" ]]; then
        error_log "Usage: $0 <project-dir> [category]"
        error_log "  category: neo, layout, colors, sizes, toolbar, header, footer, menu, page, search, all"
        exit 1
    fi

    if [[ ! -d "$project_dir" ]]; then
        error_log "Project directory not found: $project_dir"
        exit 1
    fi

    # Determine which file to read based on category
    local scss_file=""
    case "$category" in
        neo|layout|colors|toolbar|header|footer|menu|page|search|link|all)
            scss_file=$(find_scss_file "$project_dir" "_colors.scss") || {
                error_log "_colors.scss not found in project"
                exit 1
            }
            ;;
        sizes)
            scss_file=$(find_scss_file "$project_dir" "_sizes.scss") || {
                error_log "_sizes.scss not found in project"
                exit 1
            }
            ;;
        *)
            error_log "Unknown category: $category"
            error_log "Valid categories: neo, layout, colors, sizes, toolbar, header, footer, menu, page, search, all"
            exit 1
            ;;
    esac

    success_log "Reading from: $scss_file"

    # Extract variables based on category
    case "$category" in
        neo)
            extract_neo_variables "$scss_file"
            ;;
        layout)
            extract_layout_variables "$scss_file"
            ;;
        colors|all)
            extract_all_variables "$scss_file"
            ;;
        sizes)
            extract_all_variables "$scss_file"
            ;;
        toolbar|header|footer|menu|page|search|link)
            extract_component_variables "$scss_file" "$category"
            ;;
    esac
}

main "$@"
