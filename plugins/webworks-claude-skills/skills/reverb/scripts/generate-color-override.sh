#!/bin/bash
################################################################################
# generate-color-override.sh
#
# Generates a minimal _colors.scss override file with brand colors.
# Creates only the essential neo variable overrides for quick theming.
#
# Usage:
#   ./generate-color-override.sh <output-path> [options]
#
# Options:
#   --main-color <hex>      Primary brand color (default: #008bff)
#   --main-text <hex>       Text on primary (default: #ffffff)
#   --secondary-color <hex> Secondary/sidebar bg (default: #eeeeee)
#   --secondary-text <hex>  Text on dark bg (default: #222222)
#   --tertiary-color <hex>  Tertiary accents (default: #222222)
#   --page-color <hex>      Page background (default: #fefefe)
#   --full                  Generate full _colors.scss instead of minimal
#   --base-file <path>      Use this file as base for full generation
#
################################################################################

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Defaults
MAIN_COLOR="#008bff"
MAIN_TEXT="#ffffff"
SECONDARY_COLOR="#eeeeee"
SECONDARY_TEXT="#222222"
TERTIARY_COLOR="#222222"
PAGE_COLOR="#fefefe"
FULL_MODE=false
BASE_FILE=""

error_log() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

success_log() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

################################################################################
# Argument Parsing
################################################################################

parse_args() {
    OUTPUT_PATH=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --main-color)
                MAIN_COLOR="$2"
                shift 2
                ;;
            --main-text)
                MAIN_TEXT="$2"
                shift 2
                ;;
            --secondary-color)
                SECONDARY_COLOR="$2"
                shift 2
                ;;
            --secondary-text)
                SECONDARY_TEXT="$2"
                shift 2
                ;;
            --tertiary-color)
                TERTIARY_COLOR="$2"
                shift 2
                ;;
            --page-color)
                PAGE_COLOR="$2"
                shift 2
                ;;
            --full)
                FULL_MODE=true
                shift
                ;;
            --base-file)
                BASE_FILE="$2"
                shift 2
                ;;
            -*)
                error_log "Unknown option: $1"
                exit 1
                ;;
            *)
                if [[ -z "$OUTPUT_PATH" ]]; then
                    OUTPUT_PATH="$1"
                else
                    error_log "Unexpected argument: $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$OUTPUT_PATH" ]]; then
        error_log "Usage: $0 <output-path> [options]"
        error_log ""
        error_log "Options:"
        error_log "  --main-color <hex>      Primary brand color"
        error_log "  --main-text <hex>       Text on primary backgrounds"
        error_log "  --secondary-color <hex> Secondary/sidebar background"
        error_log "  --secondary-text <hex>  Text on dark backgrounds"
        error_log "  --tertiary-color <hex>  Tertiary accents"
        error_log "  --page-color <hex>      Page background"
        error_log "  --full                  Generate full _colors.scss"
        error_log "  --base-file <path>      Base file for full generation"
        exit 1
    fi
}

################################################################################
# Color Validation
################################################################################

