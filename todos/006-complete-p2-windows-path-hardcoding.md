---
status: complete
priority: p2
issue_id: "006"
tags: [code-review, cross-platform, bug]
dependencies: []
---

# Windows Path Separator Hardcoding Breaks Cross-Platform

## Problem Statement

The `create-job.py` script hardcodes Windows path separators (`\`), which will break functionality on Linux/macOS systems.

## Findings

### Affected Files
- `scripts/create-job.py:263`

### Evidence
```python
# Line 263: Forces backslashes
doc_path = doc_path.replace('/', '\\')
```

Data corruption scenario on Linux:
```bash
# User on Linux creates job file:
documents: ['docs/intro.md']

# Script converts to Windows paths:
<Document path="docs\intro.md" />

# AutoMap on Linux can't find 'docs\intro.md' (backslash in filename!)
```

## Proposed Solutions

### Option A: Remove path normalization (Recommended)
- **Pros**: Let AutoMap handle platform differences
- **Cons**: Inconsistent path separators in output
- **Effort**: Tiny (5 minutes)
- **Risk**: Low

```python
# Just remove line 263 entirely
# doc_path = doc_path.replace('/', '\\')  # DELETE THIS
```

### Option B: Normalize to forward slashes
- **Pros**: Works everywhere, consistent output
- **Cons**: May look wrong on Windows
- **Effort**: Tiny (5 minutes)
- **Risk**: Low

```python
doc_path = doc_path.replace('\\', '/')  # Forward slashes work everywhere
```

### Option C: Use platform-aware normalization
- **Pros**: Correct for each platform
- **Cons**: Output varies by OS
- **Effort**: Small (30 minutes)
- **Risk**: Medium

```python
import os
doc_path = os.path.normpath(doc_path)
```

## Recommended Action

**Implement Option A** - Remove the hardcoded replacement. Let AutoMap handle path separators.

## Technical Details

### Affected Files
1. `plugins/epublisher-automation/skills/automap/scripts/create-job.py`

### Line to modify
Line 263: Remove or change the `replace('/', '\\')` call

## Acceptance Criteria

- [ ] Path separator hardcoding removed or made platform-aware
- [ ] Job files work correctly on Windows
- [ ] Job files work correctly on Linux/macOS (if supported)

## Work Log

| Date | Action | Result |
|------|--------|--------|
| 2025-12-05 | Identified during code review | Single line fix needed |
| 2025-12-05 | Approved during triage | Status: pending → ready |
| 2025-12-05 | Resolved: Removed hardcoded Windows path separator | Status: ready → complete |

## Resources

- PR: https://github.com/quadralay/webworks-claude-skills/pull/1
