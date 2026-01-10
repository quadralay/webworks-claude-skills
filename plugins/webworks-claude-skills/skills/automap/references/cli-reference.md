# AutoMap CLI Reference

Complete reference for WebWorks ePublisher AutoMap command-line interface options and execution patterns.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Recommended Options](#recommended-options)
- [Basic Command Pattern](#basic-command-pattern)
- [Command Options](#command-options)
- [Execution Guidelines](#execution-guidelines)
- [Output Monitoring](#output-monitoring)
- [Common Errors](#common-errors)
- [Best Practices](#best-practices)

## Environment Variables

| Variable | Description |
|----------|-------------|
| `AUTOMAP_PATH` | Path to AutoMap CLI executable. If set, skips installation detection. |

### Caching for Batch Builds

For multiple consecutive builds, cache the installation path to avoid repeated detection:

```bash
export AUTOMAP_PATH=$(./scripts/detect-installation.sh)

# All subsequent builds skip detection
./scripts/automap-wrapper.sh -c -n --skip-reports project1.wep
./scripts/automap-wrapper.sh -c -n --skip-reports project2.wep
./scripts/automap-wrapper.sh -c -n --skip-reports project3.wep
```

### Clearing the Cache

```bash
unset AUTOMAP_PATH
```

## Recommended Options

For most builds, use these options by default:

```bash
./scripts/automap-wrapper.sh -c -n --skip-reports <project-file>
```

| Option | Why Recommended |
|--------|-----------------|
| `-c` (clean) | Ensures consistent builds by starting fresh |
| `-n` (nodeploy) | Prevents automatic deployment; deploy manually when ready |
| `--skip-reports` | Reduces build time by skipping report pipelines *(2025.1+)* |

These options provide predictable, fast builds suitable for iterative development and AI-assisted workflows.

## Basic Command Pattern

Always use the wrapper script to execute builds:

```bash
./scripts/automap-wrapper.sh [options] <project-file> [-t <target-name>]
```

**Components:**
- `<project-file>`: Path to `.wep`, `.wrp`, or `.waj` project/job file
- `[options]`: Build configuration flags (see below)
- `[-t <target-name>]`: Optional single target (use `--target="Name1", "Name2"` for multiple)

## Command Options

### Core Build Options

**`-c, --clean`**
- **Purpose**: Clean build (remove cached files before generation)
- **Use When**: Ensuring fresh build after major changes
- **Impact**: Longer build time but guaranteed clean state
- **Example**: `-c -n project.wep`

**`-n, --nodeploy`**
- **Purpose**: Do not copy output to deployment location
- **Use When**: Testing builds or using custom deployment
- **Impact**: Output remains in project's Output folder only
- **Example**: `-c -n project.wep`

**`-l, --cleandeploy`**
- **Purpose**: Clean deployment location before copying output
- **Use When**: Ensuring deployment folder has only latest files
- **Impact**: Removes old files from previous builds
- **Example**: `-c -l project.wep`

### Target Selection

**`-t <TargetName>`** or **`--target=<TargetName1>, <TargetName2>`**
- **Purpose**: Build specific target(s) only
- **Use When**: Working on specific output format(s) rather than all targets
- **Impact**: Faster builds, generates only specified target(s)
- **Syntax**:
  - Single target: `-t "WebWorks Reverb 2.0"`
  - Multiple targets: `--target="WebWorks Reverb 2.0", "PDF - XSL-FO"`
  - All targets: omit `-t` or `--target=` entirely
- **Examples**:
  - Single target: `./scripts/automap-wrapper.sh -c -n -t "WebWorks Reverb 2.0" project.wep`
  - Multiple targets: `./scripts/automap-wrapper.sh -c -n --target="WebWorks Reverb 2.0", "PDF - XSL-FO" project.wep`
- **Note**: Target names must exactly match `TargetName` in project file (case-sensitive)

### Deployment Control

**`--deployfolder "[Path]"`**
- **Purpose**: Override default deployment destination
- **Use When**: Deploying to custom location (web server, network share)
- **Impact**: Output copied to specified path instead of project default
- **Example**: `--deployfolder "C:\Output" project.wep`
- **Note**: Must have write permissions to deployment path

### Performance Options

**`--skip-reports`** *(2025.1+)*
- **Purpose**: Skip report generation pipelines during build
- **Use When**: CI/CD builds, agentic workflows, or iterative development where reports not needed
- **Impact**: Faster builds, reduced file system output
- **Trade-off**: No build reports generated (errors and warnings still shown in console)
- **Example**: `-c -n --skip-reports project.wep`

### Output Control

**Default behavior:** The wrapper runs in minimal output mode, showing only errors and final build status. This is optimized for AI-assisted workflows where verbose output increases token costs.

**`--verbose`** *(wrapper script only)*
- **Purpose**: Show all build output including progress messages
- **Use When**: Debugging build issues or monitoring progress manually
- **Impact**: Full output with progress indicators and informational messages
- **Example**: `./automap-wrapper.sh --verbose -c -n project.wep`

**Default output:**
```
[SUCCESS] Build completed in 45s
```

**Verbose output:**
```
[INFO] Executing AutoMap...
[INFO] Processing chapter1.md...
[INFO] Generating WebWorks Reverb 2.0...
[SUCCESS] Build completed in 45s
```

## Example Commands

### Basic Builds

**Clean build all targets (no deploy, skip reports):**
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports project.wep
```

**Clean build with deployment:**
```bash
./scripts/automap-wrapper.sh -c -l --skip-reports project.wep
```

### Target-Specific Builds

**Build single target:**
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports -t "WebWorks Reverb 2.0" project.wep
```

**Build multiple targets:**
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports --target="WebWorks Reverb 2.0", "PDF - XSL-FO" project.wep
```

### Custom Deployment

**Deploy to network share:**
```bash
./scripts/automap-wrapper.sh -c -l --skip-reports --deployfolder "\\\\WebServer\\wwwroot\\docs" project.wep
```

**Deploy to local test folder:**
```bash
./scripts/automap-wrapper.sh -c --skip-reports --deployfolder "C:\\TestOutput" project.wep
```

## Execution Guidelines

### Path Requirements

1. **Use absolute or relative paths** for project files
2. **Quote paths containing spaces** - Most Windows paths have spaces
3. **The wrapper handles path conversion** between Unix and Windows formats automatically

### Timeout Configuration

Set appropriate timeout based on project size when using the Bash tool:

| Project Size | Recommended Timeout |
|-------------|---------------------|
| Small (< 50 pages) | 2 minutes (default) |
| Medium (50-200 pages) | 5 minutes (300000ms) |
| Large (200-500 pages) | 10 minutes (600000ms) |
| Very Large (> 500 pages) | 15 minutes (900000ms) |

### Output Capture

**Save output to log file:**
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports project.wep > build.log 2>&1
```

**Verbose mode for debugging:**
```bash
./scripts/automap-wrapper.sh --verbose -c -n project.wep
```

### Exit Code Handling

The wrapper provides consistent exit codes:

| Exit Code | Meaning |
|-----------|---------|
| 0 | Build succeeded |
| 1 | Build failed |
| 2 | Project file not found |
| 3 | AutoMap not installed |
| 4 | Invalid target name |

**Check build status:**
```bash
if ./scripts/automap-wrapper.sh -c -n --skip-reports project.wep; then
    echo "Build succeeded"
else
    echo "Build failed with exit code: $?"
fi
```

## Output Monitoring (non-errors require verbose mode)

### Success Indicators

Monitor console output for these success patterns:
- `"Generation completed successfully"`
- `"Output deployed to [path]"`
- `"Build finished"`
- `"All targets generated successfully"`

### Error Patterns

Watch for error indicators:
- `"Error:"` - Critical errors
- `"Failed to"` - Operation failures
- `"Unable to"` - Capability errors
- `"Exception"` - Runtime exceptions
- `"Could not"` - Resource access errors

### Warning Patterns

Note warnings that may affect output:
- `"Warning:"` - Non-critical issues
- `"Could not find"` - Missing optional resources
- `"Deprecated"` - Outdated configurations
- `"Skipping"` - Excluded content

### Progress Indicators

Track build progress:
- `"Processing [file]"` - Current file being processed
- `"Generating [target]"` - Current target being built
- `"Transforming"` - Content transformation phase
- `"Deploying to [path]"` - Deployment phase

## Common Errors

### Error 1: Project File Not Found

**Symptom:**
```
Error: Could not load project file 'C:\projects\my-proj\my-proj.wep'
```

**Causes:**
- Incorrect project file path
- File moved or deleted
- Permission denied

**Solutions:**
1. Verify file exists: `test -f "C:\projects\my-proj\my-proj.wep"`
2. Check file permissions
3. Use absolute path
4. Check for typos in filename

### Error 2: Source Documents Missing

**Symptom:**
```
Error: Source document not found: 'Source\getting-started.md'
```

**Causes:**
- Source file moved or deleted
- Incorrect relative path in project file
- File referenced but not committed to repository

**Solutions:**
1. Verify source file exists
2. Check path in project file `<Document Path="..."/>`
3. Update project file if source moved
4. Use `manage-sources.sh --validate` to check all sources

### Error 3: Invalid Target Configuration

**Symptom:**
```
Error: Invalid target configuration for 'WebWorks Reverb 2.0'
```

**Causes:**
- Corrupted target configuration in project file
- Missing required FormatSettings
- Incompatible format version

**Solutions:**
1. Review target XML structure in project file
2. Validate against known working project
3. Re-create target configuration if corrupted
4. Check FormatSettings completeness

### Error 4: Insufficient Disk Space

**Symptom:**
```
Error: Unable to write output - disk full
Error: Out of disk space
```

**Causes:**
- Output directory drive full
- Deployment folder drive full
- Temp directory full

**Solutions:**
1. Check available disk space: `df -h`
2. Clean output directories
3. Use different deployment folder with more space
4. Clear temp files

### Error 5: Permission Denied

**Symptom:**
```
Error: Access denied writing to 'C:\Output'
Error: Permission denied
```

**Causes:**
- Insufficient write permissions on output folder
- Deployment folder restricted
- File in use by another process

**Solutions:**
1. Check folder permissions
2. Run as administrator if needed
3. Close files in output folder
4. Choose different deployment location

### Error 6: Target Not Found

**Symptom:**
```
Error: Target 'Invalid Target Name' not found in project
```

**Causes:**
- Typo in `-t` parameter
- Target name doesn't match project configuration
- Case sensitivity mismatch

**Solutions:**
1. List available targets: `parse-targets.sh project.wep`
2. Use exact target name from project file
3. Check for extra spaces or special characters
4. Ensure case matches exactly

## Best Practices

### 1. Use Recommended Options by Default

Start with the recommended options for most builds:
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports project.wep
```

### 2. Clean Build for Production

Use `-c -l` for production releases to ensure:
- No stale cached files
- Fresh transformation of all content
- Clean deployment folder

```bash
./scripts/automap-wrapper.sh -c -l --skip-reports project.wep
```

### 3. Use -n Flag During Development

Skip deployment during iterative development:
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports project.wep
```

Check output in `Output/[TargetName]/` folder.

### 4. Build Specific Targets When Testing

Save time by building only the target(s) you're working on:
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports -t "WebWorks Reverb 2.0" project.wep
```

### 5. Cache Installation Path for Batch Builds

When building multiple projects, cache the installation path:
```bash
export AUTOMAP_PATH=$(./scripts/detect-installation.sh)

./scripts/automap-wrapper.sh -c -n --skip-reports project1.wep
./scripts/automap-wrapper.sh -c -n --skip-reports project2.wep
./scripts/automap-wrapper.sh -c -n --skip-reports project3.wep
```

### 6. Use Verbose Mode for Debugging

When troubleshooting build issues:
```bash
./scripts/automap-wrapper.sh --verbose -c -n project.wep
```

### 7. Capture Build Logs

Save output for troubleshooting:
```bash
./scripts/automap-wrapper.sh -c -n --skip-reports project.wep 2>&1 | tee build.log
```

### 8. Document Standard Build Commands

For complex projects, document your standard build commands:
```bash
# Production build (clean + deploy)
./scripts/automap-wrapper.sh -c -l --skip-reports project.wep

# Development build (Reverb only)
./scripts/automap-wrapper.sh -c -n --skip-reports -t "WebWorks Reverb 2.0" project.wep

# Multiple targets
./scripts/automap-wrapper.sh -c -n --skip-reports --target="WebWorks Reverb 2.0", "PDF - XSL-FO" project.wep
```

## Script Reference

The wrapper is the primary execution interface:

| Script | Purpose |
|--------|---------|
| **automap-wrapper.sh** | Execute builds (primary interface) |
| **detect-installation.sh** | Verify installation, cache path |
| **parse-targets.sh** | List valid target names for `-t` parameter |

Use `detect-installation.sh` only for:
- Verifying AutoMap is installed
- Caching the path via `AUTOMAP_PATH` for batch builds
- Debugging installation detection issues

## Related Documentation

- [installation-detection.md](./installation-detection.md) - Finding AutoMap executable
- [../SKILL.md](../SKILL.md) - Main skill documentation

## Adding New CLI Options

When adding a new AutoMap CLI option to this skill, update these locations:

1. **SKILL.md** - Add to Wrapper Options or Pass-Through Options table
2. **cli-reference.md** - Add detailed documentation with examples using wrapper
3. **automap-wrapper.sh** - Add script support (variable, usage, parsing, command building)

---

**Version**: 2.0.0
**Last Updated**: 2026-01-09
**Target**: ePublisher 2024.1+ AutoMap CLI (--skip-reports requires 2025.1+)
