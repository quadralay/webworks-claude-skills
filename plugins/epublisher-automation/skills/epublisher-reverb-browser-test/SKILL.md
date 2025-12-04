---
name: epublisher-reverb-browser-test
description: Browser-based testing for WebWorks Reverb 2.0 output. Loads Reverb in headless Chrome to verify JavaScript runtime, monitor console errors, inspect DOM components (toolbar, header, footer, TOC, content), validate FormatSettings, and detect resource loading failures. Use after building Reverb to validate output quality.
allowed-tools: Bash, Read, Write, Edit
metadata:
  version: "2.0.0"
  category: "testing"
  status: "production"
  related-skills:
    - epublisher-core
    - epublisher-reverb-csh-analyzer
    - epublisher-reverb-test-orchestrator
---

# Reverb Browser Test

Browser-based testing for WebWorks Reverb 2.0 output using headless Chrome automation.

## Purpose

**Core Capabilities:**
- Load Reverb in headless Chrome and verify JavaScript runtime initialization
- Monitor console errors and warnings during page load
- Inspect DOM components: toolbar (#toolbar_div), header, footer (#footer_div), TOC (#toc), content
- Validate FormatSettings against actual DOM structure
- Detect resource loading failures (404s, network errors)
- Capture screenshots for visual verification
- Return structured JSON test results

**Format Support:** WebWorks Reverb 2.0 only (legacy Reverb 1.x not supported)

## Quick Start

### Prerequisites

- Node.js 14+ with npm
- Chrome browser (standard installation)
- Generated Reverb 2.0 output

### Installation

```bash
cd plugins/epublisher-automation/skills/epublisher-reverb-browser-test
./scripts/setup-dependencies.sh  # Installs puppeteer-core
./scripts/detect-chrome.sh       # Verify Chrome found
```

### Basic Usage

```bash
# Test Reverb output
node ./scripts/browser-test.js \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "file:///C:/wwepub/project/Output/Target%201/index.html"
```

## What Gets Tested

### 1. JavaScript Runtime

- Waits for `Parcels.loaded_all === true` (default 30s timeout)
- Measures page load time
- Reports initialization failures

**Success:** Reverb loads within timeout, no errors

### 2. Console Monitoring

- Captures JavaScript errors with full messages and timestamps
- Captures console warnings separately
- Detects failed resource loads (404s, network errors)

**Success:** Zero console errors, no failed resources

### 3. DOM Component Inspection

Inspects and validates:
- **Toolbar** (#toolbar_div): Presence, logo, search functionality
- **Header**: Presence, logo, position
- **Footer** (#footer_div): Presence, logo
- **TOC** (#toc): Presence, initial state, item count
- **Content**: Presence

**Success:** All components match FormatSettings configuration

### 4. FormatSettings Validation

Compares FormatSettings from project file to actual DOM:
- ShowToolbar="true" → #toolbar_div must exist
- ShowHeader="true" → header must exist
- ShowFooter="true" → #footer_div must exist
- Logo file paths → images must load

**Success:** No mismatches between settings and DOM

## Output Format

JSON structure:

```json
{
  "success": true,
  "reverbLoaded": true,
  "loadTime": 1234,
  "errors": [],
  "warnings": [],
  "components": {
    "toolbar": {"present": true, "logo": "none", "search": "enabled"},
    "header": {"present": false},
    "footer": {"present": true, "logo": "none"},
    "toc": {"present": true, "state": "expanded", "items": 15},
    "content": {"present": true}
  },
  "formatSettingsMismatches": []
}
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TIMEOUT` | 30000 (30s) | Page load timeout in milliseconds |
| `DEBUG` | 0 | Enable verbose logging (1=on, 0=off) |
| `SCREENSHOT_PATH` | None | Path to save screenshot |

**Example:**
```bash
export TIMEOUT=60000
export SCREENSHOT_PATH="reverb-output.png"
node ./scripts/browser-test.js "$CHROME_PATH" "$ENTRY_URL"
```

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `browser-test.js` | Main Puppeteer script for testing Reverb |
| `detect-chrome.sh` | Detects Chrome/Chromium installation |
| `setup-dependencies.sh` | Installs puppeteer-core dependency |

## Common Workflows

### Standalone Testing

```bash
# 1. Detect Chrome
CHROME_PATH=$(./scripts/detect-chrome.sh)

# 2. Run browser test
node ./scripts/browser-test.js "$CHROME_PATH" "file:///path/to/index.html"
```

### With FormatSettings Validation

```bash
# Pass FormatSettings JSON for validation
node ./scripts/browser-test.js "$CHROME_PATH" "$ENTRY_URL" \
  '{"ShowToolbar":"true","ShowFooter":"false"}'
```

### With Screenshot Capture

```bash
export SCREENSHOT_PATH="test-output.png"
node ./scripts/browser-test.js "$CHROME_PATH" "$ENTRY_URL"
```

## Integration with Other Skills

**epublisher-reverb-test-orchestrator:**
- Orchestrator calls this skill for browser testing
- Combines results with CSH analysis
- Generates unified reports

**epublisher-core:**
- Use automap-wrapper.sh to build Reverb before testing
- Coordinate build → test workflows

## Troubleshooting

| Issue | Quick Fix |
|-------|-----------|
| Chrome not found | `export CHROME_PATH="/path/to/chrome.exe"` |
| Timeout waiting for Reverb | `export TIMEOUT=60000` |
| npm install failed | `npm cache clean --force && rm -rf node_modules` |
| Permission denied | `chmod +x scripts/*.sh` |

**See Also:** [`INSTALLATION.md`](./INSTALLATION.md) for complete setup and troubleshooting.

## Known Limitations

1. **Chrome Only** - Requires Chrome/Edge (no Firefox/Safari)
2. **File Protocol** - Uses `file://` URLs (best with Chrome)
3. **Windows Focused** - Primarily tested on Windows with Git Bash
4. **Single Session** - Tests one Reverb output at a time

## Version History

**v2.0.0** (2025-11-05)
- Extracted from epublisher-reverb-analyzer as focused browser-test skill
- Maintains all browser automation capabilities
- Reduced scope to browser-only operations
- Added integration with orchestrator skill

**v1.x** - Previous versions as part of epublisher-reverb-analyzer

## License

ISC License - Part of WebWorks Agent Skills project
