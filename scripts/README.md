# Helper Scripts

This directory contains helper scripts for automating WebWorks ePublisher AutoMap operations.

## Scripts

### detect-installation.sh

Detects WebWorks ePublisher AutoMap installation using Windows Registry (preferred method) with filesystem fallback.

**Usage:**
```bash
# Detect latest AutoMap installation
./detect-installation.sh

# Detect specific version
./detect-installation.sh --version 2024.1

# Verbose mode
./detect-installation.sh --verbose
```

**Output:**
```
C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe
```

**Exit Codes:**
- `0` - AutoMap found
- `1` - AutoMap not found
- `2` - Invalid arguments

**Features:**
- Registry-based detection (64-bit and 32-bit)
- Filesystem fallback search
- Version-specific detection
- Latest version auto-detection
- Verbose logging

### automap-wrapper.sh

Wrapper script for AutoMap CLI with automatic detection and enhanced error reporting.

**Usage:**
```bash
# Build all targets with clean
./automap-wrapper.sh -c -l project.wep

# Build specific target
./automap-wrapper.sh -c -l -t "WebWorks Reverb 2.0" project.wep

# Build with custom deployment
./automap-wrapper.sh --deployfolder "C:\Output" project.wep

# Use specific AutoMap version
./automap-wrapper.sh --version 2024.1 -c -l project.wep

# Quiet mode (errors only)
./automap-wrapper.sh --quiet -c -l project.wep
```

**Options:**
- `-c, --clean` - Clean build (remove cached files)
- `-l, --cleandeploy` - Clean deployment location
- `-t, --target TARGET` - Build specific target only
- `--deployfolder PATH` - Override deployment destination
- `--version VERSION` - Use specific AutoMap version
- `--verbose` - Enable verbose output
- `--quiet` - Suppress informational messages

**Exit Codes:**
- `0` - Build succeeded
- `1` - Build failed
- `2` - Invalid arguments
- `3` - AutoMap not found
- `4` - Project file not found

**Features:**
- Automatic AutoMap detection
- Color-coded output (info, success, warning, error)
- Real-time output parsing
- Progress monitoring
- Build duration reporting
- Proper path handling and quoting

## Integration with Claude Code

These scripts are designed to be called from the Claude Code skill (`SKILL.md`) to provide reliable AutoMap detection and execution.

**Example from skill:**
```bash
# Detect AutoMap
AUTOMAP_PATH=$(./scripts/detect-installation.sh)

# Execute build
./scripts/automap-wrapper.sh -c -l "C:\Projects\MyDoc\MyDoc.wep"
```

## Requirements

- Windows operating system (MINGW64/Git Bash/WSL)
- WebWorks ePublisher AutoMap installed
- Bash shell (included with Git for Windows)
- Standard Windows utilities: `reg` command

## Testing

To test the scripts:

```bash
# Test detection
./detect-installation.sh --verbose

# Test wrapper with help
./automap-wrapper.sh --help

# Test with actual project (requires ePublisher installation)
./automap-wrapper.sh -c -l /path/to/project.wep
```

## Troubleshooting

### Script Permission Errors

If you get "Permission denied" errors:
```bash
chmod +x detect-installation.sh automap-wrapper.sh
```

### Registry Access Issues

If registry queries fail:
- Ensure running with standard user permissions
- Check Windows Registry access via `regedit`
- Verify AutoMap is properly installed

### Path Issues

If paths are not resolved correctly:
- Use absolute paths for project files
- Ensure paths are quoted when containing spaces
- Check `cygpath` availability for path conversion

## Development Notes

**Line Endings:** Scripts use LF line endings for compatibility with Git Bash and WSL. Git is configured to handle CRLF conversion automatically.

**Error Handling:** Both scripts use `set -euo pipefail` for strict error handling.

**Logging:** Scripts provide multiple verbosity levels (normal, verbose, quiet) for different use cases.

**Registry Detection:** Primary method uses Windows `reg` command to query registry keys. This is faster and more reliable than filesystem searches.

## Version History

- **1.0.0** (2025-01-27): Initial release with registry-based detection and wrapper functionality