validate_hex_color() {
    local color="$1"
    local name="$2"

    if [[ ! "$color" =~ ^#[0-9A-Fa-f]{6}$ ]] && [[ ! "$color" =~ ^#[0-9A-Fa-f]{3}$ ]]; then
        error_log "Invalid hex color for $name: $color"
        error_log "Expected format: #RRGGBB or #RGB"
        exit 1
    fi
}

################################################################################
# Generation Functions
################################################################################

generate_minimal_override() {
    local output_path="$1"

    cat > "$output_path" << EOF
/*~~~~~ COLORS ~~~~~*/
/*~~~~~~~~~~~~~~~~~~*/
/* Brand color override - Generated $(date '+%Y-%m-%d %H:%M') */

/* Primary brand colors */
\$neo_main_color: $MAIN_COLOR;
\$neo_main_text_color: $MAIN_TEXT;
\$neo_secondary_color: $SECONDARY_COLOR;
\$neo_secondary_text_color: $SECONDARY_TEXT;
\$neo_tertiary_color: $TERTIARY_COLOR;
\$neo_page_color: $PAGE_COLOR;

/* Layout colors - cascade from neo variables */
\$_layout_color_1: \$neo_main_color;
\$_layout_color_2: \$neo_main_text_color;
\$_layout_color_3: \$neo_secondary_color;
\$_layout_color_4: \$neo_secondary_text_color;
\$_layout_color_5: \$neo_tertiary_color;
\$_layout_color_6: \$neo_page_color;

/* Link colors */
\$link_default_color: \$_layout_color_1;
\$link_visited_color: darken(\$link_default_color, 20%);
\$link_active_color: lighten(\$link_default_color, 20%);

/* Toolbar */
\$toolbar_background_color: \$_layout_color_1;
\$toolbar_text_color: \$_layout_color_4;
\$toolbar_icon_color: \$_layout_color_4;

/* Menu/TOC */
\$menu_background_color: \$_layout_color_3;
\$menu_text_color: \$_layout_color_2;

/* Page */
\$page_background_color: \$_layout_color_6;

/* Header */
\$header_background_color: \$_layout_color_5;
\$header_text_color: \$_layout_color_4;

/* Footer */
\$footer_background_color: \$_layout_color_5;
\$footer_text_color: \$_layout_color_4;

/* Search */
\$search_background_color: \$_layout_color_6;

/* Back to top */
\$back_to_top_background_color: \$_layout_color_1;
\$back_to_top_caret_color: \$_layout_color_4;
EOF

    success_log "Generated minimal override: $output_path"
}

generate_full_override() {
    local output_path="$1"
    local base_file="$2"

    if [[ ! -f "$base_file" ]]; then
        error_log "Base file not found: $base_file"
        exit 1
    fi

    # Copy base file and replace neo variables
    sed -e "s/\\\$neo_main_color: [^;]*;/\$neo_main_color: $MAIN_COLOR;/" \
        -e "s/\\\$neo_main_text_color: [^;]*;/\$neo_main_text_color: $MAIN_TEXT;/" \
        -e "s/\\\$neo_secondary_color: [^;]*;/\$neo_secondary_color: $SECONDARY_COLOR;/" \
        -e "s/\\\$neo_secondary_text_color: [^;]*;/\$neo_secondary_text_color: $SECONDARY_TEXT;/" \
        -e "s/\\\$neo_tertiary_color: [^;]*;/\$neo_tertiary_color: $TERTIARY_COLOR;/" \
        -e "s/\\\$neo_page_color: [^;]*;/\$neo_page_color: $PAGE_COLOR;/" \
        "$base_file" > "$output_path"

    success_log "Generated full override from base: $output_path"
}

################################################################################
# Main Logic
################################################################################

main() {
    parse_args "$@"

    # Validate colors
    validate_hex_color "$MAIN_COLOR" "main-color"
    validate_hex_color "$MAIN_TEXT" "main-text"
    validate_hex_color "$SECONDARY_COLOR" "secondary-color"
    validate_hex_color "$SECONDARY_TEXT" "secondary-text"
    validate_hex_color "$TERTIARY_COLOR" "tertiary-color"
    validate_hex_color "$PAGE_COLOR" "page-color"

    # Create output directory if needed
    local output_dir
    output_dir=$(dirname "$OUTPUT_PATH")
    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir"
    fi

    # Generate file
    if [[ "$FULL_MODE" == true ]]; then
        if [[ -z "$BASE_FILE" ]]; then
            error_log "--full requires --base-file to be specified"
            exit 1
        fi
        generate_full_override "$OUTPUT_PATH" "$BASE_FILE"
    else
        generate_minimal_override "$OUTPUT_PATH"
    fi

    echo ""
    echo "Color summary:"
    echo "  Main color:      $MAIN_COLOR (toolbar, buttons, links)"
    echo "  Main text:       $MAIN_TEXT (text on primary)"
    echo "  Secondary color: $SECONDARY_COLOR (sidebar background)"
    echo "  Secondary text:  $SECONDARY_TEXT (dark text)"
    echo "  Tertiary color:  $TERTIARY_COLOR (header/footer bg)"
    echo "  Page color:      $PAGE_COLOR (page background)"
}

main "$@"
