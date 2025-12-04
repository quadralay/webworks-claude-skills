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
</overview>

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

### detect-installation.sh

Locate ePublisher and AutoMap installation:

```bash
./detect-installation.sh
```

Output (JSON):
```json
{
  "installed": true,
  "version": "2024.1",
  "automap_path": "C:/Program Files/WebWorks/ePublisher/2024.1/AutoMap.exe",
  "formats_path": "C:/Program Files/WebWorks/ePublisher/2024.1/Formats"
}
```

### automap-wrapper.sh

Wrapper script with error handling and logging:

```bash
./automap-wrapper.sh <project-file> [target-name] [options]
```

Features:
- Validates project file exists
- Detects AutoMap installation
- Captures build output
- Returns structured exit codes
</scripts>

<references>

## Reference Files

- `cli-reference.md` - Complete CLI options and syntax
- `cli-vs-administrator.md` - When to use CLI vs GUI
- `installation-detection.md` - Installation paths and detection logic
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

<success_criteria>

## Success Criteria

- AutoMap installation detected
- Build executed without errors
- Output generated at expected location
- Exit code indicates success (0)
</success_criteria>
