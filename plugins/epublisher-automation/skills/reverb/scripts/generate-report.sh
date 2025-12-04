#!/bin/bash
################################################################################
# generate-report.sh
#
# Generates a comprehensive human-readable report from Reverb analysis results.
# Combines project info, CSH data, and browser test results into formatted output.
#
# Usage:
#   ./generate-report.sh <project-file> <project-info-json> <csh-data-json> <test-results-json>
#
# Arguments:
#   project-file       - Path to .wep project file
#   project-info-json  - JSON with project/target information
#   csh-data-json      - JSON array of CSH links
#   test-results-json  - JSON with browser test results
#
################################################################################

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

################################################################################
# JSON Parsing Helpers
################################################################################

json_get() {
    local json="$1"
    local key="$2"
    # Compact JSON (remove newlines/extra spaces) then extract value
    echo "$json" | tr -d '\n' | tr -s ' ' | grep -oP "(?<=\"$key\":)[^,}]*" | sed 's/"//g; s/^ *//' || echo ""
}

json_count_array() {
    local json="$1"
    local key="$2"
    echo "$json" | tr -d '\n' | grep -oP "(?<=\"$key\":)\[.*?\]" | grep -o "{" | wc -l || echo "0"
}

# Extract value from nested object: json_get_nested "$json" "components" "toolbar" "present"
json_get_nested() {
    local json="$1"
    local parent="$2"
    local child="$3"
    local key="$4"
    # Compact JSON and extract nested value
    echo "$json" | tr -d '\n' | tr -s ' ' | \
        grep -oP "\"$parent\":\{[^}]*\"$child\":\{[^}]*\"$key\":\s*[^,}]*" | \
        grep -oP "\"$key\":\s*[^,}]*" | \
        sed 's/.*://; s/"//g; s/^ *//' || echo ""
}

################################################################################
# Report Sections
################################################################################

print_header() {
    local project_file="$1"
    local target_name="$2"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║          Reverb Output Analysis Report                              ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Project:${NC} $(basename "$project_file")"
    echo -e "${BLUE}Target:${NC} $target_name"
    echo -e "${BLUE}Generated:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

print_browser_test_results() {
    local test_results="$1"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD} Browser Test Results${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    local reverb_loaded
    reverb_loaded=$(json_get "$test_results" "reverbLoaded")

    local load_time
    load_time=$(json_get "$test_results" "loadTime")

    local error_count
    error_count=$(json_get "$test_results" "errorCount")

    local warning_count
    warning_count=$(json_get "$test_results" "warningCount")

    if [[ "$reverb_loaded" == "true" ]]; then
        echo -e "${GREEN}✅ Reverb Runtime${NC}"
        echo -e "   • Loaded successfully"
        echo -e "   • Load time: ${load_time}ms"
    else
        echo -e "${RED}❌ Reverb Runtime${NC}"
        echo -e "   • Failed to load"
    fi

    echo ""

    if [[ "$error_count" -eq 0 ]]; then
        echo -e "${GREEN}✅ JavaScript Errors${NC}"
        echo -e "   • No errors detected"
    else
        echo -e "${RED}❌ JavaScript Errors${NC}"
        echo -e "   • $error_count errors found"
        echo ""
        # Extract and display errors
        echo "$test_results" | grep -oP '(?<="message":")[^"]*' | head -n 10 | while read -r error; do
            echo -e "   ${RED}•${NC} $error"
        done
    fi

    echo ""

    if [[ "$warning_count" -eq 0 ]]; then
        echo -e "${GREEN}✅ Console Warnings${NC}"
        echo -e "   • No warnings detected"
    else
        echo -e "${YELLOW}⚠ Console Warnings${NC}"
        echo -e "   • $warning_count warnings found"
    fi
}

print_csh_results() {
    local csh_data="$1"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD} Context Sensitive Help (CSH)${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ "$csh_data" == "[]" ]]; then
        echo -e "${BLUE}ℹ No CSH Links Configured${NC}"
        echo -e "   • url_maps.xml has empty TopicMap"
        return
    fi

    local csh_count
    csh_count=$(echo "$csh_data" | grep -o '"id"' | wc -l)

    echo -e "${GREEN}✅ CSH Links: $csh_count configured${NC}"
    echo ""

    # Display CSH table
    echo -e "${BOLD}ID       URL                                    Title${NC}"
    echo "───────────────────────────────────────────────────────────────────────"

    echo "$csh_data" | grep -oP '"id":"[^"]*"' | sed 's/"id":"//;s/"$//' > /tmp/csh_ids.txt || true
    echo "$csh_data" | grep -oP '"url":"[^"]*"' | sed 's/"url":"//;s/"$//' > /tmp/csh_urls.txt || true
    echo "$csh_data" | grep -oP '"title":"[^"]*"' | sed 's/"title":"//;s/"$//' > /tmp/csh_titles.txt || true

    paste /tmp/csh_ids.txt /tmp/csh_urls.txt /tmp/csh_titles.txt 2>/dev/null | \
    while IFS=$'\t' read -r id url title; do
        printf "%-8s %-40s %s\n" "$id" "$url" "$title"
    done || true

    rm -f /tmp/csh_ids.txt /tmp/csh_urls.txt /tmp/csh_titles.txt
}

