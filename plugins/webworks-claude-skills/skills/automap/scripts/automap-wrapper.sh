#!/bin/bash
#
# automap-wrapper.sh
# Wrapper script for WebWorks ePublisher AutoMap CLI
#
# This wrapper automatically detects the AutoMap CLI installation and executes
# builds with proper argument handling, output parsing, and error detection.
#
# Note: The detection script finds the AutoMap Administrator executable via
# registry or filesystem, then normalizes to the CLI executable for headless
# automation.
#
# Usage:
#   ./automap-wrapper.sh [OPTIONS] <project-file>
#
# Features:
#   - Automatic AutoMap CLI detection (via registry or filesystem)
#   - Proper argument handling and quoting
#   - Output parsing and error detection
#   - Exit code reporting
#   - Progress monitoring
#
# Exit Codes:
#   0   - Build succeeded
#   1   - Build failed
#   2   - Invalid arguments
#   3   - AutoMap not found
#   4   - Project file not found
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"
DETECT_SCRIPT="$SCRIPT_DIR/detect-installation.sh"

# Default options
CLEAN_BUILD=false
CLEAN_DEPLOY=false
NO_DEPLOY=false
SKIP_REPORTS=false
TARGET=""
DEPLOY_FOLDER=""
AUTOMAP_VERSION=""
VERBOSE=false
QUIET=false
ERRORS_ONLY=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#
# Helper Functions
#

log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "[VERBOSE] $*" >&2
    fi
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <project-file>

Wrapper script for WebWorks ePublisher AutoMap CLI with automatic detection
and enhanced error reporting.

REQUIRED:
    <project-file>          Path to .wep, .wrp, or .wxsp project file

OPTIONS:
    -c, --clean            Clean build (remove cached files)
    -n, --nodeploy         Do not copy files to deployment location
    -l, --cleandeploy      Clean deployment location before copying output
    -t, --target TARGET    Build specific target only
    --deployfolder PATH    Override deployment destination
    --skip-reports         Skip report pipelines (2025.1+)
    --verbose              Enable verbose output
    --quiet                Suppress informational messages
    --errors-only          Show only errors and final status (minimal output)
    --help                 Show this help message

EXIT CODES:
    0    Build succeeded
    1    Build failed
    2    Invalid arguments
    3    AutoMap not found
    4    Project file not found

EXAMPLES:
    # Build all targets with clean
    $SCRIPT_NAME -c -n project.wep

    # Build specific target
    $SCRIPT_NAME -c -n -t "WebWorks Reverb 2.0" project.wep

    # Fast CI build (skip reports, 2025.1+)
    $SCRIPT_NAME -c -n --skip-reports project.wep

    # Build with custom deployment and delete existing files at deployment location
    $SCRIPT_NAME -l --deployfolder "C:\\Output" project.wep

    # Quiet mode (suppress info messages)
    $SCRIPT_NAME --quiet -c -n project.wep

    # Minimal output for AI/automation (suppress all stdout)
    $SCRIPT_NAME --errors-only -c -n project.wep
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
    if [[ ! "$project_file" =~ \.(wep|wrp|wxsp)$ ]]; then
        log_warning "Project file has unexpected extension: $project_file"
        log_warning "Expected: .wep, .wrp, or .wxsp"
    fi

    return 0
}

detect_automap_executable() {
    local version="$1"

    log_verbose "Detecting AutoMap installation..."

    if [ ! -x "$DETECT_SCRIPT" ]; then
        log_error "Detection script not found or not executable: $DETECT_SCRIPT"
        return 1
    fi

    local detect_args=()
    if [ "$VERBOSE" = true ]; then
        detect_args+=(--verbose)
    fi

    local automap_path
    if ! automap_path=$("$DETECT_SCRIPT" "${detect_args[@]}"); then
        log_error "AutoMap installation not found"
        if [ -n "$version" ]; then
            log_error "Requested version: $version"
        fi
        return 1
    fi

    echo "$automap_path"
    return 0
}

