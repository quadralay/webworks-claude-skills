---
name: automap
description: Build automation for WebWorks ePublisher using AutoMap command-line interface. Use when executing builds, detecting installations, or automating publishing workflows.
---

<objective>

# automap

Build automation for WebWorks ePublisher using AutoMap command-line interface. Execute builds, detect installations, and automate publishing workflows.
</objective>

<overview>

## Overview

AutoMap is the command-line build tool for ePublisher. It processes source documents and generates output without requiring the GUI application.

### Supported File Types

- **Project files (.wep, .wrp)**: Complete self-contained projects
- **Job files (.waj)**: Lean automation files that reference Stationery

### Job Files and Stationery

Job files inherit format configuration from Stationery projects (.wxsp), enabling:
- Separation of format design from build automation
- Lean, portable job definitions
- Pre/post build script execution (hook-like capability)

**For job file details, see:** references/job-file-guide.md
</overview>

<related_skills>

## Related Skills

| Skill | Relationship |
|-------|--------------|
| **epublisher** | Use first to understand project structure and target names |
| **reverb** | Use after building Reverb output to test and customize |

</related_skills>

<quick_start>

## Quick Start

### Detect Installation

```bash
./scripts/detect-installation.sh
```

Returns the path to AutoMap CLI executable if found.

### Run a Build

```bash
./scripts/automap-wrapper.sh <project-file> [target-name]
```

Builds the specified target (or all targets if none specified).
</quick_start>

<job_files>

## Job Files

Job files (.waj) are lean automation files that reference a Stationery project for format configuration.

### Creating Job Files

To create a job file from scratch:

1. Identify your Stationery file (.wxsp)
2. Gather your source documents
3. Decide which formats to build

The skill will guide you through:
- Parsing Stationery to show available formats
- Organizing documents into groups
- Configuring targets with overrides
- Generating valid XML

### Job File Scripts

```bash
# Parse Stationery to see available formats and settings
python scripts/parse-stationery.py stationery.wxsp

# Create job file interactively
python scripts/create-job.py --stationery stationery.wxsp

# Create job from config file
python scripts/create-job.py --config config.json --output job.waj

# Generate a config template from Stationery
python scripts/create-job.py --template --stationery stationery.wxsp > template.json
```

### Working with Existing Job Files

```bash
# Parse job file to view configuration
python scripts/parse-job.py job.waj

# Export to editable config format
python scripts/parse-job.py --config job.waj > job-config.json

# Validate job file before building
python scripts/validate-job.py job.waj

# Validate with full checks
python scripts/validate-job.py --check-documents --check-stationery job.waj

# List targets with build status
python scripts/list-job-targets.py job.waj

# Show only enabled targets
python scripts/list-job-targets.py --enabled job.waj
```

### Stationery Relationship

Job files reference Stationery via `<Project path="..."/>`:
- Paths are relative to job file location
- All format settings inherited from Stationery
- Targets can override conditions, variables, settings
</job_files>

<cli_reference>

## AutoMap CLI

### Basic Syntax

```
AutoMap.exe [options] <project-file>
```

### Common Options

| Option | Description |
|--------|-------------|
| `-target <name>` | Build specific target |
| `-group <name>` | Build specific group |
| `-log <path>` | Write log to file |
| `-verbose` | Enable verbose output |
| `-clean` | Clean before build |

**For complete CLI reference with examples, see:** references/cli-reference.md
</cli_reference>

<scripts>

## Scripts

| Script | Purpose |
|--------|---------|
| `detect-installation.sh` | Find AutoMap installation |
| `automap-wrapper.sh` | Execute builds with error handling |
| `parse-stationery.py` | Extract formats/settings from Stationery |
| `create-job.py` | Create job files interactively or from config |
| `parse-job.py` | Parse existing job files |
| `validate-job.py` | Validate job files before building |
| `list-job-targets.py` | List targets with build status |

### Installation Detection

```bash
./detect-installation.sh
```

### Build Wrapper

```bash
./automap-wrapper.sh <project-or-job-file> [target-name] [options]
```

Supports both project files (.wep) and job files (.waj).
</scripts>

<references>

## Reference Files

- `cli-reference.md` - Complete CLI options and syntax
- `cli-vs-administrator.md` - When to use CLI vs GUI
- `installation-detection.md` - Installation paths and detection logic
- `job-file-guide.md` - Job file structure and Stationery inheritance
</references>

<requirements>

## Requirements

- WebWorks ePublisher 2024.1+ with AutoMap component
- Windows operating system
- Git Bash or similar Unix-like shell
</requirements>

<exit_codes>

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Build successful |
| 1 | Build failed |
| 2 | Project file not found |
| 3 | AutoMap not installed |
| 4 | Invalid target name |
</exit_codes>

<common_workflows>

## Common Workflows

### CI/CD Integration

```bash
#!/bin/bash
# Build and check result
if ./automap-wrapper.sh project.wep "Production"; then
    echo "Build successful"
    # Deploy output...
else
    echo "Build failed"
    exit 1
fi
```

### Batch Building Multiple Projects

```bash
for project in projects/*.wep; do
    ./automap-wrapper.sh "$project" || echo "Failed: $project"
done
```
</common_workflows>

<troubleshooting>

## Troubleshooting

### "AutoMap installation not found"

**Cause:** AutoMap not installed or not in expected location.

**Solutions:**
1. Verify ePublisher AutoMap is installed
2. Check registry: `HKLM\SOFTWARE\WebWorks\ePublisher AutoMap`
3. Check filesystem: `C:\Program Files\WebWorks\ePublisher\[version]\`
4. Use `--verbose` flag for detailed detection output

### "Build failed with exit code 1"

**Cause:** ePublisher build encountered errors.

**Solutions:**
1. Check AutoMap output for specific error messages
2. Verify source documents exist and are accessible
3. Open project in ePublisher Administrator to check for issues
4. Try building with `-c` (clean) flag

### "Target not found"

**Cause:** Specified target name doesn't exist in project.

**Solutions:**
1. Use `parse-targets.sh` to list available targets
2. Verify target name spelling (case-sensitive)
3. Check project file for available `<Format>` elements

### Job File Errors

**Stationery not found**
```
Error: Stationery file not found: ..\stationery\main.wxsp
```
- Check `<Project path="..."/>` in job file
- Verify path is relative to job file location
- Run: `python validate-job.py job.waj`

**Invalid target format**
```
Error: Format "Unknown Format" not found in Stationery
```
- Target `format` attribute must match format name in Stationery
- Format names are case-sensitive
- Run: `python parse-stationery.py stationery.wxsp` to list available formats

**Document path errors**
```
Warning: Document not found: Source\missing.md
```
- Document paths are relative to job file location
- Check for typos in path
- Run: `python validate-job.py --check-documents job.waj`

</troubleshooting>

<success_criteria>

## Success Criteria

- AutoMap installation detected
- Build executed without errors
- Output generated at expected location
- Exit code indicates success (0)
</success_criteria>
