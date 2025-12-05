---
status: complete
priority: p1
issue_id: "003"
tags: [code-review, data-integrity, critical]
dependencies: []
---

# Non-Atomic File Write Operations Risk Data Corruption

## Problem Statement

Files are written directly without using atomic write patterns. If the script crashes, disk fills up, or process is killed during write, the job file will be corrupted and unusable.

This is a CRITICAL data integrity issue that blocks the PR merge.

## Findings

### Affected Files
- `scripts/create-job.py:571-572` - Job file write
- `scripts/create-job.py:606-607` - Config export write
- `scripts/create-job.py:615-616` - Alternative job file write

### Evidence
Current vulnerable code:
```python
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(xml_content)
```

Data corruption scenario:
1. User runs `create-job.py` overwriting existing `job.waj`
2. Script writes 50% of file, then crashes or disk fills
3. Original `job.waj` is destroyed, new one is incomplete
4. AutoMap build fails with XML parse error

## Proposed Solutions

### Option A: Atomic write with temp file + rename (Recommended)
- **Pros**: Guarantees complete file or no change
- **Cons**: More complex, platform considerations
- **Effort**: Medium (2 hours)
- **Risk**: Low

```python
import tempfile
import os

def write_file_atomic(path: str, content: str, encoding: str = 'utf-8') -> None:
    """Write file atomically using temp file + rename."""
    path_obj = Path(path)
    dir_path = path_obj.parent

    fd, temp_path = tempfile.mkstemp(
        dir=dir_path,
        prefix=f'.{path_obj.name}.tmp',
        text=True
    )

    try:
        with os.fdopen(fd, 'w', encoding=encoding) as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
        os.replace(temp_path, path)  # Atomic on most systems
    except:
        os.unlink(temp_path)
        raise
```

### Option B: Write to new file, then rename
- **Pros**: Simpler implementation
- **Cons**: Leaves temp files on failure
- **Effort**: Small (1 hour)
- **Risk**: Medium

## Recommended Action

**Implement Option A** - Full atomic write pattern for all file outputs.

## Technical Details

### Affected Files
1. `plugins/epublisher-automation/skills/automap/scripts/create-job.py`

### Three write locations to update
- Line 571-572: Main job file generation
- Line 606-607: Config export
- Line 615-616: Alternative job file generation

## Acceptance Criteria

- [ ] `write_file_atomic()` helper function created
- [ ] All 3 file write operations use atomic pattern
- [ ] Temp files cleaned up on error
- [ ] Works correctly on Windows (os.replace semantics)

## Work Log

| Date | Action | Result |
|------|--------|--------|
| 2025-12-05 | Identified during code review | 3 write locations in create-job.py |
| 2025-12-05 | Approved during triage | Status: pending → ready |
| 2025-12-05 | Resolved: write_file_atomic() helper added | Status: ready → complete |

## Resources

- PR: https://github.com/quadralay/webworks-claude-skills/pull/1
