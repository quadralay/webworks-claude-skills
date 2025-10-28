#!/bin/bash
#
# parse-targets.sh
# Parse ePublisher project files to extract target and format information
#
# Usage:
#   ./parse-targets.sh [OPTIONS] <project-file>
#
# Features:
#   - Extract target names (for AutoMap -t parameter)
#   - Extract format names (for customization paths)
#   - Extract Base Format Version (for customization file sources)
#   - List all targets with details
#   - Validate specific target names
#   - JSON output option for programmatic use
#
# Exit Codes:
#   0 - Success
#   1 - Project file not found or invalid
#   2 - Invalid arguments
#   3 - No targets found in project
#

set -euo pipefail

# Script configuration
SCRIPT_NAME="$(basename "$0")"
OUTPUT_FORMAT="text"
VALIDATE_TARGET=""
LIST_TARGETS=false
SHOW_FORMAT_NAMES=false
SHOW_VERSION=false
VERBOSE=false

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#
# Helper Functions
#

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "[VERBOSE] $*" >&2
    fi
}

log_error() {
    echo "[ERROR] $*" >&2
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <project-file>

Parse ePublisher project files (.wep, .wrp) to extract target and format
information from <Format> XML elements.

REQUIRED:
    <project-file>          Path to .wep or .wrp project file

OPTIONS:
    -l, --list              List all targets with details
    -f, --format-names      Show format names (used for customization paths)
    --version               Show Base Format Version for customizations
    -v, --validate TARGET   Validate that specific target exists
    -j, --json              Output in JSON format
    --verbose               Enable verbose output
    --help                  Show this help message

EXIT CODES:
    0    Success
    1    Project file not found or invalid
    2    Invalid arguments
    3    No targets found in project

EXAMPLES:
    # List all target names (simple)
    $SCRIPT_NAME project.wep

    # List all targets with details
    $SCRIPT_NAME --list project.wep

    # Show format names for customization paths
    $SCRIPT_NAME --format-names project.wep

    # Show Base Format Version
    $SCRIPT_NAME --version project.wep

    # Validate target exists
    $SCRIPT_NAME --validate "WebWorks Reverb 2.0" project.wep

    # JSON output for scripts
    $SCRIPT_NAME --json project.wep

OUTPUT FORMATS:

    Default (target names only):
        WebWorks Reverb 2.0
        PDF - XSL-FO

    --list (detailed):
        Target 1: WebWorks Reverb 2.0
          Format: WebWorks Reverb 2.0
          Type: Application
          ID: CC-Reverb-Target
          Output: Output\WebWorks Reverb 2.0

    --json:
        [
          {
            "targetName": "WebWorks Reverb 2.0",
            "formatName": "WebWorks Reverb 2.0",
            "type": "Application",
            "targetId": "CC-Reverb-Target",
            "outputDirectory": "Output\\WebWorks Reverb 2.0"
          }
        ]
EOF
}

validate_project_file() {
    local project_file="$1"

    # Convert to Unix path for test
    local unix_path
    unix_path=$(cygpath "$project_file" 2>/dev/null || echo "$project_file")

    if [ ! -f "$unix_path" ]; then
        log_error "Project file not found: $project_file"
        return 1
    fi

    # Check file extension
    if [[ ! "$project_file" =~ \.(wep|wrp)$ ]]; then
        log_error "Invalid project file extension: $project_file"
        log_error "Expected: .wep or .wrp"
        return 1
    fi

    return 0
}

extract_targets_text() {
    local project_file="$1"

    log_verbose "Extracting target names from: $project_file"

    # Extract TargetName attribute values
    local targets
    targets=$(grep -oP 'TargetName="\K[^"]+' "$project_file" 2>/dev/null || true)

    if [ -z "$targets" ]; then
        log_error "No targets found in project file"
        return 3
    fi

    echo "$targets"
}

extract_format_names_text() {
    local project_file="$1"

    log_verbose "Extracting format names from: $project_file"

    # Extract Name attribute values from Format elements (not TargetName)
    local formats
    formats=$(grep '<Format ' "$project_file" | grep -oP '\sName="\K[^"]+' 2>/dev/null || true)

    if [ -z "$formats" ]; then
        log_error "No format names found in project file"
        return 3
    fi

    echo "$formats"
}

extract_base_format_version() {
    local project_file="$1"

    log_verbose "Extracting Base Format Version from: $project_file"

    # Extract RuntimeVersion and FormatVersion from Project element
    local runtime_version format_version

    runtime_version=$(grep -oP '<Project[^>]*RuntimeVersion="\K[^"]+' "$project_file" 2>/dev/null || echo "")
    format_version=$(grep -oP '<Project[^>]*FormatVersion="\K[^"]+' "$project_file" 2>/dev/null || echo "")

    if [ -z "$runtime_version" ]; then
        log_error "RuntimeVersion not found in project file"
        return 3
    fi

    # Determine Base Format Version
    local base_format_version
    if [ "$format_version" = "{Current}" ] || [ -z "$format_version" ]; then
        base_format_version="$runtime_version"
    else
        base_format_version="$format_version"
    fi

    echo "$base_format_version"
}

