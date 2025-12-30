# Add --skip-reports CLI Option to AutoMap Skill

**Type:** Enhancement
**Scope:** Minimal - documentation update only

## Overview

Add documentation for the new `--skip-reports` CLI option available in ePublisher 2025.1+. This option skips report generation pipelines, reducing build time and file system noise during agentic/automated conversions.

## Problem Statement

When running AutoMap builds in CI/CD or agentic workflows:
- Report generation consumes CPU cycles unnecessarily
- Report files create noise in version control history
- Build times are longer than necessary for automated workflows

The `--skip-reports` option (2025.1+) addresses these issues but is not yet documented in the skill.

## Proposed Solution

Update two files to document the new option:

### 1. SKILL.md - Common Options Table

**File:** `plugins/webworks-claude-skills/skills/automap/SKILL.md`
**Location:** Line 144-151 (Common Options table)

Add new row to the table:

```markdown
| Option | Description |
|--------|-------------|
| `-target <name>` | Build specific target |
| `-group <name>` | Build specific group |
| `-log <path>` | Write log to file |
| `-verbose` | Enable verbose output |
| `-clean` | Clean before build |
| `--skip-reports` | Skip report pipelines (2025.1+) |
```

### 2. cli-reference.md - Detailed Documentation

**File:** `plugins/webworks-claude-skills/skills/automap/references/cli-reference.md`
**Location:** After "Deployment Control" section (line 63), add new "Performance Options" section

```markdown
### Performance Options

**`--skip-reports`** *(2025.1+)*
- **Purpose**: Skip report generation pipelines during build
- **Use When**: CI/CD builds, agentic workflows, or iterative development where reports not needed
- **Impact**: Faster builds, reduced file system output
- **Trade-off**: No build reports generated (errors still shown in console)
- **Example**: `-c -n --skip-reports project.wep`
```

### 3. Update Best Practices Section

**File:** `plugins/webworks-claude-skills/skills/automap/references/cli-reference.md`
**Location:** Best Practices section (line 305+)

Add new best practice for agentic builds:

```markdown
### 9. Use --skip-reports for Automated Workflows (2025.1+)

Skip report generation in CI/CD and agentic builds:
```bash
"[AutoMap-Path]" -c -n --skip-reports "[Project-File]"
```

Reports are useful for debugging but add overhead and file noise in automated pipelines.
```

### 4. Update Version Target

**File:** `plugins/webworks-claude-skills/skills/automap/references/cli-reference.md`
**Location:** Line 412

Update target version:

```markdown
**Target**: ePublisher 2024.1+ AutoMap CLI (--skip-reports requires 2025.1+)
```

## Acceptance Criteria

- [ ] `--skip-reports` added to SKILL.md Common Options table with version note
- [ ] Detailed documentation added to cli-reference.md
- [ ] Best practice added for agentic/CI workflows
- [ ] Version requirement clearly documented as 2025.1+

## Files to Modify

| File | Change |
|------|--------|
| `plugins/webworks-claude-skills/skills/automap/SKILL.md` | Add table row |
| `plugins/webworks-claude-skills/skills/automap/references/cli-reference.md` | Add section + best practice |

## References

- Current SKILL.md structure: Lines 132-153
- Current cli-reference.md structure: Full file reviewed
- Version notation pattern: `2024.1+` used in requirements section
