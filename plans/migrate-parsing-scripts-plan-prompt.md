# Plan Prompt: Migrate Parsing Scripts to Python

## Objective

Migrate fragile bash parsing scripts to Python for improved robustness, maintainability, and error handling.

## Scripts to Migrate

### High Priority

| Script | Location | Issue |
|--------|----------|-------|
| `parse-targets.sh` | epublisher/scripts/ | XML parsing with grep/awk chains |
| `parse-url-maps.sh` | reverb/scripts/ | XML parsing with grep chains |

### Medium Priority

| Script | Location | Issue |
|--------|----------|-------|
| `generate-report.sh` | reverb/scripts/ | JSON parsing with `tr -d '\n' | grep -oP` |
| `extract-scss-variables.sh` | reverb/scripts/ | Text parsing with grep |

## Requirements

- Maintain same input/output interface (CLI arguments, stdout format)
- Use Python standard library where possible (xml.etree, json, re)
- Include proper error handling with meaningful messages
- Support both Windows and Unix path formats
- No external dependencies unless necessary

## Considerations

- Should scripts output JSON for easier downstream consumption?
- Should there be a shared Python utility module?
- How to handle the Node.js dependency for browser-test.js alongside Python?

## Out of Scope

- `detect-installation.sh` - bash is appropriate for file/registry checks
- `automap-wrapper.sh` - bash is appropriate for CLI orchestration
- `browser-test.js` - requires Node.js for Puppeteer
