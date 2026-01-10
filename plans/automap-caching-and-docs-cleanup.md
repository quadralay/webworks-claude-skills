# feat: Add caching and improve documentation clarity for automap skill

## Overview

Improve the automap skill by:
1. Adding environment variable caching to prevent repeated installation detection
2. Removing redundant detect-installation.sh from Quick Start workflow
3. Clarifying that documented options are wrapper options (most pass through to CLI)
4. Making clear that Claude should use the wrapper to execute builds (not detect path and call CLI directly)
5. Documenting recommended default options (`-c -n --skip-reports`)

## Problem Statement

**Current issues:**

1. **Redundant detection step in docs**: SKILL.md Quick Start shows calling `detect-installation.sh` separately, but the wrapper already calls it internally

2. **No caching**: Every wrapper invocation runs full registry/filesystem detection (~50ms), wasteful for batch builds:
   ```bash
   # This runs detection 10 times unnecessarily
   for project in *.wep; do
       ./automap-wrapper.sh "$project"
   done
   ```

3. **Unclear option attribution**: The CLI reference doesn't clearly distinguish wrapper-only options from pass-through options

4. **Unclear execution intent**: The skill could be misinterpreted as providing detection so Claude can call the CLI directly, rather than using the wrapper as the execution interface

5. **No recommended defaults**: Common useful options (`-c -n --skip-reports`) are not highlighted as recommended defaults

## Proposed Solution

### 1. Environment Variable Caching

Add `AUTOMAP_PATH` environment variable support to `automap-wrapper.sh`, following the existing pattern from `reverb2/detect-chrome.sh`:

```bash
# In detect_automap_executable() function
detect_automap_executable() {
    # Check for cached/override path first
    if [[ -n "${AUTOMAP_PATH:-}" ]]; then
        # Validate the cached path exists
        local unix_path
        unix_path=$(cygpath "$AUTOMAP_PATH" 2>/dev/null || echo "$AUTOMAP_PATH")

        if [[ -f "$unix_path" ]]; then
            log_verbose "Using AutoMap from AUTOMAP_PATH: $AUTOMAP_PATH"
            echo "$AUTOMAP_PATH"
            return 0
        else
            log_error "AUTOMAP_PATH is set but executable not found: $AUTOMAP_PATH"
            log_error "Unset AUTOMAP_PATH or set it to a valid path"
            return 1
        fi
    fi

    # ... existing detection logic ...
}
```

**Design decisions:**
- **Session-scoped only**: No XDG file cache (keeps it simple)
- **Validation required**: Fail fast if `AUTOMAP_PATH` points to non-existent file
- **No fallback on invalid**: If user sets `AUTOMAP_PATH`, respect their intent - don't silently fall back
- **No `--force-detect` flag**: Users can `unset AUTOMAP_PATH` if needed

### 2. Documentation Updates

#### SKILL.md Quick Start

**Before:**
```markdown
## Quick Start

### Detect Installation

```bash
./scripts/detect-installation.sh
```

Returns the path to AutoMap CLI executable if found.

### Run a Build

```bash
./scripts/automap-wrapper.sh -c -n --skip-reports <project-file> [-t <target-name>]
```
```

**After:**
```markdown
## Quick Start

### Run a Build

```bash
./scripts/automap-wrapper.sh -c -n --skip-reports <project-file> [-t <target-name>]
```

The wrapper automatically detects the AutoMap installation. To cache the path for multiple builds:

```bash
export AUTOMAP_PATH=$(./scripts/detect-installation.sh)
```

### Verify Installation (Optional)

To check if AutoMap is installed, what version, and where:

```bash
./scripts/detect-installation.sh --version
```
```

#### CLI Reference Options Table

**Before:**
```markdown
| Option | Description |
|--------|-------------|
| `-target <name>` | Build specific target |
| `-verbose` | Show all build output (default: minimal) |
```

**After:**
```markdown
### Wrapper Options

| Option | Description |
|--------|-------------|
| `--verbose` | Show all build output (default: minimal) *(wrapper only)* |

### AutoMap CLI Options (Pass-Through)

These options are passed directly to the AutoMap CLI:

| Option | Description |
|--------|-------------|
| `-t <name> [<name2> ...]` | Build only specific targets |
| `-c, --clean` | Clean build from scratch |
| `-n, --nodeploy` | No deploy from Output folder |
| `--skip-reports` | Skip report pipelines *(2025.1+)* |
```

