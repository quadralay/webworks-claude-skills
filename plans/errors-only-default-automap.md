# refactor: Make errors-only the default for automap-wrapper

## Overview

Change `automap-wrapper.sh` to run in errors-only mode by default, since the primary consumers are Claude and AI agents. Users who want verbose output can use `--verbose`.

## Rationale

- The automap skill is designed for AI-assisted workflows
- Users don't execute the CLI directly - Claude does
- Token efficiency should be the default, not opt-in
- Simpler mental model: quiet by default, verbose when debugging

## Implementation

### Changes to automap-wrapper.sh

**1. Change default value (line 48):**
```bash
# Before
ERRORS_ONLY=false

# After
ERRORS_ONLY=true
```

**2. Update --verbose to disable errors-only (modify existing parsing):**
```bash
--verbose)
    VERBOSE=true
    ERRORS_ONLY=false  # Add this line
    shift
    ;;
```

**3. Remove redundant --errors-only flag parsing (lines 349-352):**
Delete this block since it's now the default.

**4. Update usage help:**
```bash
# Remove --errors-only from OPTIONS
# Update --verbose description:
    --verbose              Enable verbose output (shows all build messages)
```

**5. Remove example for --errors-only from help (line 130-131):**
No longer needed since it's the default.

**6. Simplify main execution section:**
Remove the `QUIET=true` implication since errors-only is now default.

### Changes to documentation

**SKILL.md:** Remove `--errors-only` from Common Options table (it's now default behavior)

**cli-reference.md:**
- Remove the `--errors-only` section
- Update to note that minimal output is the default
- Document that `--verbose` enables full output

## Acceptance Criteria

- [ ] Default execution produces minimal output (errors + final status only)
- [ ] `--verbose` flag produces full output with progress messages
- [ ] Exit codes preserved correctly in both modes
- [ ] Documentation updated to reflect new defaults

## Files to Modify

| File | Changes |
|------|---------|
| `automap-wrapper.sh` | Change default, simplify flag handling |
| `SKILL.md` | Remove --errors-only from table |
| `cli-reference.md` | Update default behavior docs |
