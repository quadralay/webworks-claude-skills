---
status: complete
priority: p2
issue_id: "005"
tags: [code-review, architecture, refactoring]
dependencies: ["001"]
---

# Code Duplication Across Scripts (~295 lines, 15%)

## Problem Statement

All 5 Python scripts contain nearly identical code for XML parsing, logging, constants, and file validation. This creates maintenance burden and risk of divergence.

## Findings

### Quantified Duplication

| Category | Lines Duplicated | Files Affected |
|----------|-----------------|----------------|
| Stationery XML parsing | ~88 | 2 |
| Job XML parsing | ~80 | 3 |
| Color constants | ~30 | 5 |
| Exit codes | ~22 | 5 |
| Logging functions | ~40 | 5 |
| File validation | ~20 | 4 |
| XML parsing wrapper | ~15 | 4 |
| **Total** | **~295** | **5** |

### Examples

Color constants defined identically in ALL 5 files:
```python
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
RED = '\033[0;31m'
NC = '\033[0m'
```

Logging functions duplicated:
```python
def log_error(message: str) -> None:
    print(f"{RED}[ERROR]{NC} {message}", file=sys.stderr)
```

## Proposed Solutions

### Option A: Create shared utilities module (Recommended)
- **Pros**: Eliminates duplication, single source of truth
- **Cons**: Adds import dependencies between scripts
- **Effort**: Medium (4 hours)
- **Risk**: Low

```
scripts/
├── lib/
│   ├── __init__.py
│   ├── constants.py      # Exit codes, colors
│   ├── logging.py        # log_error, log_info
│   ├── xml_utils.py      # XML parsing utilities
│   └── validators.py     # File validation functions
├── create-job.py
├── validate-job.py
└── ...
```

### Option B: Keep scripts standalone
- **Pros**: Each script is self-contained
- **Cons**: Continued duplication, maintenance burden
- **Effort**: None
- **Risk**: Medium - divergence over time

## Recommended Action

**Implement Option A** - Create `lib/` module with shared utilities.

## Technical Details

### Files to Create
- `scripts/lib/__init__.py`
- `scripts/lib/constants.py` - Color codes, exit codes, namespace dicts
- `scripts/lib/xml_utils.py` - Safe XML parsing with namespace handling
- `scripts/lib/validators.py` - File existence and extension validation

### Files to Update
All 5 scripts to import from lib/

## Acceptance Criteria

- [ ] `lib/` module created with shared utilities
- [ ] All scripts updated to import from lib/
- [ ] No duplicate code for constants, logging, XML parsing
- [ ] All scripts still work independently (can run from command line)
- [ ] LOC reduction of ~200+ lines

## Work Log

| Date | Action | Result |
|------|--------|--------|
| 2025-12-05 | Identified during code review | ~295 lines duplicated |
| 2025-12-05 | Approved during triage | Status: pending → ready |
| 2025-12-05 | Resolved: lib/ module created with shared utilities | Status: ready → complete |

## Resources

- PR: https://github.com/quadralay/webworks-claude-skills/pull/1
