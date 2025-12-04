---
name: epublisher-reverb-csh-analyzer
description: Analyzes Context Sensitive Help (CSH) configuration in WebWorks Reverb 2.0 output. Parses url_maps.xml to extract CSH topic mappings (@topic, @path, @href, @title), validates structure, and generates reports in JSON or table format. Fast file-based analysis with no browser required.
allowed-tools: Bash, Read
metadata:
  version: "2.0.0"
  category: "analysis"
  status: "production"
  related-skills:
    - epublisher-reverb-browser-test
    - epublisher-reverb-test-orchestrator
---

# Reverb CSH Analyzer

Fast file-based analysis of Context Sensitive Help (CSH) configuration in Reverb 2.0 output.

## Purpose

**Core Capabilities:**
- Parse `url_maps.xml` from Reverb output directory
- Extract all `<Topic>` elements from `<TopicMap>`
- Validate CSH structure and attributes
- Generate reports in JSON or human-readable table format
- Convert Windows paths to web-friendly format (backslashes → forward slashes)

**Format Support:** WebWorks Reverb 2.0 only

**No Dependencies:** Pure bash script - no Node.js or browser required

## Quick Start

### Usage

```bash
cd plugins/epublisher-automation/skills/epublisher-reverb-csh-analyzer

# JSON output (default)
./scripts/parse-url-maps.sh "path/to/Output/Target 1/url_maps.xml"

# Human-readable table
./scripts/parse-url-maps.sh "path/to/Output/Target 1/url_maps.xml" table
```

## CSH URL Types

Reverb 2.0 provides two URL types for each CSH topic:

**1. Pretty URL** (`@href` attribute)
- Format: `#context/topic-id`
- Example: `#context/whats_new`
- Requires JavaScript to resolve to HTML page
- User-friendly, shareable links

**2. Static URL** (`@path` attribute)
- Format: Direct path to HTML file
- Example: `"Getting Started\whats_new.html"` → `"Getting Started/whats_new.html"`
- Works without JavaScript (fallback)
- Backslashes converted to forward slashes for web URLs

## Output Formats

### JSON Output

```json
[
  {
    "topic_id": "whats_new",
    "url": "#context/whats_new",
    "static_url": "Getting Started/whats_new.html",
    "title": "What's New"
  }
]
```

### Table Output

```
Context Sensitive Help Links:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Topic ID              URL                           Static URL (no javascript)     Title
────────────────────────────────────────────────────────────────────────────────────────────
whats_new             #context/whats_new            Getting Started/whats_new.html  What's New
advanced              #context/advanced             Advanced/advanced.html          Advanced Features
```

### Empty TopicMap

If no CSH links configured:
```json
[]
```

Or:
```
No Context Sensitive Help links configured
```

## XML Structure

**url_maps.xml structure:**

```xml
<URLMaps>
  <TopicMap>
    <Topic topic="whats_new"
           path="Getting Started\whats_new.html"
           href="#context/whats_new"
           title="What's New"/>
  </TopicMap>
</URLMaps>
```

**Attribute Mapping:**

| XML Attribute | JSON Field | Description |
|---------------|------------|-------------|
| `@topic` | `topic_id` | CSH identifier |
| `@href` | `url` | Pretty JavaScript URL |
| `@path` | `static_url` | Direct HTML path (backslashes → forward slashes) |
| `@title` | `title` | Display name |

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `parse-url-maps.sh` | Parse url_maps.xml and extract CSH topics |

## Common Workflows

### Quick CSH Check

```bash
# Check if CSH configured
./scripts/parse-url-maps.sh "Output/Target 1/url_maps.xml"
```

### Generate CSH Report

```bash
# Table format for human review
./scripts/parse-url-maps.sh "Output/Target 1/url_maps.xml" table > csh-report.txt
```

### Integration with Build

```bash
# After AutoMap build
./scripts/automap-wrapper.sh -c -n project.wep

# Analyze CSH
./scripts/parse-url-maps.sh "Output/Target 1/url_maps.xml" table
```

## Integration with Other Skills

**epublisher-reverb-test-orchestrator:**
- Orchestrator calls this skill for CSH analysis
- Combines with browser test results
- Generates unified reports

**Standalone Use:**
- No dependencies on other skills
- Fast file-based operation
- Can run independently for CSH validation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| File not found | Check path to url_maps.xml (use quotes for spaces) |
| Empty output `[]` | TopicMap is empty (no CSH configured) - this is normal |
| Permission denied | `chmod +x scripts/parse-url-maps.sh` |

## Known Limitations

1. **Read-Only** - Does not modify url_maps.xml
2. **Validation Only** - Does not test if CSH links work in browser
3. **Reverb 2.0 Only** - Legacy Reverb 1.x not supported

## Version History

**v2.0.0** (2025-11-05)
- Extracted from epublisher-reverb-analyzer as focused CSH skill
- Standalone script with no dependencies
- Simplified scope to CSH analysis only
- Added integration with orchestrator skill

**v1.x** - Previous versions as part of epublisher-reverb-analyzer

## License

ISC License - Part of WebWorks Agent Skills project