build_automap_command() {
    local automap_path="$1"
    local project_file="$2"

    # Start with quoted executable path
    local cmd="\"$automap_path\""

    # Add clean flags
    if [ "$CLEAN_BUILD" = true ]; then
        cmd="$cmd -c"
    fi

    if [ "$CLEAN_DEPLOY" = true ]; then
        cmd="$cmd -l"
    fi

    # Add no deploy flags
    if [ "$NO_DEPLOY" = true ]; then
        cmd="$cmd -n"
    fi

    # Add target if specified
    if [ -n "$TARGET" ]; then
        cmd="$cmd -t \"$TARGET\""
    fi

    # Add deploy folder if specified
    if [ -n "$DEPLOY_FOLDER" ]; then
        cmd="$cmd --deployfolder \"$DEPLOY_FOLDER\""
    fi

    # Add skip reports flag (2025.1+)
    if [ "$SKIP_REPORTS" = true ]; then
        cmd="$cmd --skip-reports"
    fi

    # Add project file (always last)
    cmd="$cmd \"$project_file\""

    echo "$cmd"
}

parse_automap_output() {
    local output_line="$1"

    # Check for success indicators
    if echo "$output_line" | grep -qi "generation completed successfully"; then
        log_success "$output_line"
        return 0
    fi

    if echo "$output_line" | grep -qi "output deployed to"; then
        log_success "$output_line"
        return 0
    fi

    # Check for error patterns
    if echo "$output_line" | grep -qiE "(^Error:|Failed to|Unable to|Exception)"; then
        log_error "$output_line"
        return 0
    fi

    # Check for warning patterns
    if echo "$output_line" | grep -qiE "(^Warning:|Could not find)"; then
        log_warning "$output_line"
        return 0
    fi

    # Check for progress indicators
    if echo "$output_line" | grep -qiE "(Processing|Generating|Transforming|Building)"; then
        log_info "$output_line"
        return 0
    fi

    # Default: just echo the line if not quiet
    if [ "$QUIET" = false ]; then
        echo "$output_line"
    fi
}

execute_automap() {
    local cmd="$1"
    local exit_code=0
    local start_time end_time duration

    start_time=$(date +%s)

    if [ "$ERRORS_ONLY" = true ]; then
        # Minimal output mode: suppress stdout, stderr passes through naturally
        log_info "Building... (errors-only mode)"

        eval "$cmd" > /dev/null
        exit_code=$?
    else
        # Standard mode: parse all output
        log_info "Executing AutoMap..."
        log_verbose "Command: $cmd"

        eval "$cmd" 2>&1 | while IFS= read -r line; do
            parse_automap_output "$line"
        done || exit_code=$?
    fi

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    if [ $exit_code -eq 0 ]; then
        log_success "Build completed in ${duration}s"
    else
        log_error "Build failed with exit code $exit_code after ${duration}s"
    fi

    return $exit_code
}

#
# Argument Parsing
#

PROJECT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -n)
            NO_DEPLOY=true
            shift
            ;;
        -l|--cleandeploy)
            CLEAN_DEPLOY=true
            shift
            ;;
        -t|--target)
            if [ -z "${2:-}" ]; then
                log_error "Missing TARGET argument"
                usage
                exit 2
            fi
            TARGET="$2"
            shift 2
            ;;
        --deployfolder)
            if [ -z "${2:-}" ]; then
                log_error "Missing PATH argument"
                usage
                exit 2
            fi
            DEPLOY_FOLDER="$2"
            shift 2
            ;;
        --skip-reports)
            SKIP_REPORTS=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --errors-only)
            ERRORS_ONLY=true
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
    exit 4
fi

#
# Main Execution
#

# Handle flag conflicts
if [ "$ERRORS_ONLY" = true ] && [ "$VERBOSE" = true ]; then
    log_warning "Conflicting flags: --errors-only and --verbose. Using --errors-only."
    VERBOSE=false
fi

log_verbose "Starting AutoMap wrapper..."
log_verbose "Project file: $PROJECT_FILE"

# Detect AutoMap installation
if ! automap_path=$(detect_automap_executable "$AUTOMAP_VERSION"); then
    exit 3
fi

log_info "Using AutoMap: $automap_path"

# Build command
automap_cmd=$(build_automap_command "$automap_path" "$PROJECT_FILE")

# Execute AutoMap
if execute_automap "$automap_cmd"; then
    exit 0
else
    exit 1
fi
