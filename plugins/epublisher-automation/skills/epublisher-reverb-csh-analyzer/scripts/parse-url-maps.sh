#!/bin/bash
################################################################################
# parse-url-maps.sh
#
# Parses url_maps.xml from Reverb output to extract Context Sensitive Help (CSH)
# link mappings. Returns JSON with all CSH entries.
#
# Usage:
#   ./parse-url-maps.sh <url-maps-file>
#
# Arguments:
#   url-maps-file - Path to url_maps.xml from Reverb output
#
# Output:
#   JSON array of CSH mappings with topic_id, url, static_url, and title
#
# Example url_maps.xml structure:
#   <URLMaps>
#     <TopicMap>
#       <Topic topic="whats_new" path="Getting Started\whats_new.html"
#              href="#context/whats_new" title="What's New" />
#       <Topic topic="advanced" path="Advanced\advanced.html"
#              href="#context/advanced" title="Advanced Features" />
#     </TopicMap>
#   </URLMaps>
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
# XML Parsing Logic
################################################################################

parse_url_maps() {
    local url_maps_file="$1"

    debug_log "Parsing url_maps.xml: $url_maps_file"

    # Check if file exists
    if [[ ! -f "$url_maps_file" ]]; then
        error_log "url_maps.xml not found: $url_maps_file"
        echo "[]"
        return 1
    fi

    # Check if TopicMap section exists and has entries
    if ! grep -q '<TopicMap' "$url_maps_file"; then
        debug_log "No TopicMap section found in url_maps.xml"
        echo "[]"
        return 0
    fi

    # Extract Topic elements within TopicMap (note: '<Topic ' with space to exclude TopicMap)
    local topics
    topics=$(grep -A 10000 '<TopicMap' "$url_maps_file" | \
              grep '</TopicMap' -B 10000 | \
              grep '<Topic ' || true)

    if [[ -z "$topics" ]]; then
        debug_log "TopicMap is empty (no CSH links configured)"
        echo "[]"
        return 0
    fi

    # Count topics (grep -c counts actual matches, not lines)
    local count
    count=$(echo "$topics" | grep -c '<Topic ' || echo "0")
    success_log "Found $count CSH topics"

    # Convert XML Topic elements to JSON array
    echo "$topics" | awk '
    BEGIN {
        print "["
        first = 1
    }
    {
        # Extract topic, href, path, title attributes
        topic_id = ""
        url = ""
        static_url = ""
        title = ""

        if (match($0, /topic="([^"]+)"/, arr)) {
            topic_id = arr[1]
        }
        if (match($0, /href="([^"]+)"/, arr)) {
            url = arr[1]
        }
        if (match($0, /path="([^"]+)"/, arr)) {
            path = arr[1]
            # Convert backslashes to forward slashes for web URLs
            gsub(/\\/, "/", path)
            static_url = path
        }
        if (match($0, /title="([^"]+)"/, arr)) {
            title = arr[1]
        }

        if (topic_id != "" && url != "" && static_url != "") {
            if (!first) print ","
            printf "  {\"topic_id\":\"%s\",\"url\":\"%s\",\"static_url\":\"%s\",\"title\":\"%s\"}", topic_id, url, static_url, title
            first = 0
        }
    }
    END {
        print ""
        print "]"
    }'
}

################################################################################
# Human-Readable Output
################################################################################

format_csh_table() {
    local json="$1"

    # Check if JSON is empty array
    if [[ "$json" == "[]" ]]; then
        echo "No Context Sensitive Help links configured"
        return
    fi

    # Format as table
    echo "Context Sensitive Help Links:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Topic ID              URL                           Static URL (no javascript)     Title"
    echo "────────────────────────────────────────────────────────────────────────────────────────────"

    echo "$json" | grep -oP '(?<="topic_id":")[^"]*' > /tmp/topic_ids.txt || true
    echo "$json" | grep -oP '(?<="url":")[^"]*' > /tmp/urls.txt || true
    echo "$json" | grep -oP '(?<="static_url":")[^"]*' > /tmp/static_urls.txt || true
    echo "$json" | grep -oP '(?<="title":")[^"]*' > /tmp/titles.txt || true

    paste /tmp/topic_ids.txt /tmp/urls.txt /tmp/static_urls.txt /tmp/titles.txt 2>/dev/null | \
    while IFS=$'\t' read -r topic_id url static_url title; do
        printf "%-21s %-29s %-30s %s\n" "$topic_id" "$url" "$static_url" "$title"
    done

    rm -f /tmp/topic_ids.txt /tmp/urls.txt /tmp/static_urls.txt /tmp/titles.txt
}

################################################################################
# Main Logic
################################################################################

main() {
    local url_maps_file="${1:-}"
    local format="${2:-json}"

    if [[ -z "$url_maps_file" ]]; then
        error_log "Usage: $0 <url-maps-file> [format]"
        error_log "  format: json (default) or table"
        exit 1
    fi

    # Parse url_maps.xml
    local json_result
    json_result=$(parse_url_maps "$url_maps_file")

    # Output based on format
    case "$format" in
        json)
            echo "$json_result"
            ;;
        table)
            format_csh_table "$json_result"
            ;;
        *)
            error_log "Unknown format: $format (use 'json' or 'table')"
            exit 1
            ;;
    esac
}

main "$@"