extract_output_directory() {
    local project_file="$1"
    local target_name="$2"

    # Find the Format element for this target and check for OutputDirectory child element
    # Using awk to parse multi-line Format blocks
    local output_dir
    output_dir=$(awk -v target="$target_name" '
        /<Format [^>]*TargetName="/ {
            if ($0 ~ "TargetName=\"" target "\"") {
                in_target = 1
            }
        }
        in_target && /<OutputDirectory>/ {
            match($0, /<OutputDirectory>([^<]+)<\/OutputDirectory>/, arr)
            if (arr[1]) {
                print arr[1]
                exit
            }
        }
        in_target && /<\/Format>/ {
            in_target = 0
        }
    ' "$project_file" || true)

    if [ -n "$output_dir" ]; then
        echo "$output_dir"
    else
        echo "Output\\$target_name"
    fi
}

list_targets_detailed() {
    local project_file="$1"

    log_verbose "Extracting detailed target information from: $project_file"

    # Extract all Format elements
    local format_lines
    format_lines=$(grep '<Format ' "$project_file" || true)

    if [ -z "$format_lines" ]; then
        log_error "No Format elements found in project file"
        return 3
    fi

    local count=1
    while IFS= read -r line; do
        local target_name format_name type target_id output_dir

        target_name=$(echo "$line" | grep -oP 'TargetName="\K[^"]+' || echo "Unknown")
        format_name=$(echo "$line" | grep -oP '\sName="\K[^"]+' || echo "Unknown")
        type=$(echo "$line" | grep -oP 'Type="\K[^"]+' || echo "Unknown")
        target_id=$(echo "$line" | grep -oP 'TargetID="\K[^"]+' || echo "Unknown")
        output_dir=$(extract_output_directory "$project_file" "$target_name")

        echo -e "${GREEN}Target $count:${NC} $target_name"
        echo "  Format: $format_name"
        echo "  Type: $type"
        echo "  ID: $target_id"
        echo "  Output: $output_dir"
        echo ""

        ((count++))
    done <<< "$format_lines"
}

list_targets_json() {
    local project_file="$1"

    log_verbose "Extracting target information in JSON format from: $project_file"

    # Extract all Format elements
    local format_lines
    format_lines=$(grep '<Format ' "$project_file" || true)

    if [ -z "$format_lines" ]; then
        log_error "No Format elements found in project file"
        return 3
    fi

    echo "["

    local first=true
    while IFS= read -r line; do
        local target_name format_name type target_id output_dir

        target_name=$(echo "$line" | grep -oP 'TargetName="\K[^"]+' || echo "Unknown")
        format_name=$(echo "$line" | grep -oP '\sName="\K[^"]+' || echo "Unknown")
        type=$(echo "$line" | grep -oP 'Type="\K[^"]+' || echo "Unknown")
        target_id=$(echo "$line" | grep -oP 'TargetID="\K[^"]+' || echo "Unknown")
        output_dir=$(extract_output_directory "$project_file" "$target_name")

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        cat <<JSON_ENTRY
  {
    "targetName": "$target_name",
    "formatName": "$format_name",
    "type": "$type",
    "targetId": "$target_id",
    "outputDirectory": "$output_dir"
  }
JSON_ENTRY
    done <<< "$format_lines"

    echo ""
    echo "]"
}

validate_target_exists() {
    local project_file="$1"
    local target_to_validate="$2"

    log_verbose "Validating target: $target_to_validate"

    local targets
    targets=$(extract_targets_text "$project_file")

    if echo "$targets" | grep -Fxq "$target_to_validate"; then
        echo -e "${GREEN}✓${NC} Target found: $target_to_validate"
        return 0
    else
        echo -e "${YELLOW}✗${NC} Target not found: $target_to_validate"
        echo ""
        echo "Available targets:"
        echo "$targets" | sed 's/^/  - /'
        return 1
    fi
}

#
# Argument Parsing
#

PROJECT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            LIST_TARGETS=true
            shift
            ;;
        -f|--format-names)
            SHOW_FORMAT_NAMES=true
            shift
            ;;
        --version)
            SHOW_VERSION=true
            shift
            ;;
        -v|--validate)
            if [ -z "${2:-}" ]; then
                log_error "Missing TARGET argument"
                usage
                exit 2
            fi
            VALIDATE_TARGET="$2"
            shift 2
            ;;
        -j|--json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            exit 2
            ;;
        *)
            if [ -n "$PROJECT_FILE" ]; then
                log_error "Multiple project files specified"
                usage
                exit 2
            fi
            PROJECT_FILE="$1"
            shift
            ;;
    esac
done

#
# Validation
#

if [ -z "$PROJECT_FILE" ]; then
    log_error "Project file required"
    usage
    exit 2
fi

if ! validate_project_file "$PROJECT_FILE"; then
    exit 1
fi

#
# Main Execution
#

log_verbose "Parsing project file: $PROJECT_FILE"

# Validate specific target
if [ -n "$VALIDATE_TARGET" ]; then
    if validate_target_exists "$PROJECT_FILE" "$VALIDATE_TARGET"; then
        exit 0
    else
        exit 1
    fi
fi

# JSON output
if [ "$OUTPUT_FORMAT" = "json" ]; then
    list_targets_json "$PROJECT_FILE"
    exit 0
fi

# Detailed list
if [ "$LIST_TARGETS" = true ]; then
    list_targets_detailed "$PROJECT_FILE"
    exit 0
fi

# Format names only
if [ "$SHOW_FORMAT_NAMES" = true ]; then
    extract_format_names_text "$PROJECT_FILE"
    exit 0
fi

# Base Format Version
if [ "$SHOW_VERSION" = true ]; then
    extract_base_format_version "$PROJECT_FILE"
    exit 0
fi

# Default: target names only
extract_targets_text "$PROJECT_FILE"
exit 0
