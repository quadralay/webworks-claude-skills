---
name: epublisher-reverb-test-orchestrator
description: Orchestrates comprehensive Reverb 2.0 testing by coordinating browser-test and CSH analyzer skills. Detects entry points from project files, runs both test suites, aggregates results, and generates unified reports. Use this as the main entry point for complete Reverb output validation.
allowed-tools: Bash, Read
metadata:
  version: "2.0.0"
  category: "orchestration"
  status: "production"
  related-skills:
    - epublisher-reverb-browser-test
    - epublisher-reverb-csh-analyzer
    - epublisher-core
---

# Reverb Test Orchestrator

Coordinates comprehensive Reverb 2.0 testing by running browser tests and CSH analysis, then generating unified reports.

## Purpose

**Core Capabilities:**
- Detect Reverb output entry points from project files
- Coordinate epublisher-reverb-browser-test skill
- Coordinate epublisher-reverb-csh-analyzer skill
- Aggregate results from both test suites
- Generate unified analysis reports
- Provide "run all tests" workflow

**Format Support:** WebWorks Reverb 2.0 only

## Quick Start

### Usage

```bash
cd plugins/epublisher-automation/skills/epublisher-reverb-test-orchestrator

# Run all tests for project
./scripts/orchestrate-tests.sh /path/to/project.wep

# Specific target
./scripts/orchestrate-tests.sh project.wep --target "Target 2"

# Verbose output
./scripts/orchestrate-tests.sh project.wep --verbose
```

## What Gets Orchestrated

### 1. Entry Point Detection

- Parses project file to find Reverb 2.0 targets
- Extracts output directory paths
- Locates url_maps.xml for CSH analysis
- Builds entry URLs for browser testing
- Extracts FormatSettings for validation

### 2. Browser Testing

Delegates to `epublisher-reverb-browser-test`:
- JavaScript runtime verification
- Console error monitoring
- DOM component inspection
- FormatSettings validation

### 3. CSH Analysis

Delegates to `epublisher-reverb-csh-analyzer`:
- Parse url_maps.xml
- Extract CSH topic mappings
- Validate structure

### 4. Report Generation

- Aggregates results from both skills
- Generates unified formatted report
- Includes summary statistics
- Shows pass/fail status

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `orchestrate-tests.sh` | Main orchestration script - coordinates all testing |
| `detect-entry-point.sh` | Parse project files to find Reverb output and settings |
| `generate-report.sh` | Generate unified reports from test results |

## Common Workflows

### Complete Project Testing

```bash
# Build then test
./scripts/automap-wrapper.sh -c -n project.wep
./scripts/orchestrate-tests.sh project.wep
```

### CI/CD Integration

```yaml
- name: Test Reverb Output
  run: |
    cd plugins/epublisher-automation/skills/epublisher-reverb-test-orchestrator
    ./scripts/orchestrate-tests.sh ${{ github.workspace }}/project.wep
```

### Multi-Target Testing

```bash
# Test each target separately
for target in "Target 1" "Target 2"; do
  ./scripts/orchestrate-tests.sh project.wep --target "$target"
done
```

## Integration with Other Skills

**Coordinates:**
- `epublisher-reverb-browser-test` - Browser automation and DOM inspection
- `epublisher-reverb-csh-analyzer` - CSH link validation

**Works with:**
- `epublisher-core` - Build Reverb output before testing

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CHROME_PATH` | Auto-detected | Chrome executable path (for browser-test) |
| `TIMEOUT` | 30000 | Browser test timeout in milliseconds |
| `DEBUG` | 0 | Enable verbose logging |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No Reverb target found | Ensure project has Reverb 2.0 target configured |
| Browser test fails | Check CHROME_PATH and increase TIMEOUT if needed |
| Output directory not found | Run AutoMap build before testing |

## Known Limitations

1. **Sequential Execution** - Runs tests in sequence (not parallel)
2. **Single Target** - Tests one target at a time
3. **Requires Both Skills** - Needs browser-test and csh-analyzer skills available

## Version History

**v2.0.0** (2025-11-05)
- Created as orchestration skill for split architecture
- Coordinates browser-test and csh-analyzer skills
- Maintains unified testing workflow
- Simplified from monolithic analyzer

## License

ISC License - Part of WebWorks Agent Skills project
