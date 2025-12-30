# AutoMap CLI Reference

Complete reference for WebWorks ePublisher AutoMap command-line interface options and execution patterns.

## Table of Contents

- [Basic Command Pattern](#basic-command-pattern)
- [Command Options](#command-options)
- [Execution Guidelines](#execution-guidelines)
- [Output Monitoring](#output-monitoring)
- [Common Errors](#common-errors)
- [Best Practices](#best-practices)

## Basic Command Pattern

```bash
"[AutoMap-Path]" "[Project-File]" [Options]
```

**Components:**
- `[AutoMap-Path]`: Full path to `WebWorks.Automap.exe` (CLI version)
- `[Project-File]`: Full path to `.wep`, `.wrp`, or `.wxsp` project file
- `[Options]`: Build configuration flags and parameters

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

**`-t, --target "[TargetName]"`**
- **Purpose**: Build specific target only
- **Use When**: Working on single output format
- **Impact**: Faster builds, generates only specified target
- **Example**: `-t "WebWorks Reverb 2.0" project.wep`
- **Note**: Target name must exactly match `TargetName` in project file

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

## Example Commands

### Basic Builds

**Clean build all targets (no deploy):**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n "C:\projects\my-proj\my-proj.wep"
```

**Clean build with deployment:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l "C:\projects\my-proj\my-proj.wep"
```

### Target-Specific Builds

**Build only Reverb target:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n -t "WebWorks Reverb 2.0" "C:\projects\my-proj\my-proj.wep"
```

**Build only PDF target:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n -t "PDF - XSL-FO" "C:\projects\my-proj\my-proj.wep"
```

### Custom Deployment

**Deploy to web server:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l --deployfolder "\\WebServer\wwwroot\docs" "C:\projects\my-proj\my-proj.wep"
```

**Deploy to local test folder:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c --deployfolder "C:\TestOutput" "C:\projects\my-proj\my-proj.wep"
```

## Execution Guidelines

### Path Requirements

1. **Always use absolute paths** for both executable and project files
2. **Quote paths containing spaces** - Most Windows paths have spaces
3. **Use correct path separators**:
   - Windows style: `C:\Path\To\File.wep`
   - Unix style in bash: `/c/Path/To/File.wep` (cygpath conversion)

### Timeout Configuration

Set appropriate timeout based on project size:

| Project Size | Recommended Timeout | Command |
|-------------|---------------------|---------|
| Small (< 50 pages) | 2 minutes | Default |
| Medium (50-200 pages) | 5 minutes | 300000ms |
| Large (200-500 pages) | 10 minutes | 600000ms |
| Very Large (> 500 pages) | 15 minutes | 900000ms |

**Setting timeout in bash:**
```bash
# Use Bash tool with timeout parameter
timeout 600000  # 10 minutes in milliseconds
```

### Output Capture

**Capture both stdout and stderr:**
```bash
"[AutoMap-Path]" "[Project-File]" [Options] 2>&1
```

**Save output to log file:**
```bash
"[AutoMap-Path]" "[Project-File]" [Options] > build.log 2>&1
```

### Exit Code Handling

**Check build status:**
```bash
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "Build succeeded"
else
    echo "Build failed with exit code: $exit_code"
fi
```

**Exit codes:**
- `0` - Success
- Non-zero - Failure (specific codes vary)

## Output Monitoring

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

### 1. Always Clean Build for Production

Use `-c -l` for production releases to ensure:
- No stale cached files
- Fresh transformation of all content
- Clean deployment folder

```bash
"[AutoMap-Path]" -c -l "[Project-File]"
```

### 2. Use -n Flag During Development

Skip deployment during iterative development:
```bash
"[AutoMap-Path]" -c -n "[Project-File]"
```

Check output in `Output/[TargetName]/` folder.

### 3. Build Specific Targets When Testing

Save time by building only the target you're working on:
```bash
"[AutoMap-Path]" -c -n -t "WebWorks Reverb 2.0" "[Project-File]"
```

### 4. Capture Build Logs

Always capture output for troubleshooting:
```bash
"[AutoMap-Path]" "[Project-File]" 2>&1 | tee build.log
```

### 5. Validate Before Building

Check project health before executing build:
```bash
# Check targets exist
./parse-targets.sh project.wep

# Validate source files
./manage-sources.sh --validate project.wep

# Verify AutoMap installation
./detect-installation.sh
```

### 6. Use Wrapper Script for Enhanced Error Handling

The `automap-wrapper.sh` script provides:
- Automatic error detection
- Progress monitoring
- Enhanced error messages
- Build time reporting

```bash
./automap-wrapper.sh -c -l project.wep
```

### 7. Monitor Builds Actively

Don't just execute and walk away:
- Watch for error patterns in real-time
- Note warnings that may affect output
- Verify deployment location on success
- Check exit code before considering build successful

### 8. Document Build Commands

For complex projects, document standard build commands:
```bash
# Production build
"[AutoMap-Path]" -c -l project.wep

# Development build (Reverb only)
"[AutoMap-Path]" -c -n -t "WebWorks Reverb 2.0" project.wep

# PDF only
"[AutoMap-Path]" -c -n -t "PDF - XSL-FO" project.wep
```

## Integration with Scripts

This reference complements the helper scripts:

- **detect-installation.sh** - Finds AutoMap executable path
- **automap-wrapper.sh** - Enhanced CLI wrapper with this reference built-in
- **parse-targets.sh** - Lists valid target names for `-t` parameter

Use this reference when:
- Calling AutoMap directly without wrapper
- Understanding wrapper script behavior
- Debugging build failures
- Optimizing build commands

## Related Documentation

- [installation-detection.md](./installation-detection.md) - Finding AutoMap executable
- [../SKILL.md](../SKILL.md) - Main skill documentation

---

**Version**: 1.1.0
**Last Updated**: 2025-12-29
**Target**: ePublisher 2024.1+ AutoMap CLI (--skip-reports requires 2025.1+)