### 3. Clarify Wrapper as Execution Interface

Add to SKILL.md `<objective>` or `<overview>` section:

```markdown
## How to Use This Skill

**Always use the wrapper script to execute builds.** The wrapper:
- Automatically detects the AutoMap installation
- Handles path conversion between Unix and Windows formats
- Provides consistent error handling and exit codes
- Supports environment variable caching for performance

Do NOT use `detect-installation.sh` to find the CLI path and call it directly.
```

### 4. Document Recommended Default Options

Add to SKILL.md and cli-reference.md:

```markdown
## Recommended Options

For most builds, use these options:

```bash
./scripts/automap-wrapper.sh -c -n --skip-reports <project-file>
```

| Option | Why Recommended |
|--------|-----------------|
| `-c` (clean) | Ensures consistent builds by starting fresh |
| `-n` (nodeploy) | Prevents automatic deployment; deploy manually when ready |
| `--skip-reports` | Reduces build time by skipping report pipelines *(2025.1+)* |
```

### 5. Add Environment Variables Section

Add to `references/cli-reference.md`:

```markdown
## Environment Variables

| Variable | Description |
|----------|-------------|
| `AUTOMAP_PATH` | Path to AutoMap CLI executable. If set, skips installation detection. |

### Caching for Batch Builds

For multiple consecutive builds, cache the installation path:

```bash
export AUTOMAP_PATH=$(./scripts/detect-installation.sh)

# All subsequent builds skip detection
./scripts/automap-wrapper.sh project1.wep
./scripts/automap-wrapper.sh project2.wep
./scripts/automap-wrapper.sh project3.wep
```

### Clearing the Cache

```bash
unset AUTOMAP_PATH
```
```

## Files to Modify

| File | Changes |
|------|---------|
| `scripts/automap-wrapper.sh` | Add AUTOMAP_PATH check in `detect_automap_executable()` |
| `SKILL.md` | Update Quick Start with recommended options, add "How to Use" section clarifying wrapper usage, remove standalone detect step |
| `references/cli-reference.md` | Add Environment Variables section, split options into wrapper-only vs pass-through, add Recommended Options section |

## Acceptance Criteria

- [ ] Wrapper uses `AUTOMAP_PATH` if set and file exists
- [ ] Wrapper errors with clear message if `AUTOMAP_PATH` set but file missing
- [ ] Wrapper falls back to detection if `AUTOMAP_PATH` not set
- [ ] SKILL.md Quick Start shows only wrapper command for basic builds
- [ ] SKILL.md documents caching with `export AUTOMAP_PATH=...` pattern
- [ ] cli-reference.md has Environment Variables section
- [ ] Options tables distinguish wrapper-only vs pass-through options
- [ ] SKILL.md clearly states to use wrapper for builds (not detect + call CLI directly)
- [ ] SKILL.md documents recommended default options (`-c -n --skip-reports`)
- [ ] Quick Start example uses recommended options

## Out of Scope

- XDG file-based persistent cache (adds complexity without clear benefit)
- Cache TTL/expiration (validation on use is simpler)
- `--force-detect` flag (users can `unset AUTOMAP_PATH`)
- Version-keyed caching (single path is sufficient for most users)
- Automatic `export` by wrapper (let users control their environment)

## Implementation Notes

**Pattern reference:** `plugins/webworks-claude-skills/skills/reverb2/scripts/detect-chrome.sh:51-61`

```bash
# Check for manual override first
if [[ -n "${CHROME_PATH:-}" ]]; then
    debug_log "Found CHROME_PATH environment variable: $CHROME_PATH"
    if [[ -f "$CHROME_PATH" ]]; then
        success_log "Using Chrome from CHROME_PATH: $CHROME_PATH"
        echo "$CHROME_PATH"
        return 0
    else
        error_log "CHROME_PATH is set but file does not exist: $CHROME_PATH"
        return 1
    fi
fi
```

Follow this exact pattern for consistency across skills.

## References

- `plugins/webworks-claude-skills/skills/automap/scripts/automap-wrapper.sh:148-169` - Current detect function
- `plugins/webworks-claude-skills/skills/reverb2/scripts/detect-chrome.sh:51-61` - CHROME_PATH pattern
- `plugins/webworks-claude-skills/skills/automap/references/installation-detection.md:60-64` - Existing caching recommendation
