# 🐛 Fix: Add --skip-reports to automap-wrapper.sh

**Type:** Bug fix
**Scope:** Small - update wrapper script to support documented option

## Problem Statement

The `--skip-reports` option was documented in SKILL.md and cli-reference.md but was not added to `automap-wrapper.sh`. This means:

1. Users following the documentation can't use `--skip-reports` via the wrapper
2. The wrapper rejects the flag as an "Unknown option"
3. Inconsistency between documented features and script capabilities

## Files to Modify

| File | Change |
|------|--------|
| `plugins/webworks-claude-skills/skills/automap/scripts/automap-wrapper.sh` | Add `--skip-reports` support |

## Proposed Solution

### 1. Add Variable (line ~45)

```bash
# Default options
CLEAN_BUILD=false
CLEAN_DEPLOY=false
NO_DEPLOY=false
SKIP_REPORTS=false   # <-- ADD THIS
TARGET=""
```

### 2. Update Usage Text (line ~98)

```bash
OPTIONS:
    -c, --clean            Clean build (remove cached files)
    -n, --nodeploy         Do not copy files to deployment location
    -l, --cleandeploy      Clean deployment location before copying output
    -t, --target TARGET    Build specific target only
    --deployfolder PATH    Override deployment destination
    --skip-reports         Skip report pipelines (2025.1+)   # <-- ADD THIS
    --verbose              Enable verbose output
```

### 3. Update Examples (line ~110)

```bash
EXAMPLES:
    # Build all targets with clean
    $SCRIPT_NAME -c -n project.wep

    # Fast CI build (skip reports)
    $SCRIPT_NAME -c -n --skip-reports project.wep   # <-- ADD THIS
```

### 4. Add Argument Parsing Case (line ~315)

```bash
        --skip-reports)
            SKIP_REPORTS=true
            shift
            ;;
```

### 5. Update build_automap_command Function (line ~200)

```bash
    # Add skip reports flag
    if [ "$SKIP_REPORTS" = true ]; then
        cmd="$cmd --skip-reports"
    fi
```

## Acceptance Criteria

- [ ] `--skip-reports` is accepted by the wrapper script
- [ ] Flag is passed through to AutoMap CLI
- [ ] Usage text documents the option with version note (2025.1+)
- [ ] Example shows recommended CI/CD usage

## References

- PR #17: Original `--skip-reports` documentation
- `plugins/webworks-claude-skills/skills/automap/scripts/automap-wrapper.sh:283-342` - argument parsing
- `plugins/webworks-claude-skills/skills/automap/references/cli-reference.md:67-72` - documented option