print_component_analysis() {
    local test_results="$1"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD} Component Analysis${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Compact JSON once for all component parsing
    local compact_json
    compact_json=$(echo "$test_results" | tr -d '\n' | tr -s ' ')

    # Toolbar
    local toolbar_present
    toolbar_present=$(echo "$compact_json" | grep -oP '"toolbar":\s*\{[^}]*"present":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

    if [[ "$toolbar_present" == "true" ]]; then
        echo -e "${GREEN}✅ Toolbar${NC} (#toolbar_div)"

        local toolbar_logo
        toolbar_logo=$(echo "$compact_json" | grep -oP '"toolbar":\s*\{[^}]*"logo":\s*"[^"]*"' | grep -oP '"logo":\s*"[^"]*"' | sed 's/"logo":\s*"//; s/"$//' || echo "none")

        if [[ "$toolbar_logo" != "none" && "$toolbar_logo" != "null" && -n "$toolbar_logo" ]]; then
            echo -e "   • Logo: $toolbar_logo"
        else
            echo -e "   • Logo: none"
        fi

        local toolbar_search
        toolbar_search=$(echo "$compact_json" | grep -oP '"toolbar":\s*\{[^}]*"searchPresent":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

        if [[ "$toolbar_search" == "true" ]]; then
            echo -e "   • Search: enabled"
        else
            echo -e "   • Search: disabled"
        fi
    else
        echo -e "${BLUE}○ Toolbar${NC} (not configured)"
    fi

    # Header
    local header_present
    header_present=$(echo "$compact_json" | grep -oP '"header":\s*\{[^}]*"present":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

    if [[ "$header_present" == "true" ]]; then
        echo -e "${GREEN}✅ Header${NC} (#header_div)"

        local header_logo
        header_logo=$(echo "$compact_json" | grep -oP '"header":\s*\{[^}]*"logo":\s*"[^"]*"' | grep -oP '"logo":\s*"[^"]*"' | sed 's/"logo":\s*"//; s/"$//' || echo "none")

        if [[ "$header_logo" != "none" && "$header_logo" != "null" && -n "$header_logo" ]]; then
            echo -e "   • Logo: $header_logo"
        else
            echo -e "   • Logo: none"
        fi
    else
        echo -e "${BLUE}○ Header${NC} (not configured)"
    fi

    # Footer
    local footer_present
    footer_present=$(echo "$compact_json" | grep -oP '"footer":\s*\{[^}]*"present":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

    if [[ "$footer_present" == "true" ]]; then
        local footer_type
        footer_type=$(echo "$compact_json" | grep -oP '"footer":\s*\{[^}]*"type":\s*"[^"]*"' | grep -oP '"type":\s*"[^"]*"' | sed 's/"type":\s*"//; s/"$//' || echo "unknown")
        echo -e "${GREEN}✅ Footer${NC} (#footer_div, type: $footer_type)"

        local footer_logo
        footer_logo=$(echo "$compact_json" | grep -oP '"footer":\s*\{[^}]*"logo":\s*"[^"]*"' | grep -oP '"logo":\s*"[^"]*"' | sed 's/"logo":\s*"//; s/"$//' || echo "none")

        if [[ "$footer_logo" != "none" && "$footer_logo" != "null" && -n "$footer_logo" ]]; then
            echo -e "   • Logo: $footer_logo"
        else
            echo -e "   • Logo: none"
        fi
    else
        echo -e "${BLUE}○ Footer${NC} (not configured)"
    fi

    # TOC Menu
    local toc_present
    toc_present=$(echo "$compact_json" | grep -oP '"toc":\s*\{[^}]*"present":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

    if [[ "$toc_present" == "true" ]]; then
        echo -e "${GREEN}✅ TOC Menu${NC} (#toc)"

        local toc_expanded
        toc_expanded=$(echo "$compact_json" | grep -oP '"toc":\s*\{[^}]*"expanded":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

        if [[ "$toc_expanded" == "true" ]]; then
            echo -e "   • Initial state: expanded"
        else
            echo -e "   • Initial state: collapsed"
        fi

        local toc_items
        toc_items=$(echo "$compact_json" | grep -oP '"toc":\s*\{[^}]*"itemCount":\s*[0-9]+' | grep -oP '[0-9]+$' || echo "0")
        echo -e "   • Items: $toc_items"
    else
        echo -e "${BLUE}○ TOC Menu${NC} (not configured)"
    fi

    # Content Area
    local content_present
    content_present=$(echo "$compact_json" | grep -oP '"content":\s*\{[^}]*"present":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")

    if [[ "$content_present" == "true" ]]; then
        echo -e "${GREEN}✅ Content Area${NC} (#page_div)"
        local has_iframe
        has_iframe=$(echo "$compact_json" | grep -oP '"content":\s*\{[^}]*"hasIframe":\s*(true|false)' | grep -oP '(true|false)$' || echo "false")
        if [[ "$has_iframe" == "true" ]]; then
            echo -e "   • Content iframe: loaded"
        fi
    else
        echo -e "${RED}❌ Content Area${NC} (MISSING - this is required)"
    fi
}

print_summary() {
    local test_results="$1"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD} Summary${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    local error_count
    error_count=$(json_get "$test_results" "errorCount")

    local warning_count
    warning_count=$(json_get "$test_results" "warningCount")

    if [[ "$error_count" -eq 0 ]]; then
        echo -e "${GREEN}✅ Status: PASS${NC}"
    else
        echo -e "${RED}❌ Status: FAIL${NC}"
    fi

    echo -e "   • Errors: $error_count"
    echo -e "   • Warnings: $warning_count"

    # Count active components (compact JSON first)
    local compact_json
    compact_json=$(echo "$test_results" | tr -d '\n' | tr -s ' ')
    local components_active=0

    echo "$compact_json" | grep -q '"toolbar":[^}]*"present":\s*true' && ((components_active++)) || true
    echo "$compact_json" | grep -q '"header":[^}]*"present":\s*true' && ((components_active++)) || true
    echo "$compact_json" | grep -q '"footer":[^}]*"present":\s*true' && ((components_active++)) || true
    echo "$compact_json" | grep -q '"toc":[^}]*"present":\s*true' && ((components_active++)) || true
    echo "$compact_json" | grep -q '"content":[^}]*"present":\s*true' && ((components_active++)) || true

    echo -e "   • Active components: $components_active"
    echo ""
}

################################################################################
# Main Logic
################################################################################

main() {
    if [[ $# -lt 4 ]]; then
        echo "Usage: $0 <project-file> <project-info-json> <csh-data-json> <test-results-json>" >&2
        exit 1
    fi

    local project_file="$1"
    local project_info="$2"
    local csh_data="$3"
    local test_results="$4"

    # Extract target name from project info
    local target_name
    target_name=$(json_get "$project_info" "target_name")

    # Print report sections
    print_header "$project_file" "$target_name"
    print_browser_test_results "$test_results"
    print_csh_results "$csh_data"
    print_component_analysis "$test_results"
    print_summary "$test_results"

    echo ""
}

main "$@"
