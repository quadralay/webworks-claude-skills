---
status: complete
priority: p1
issue_id: "004"
tags: [code-review, data-integrity, critical]
dependencies: []
---

# Missing Configuration Validation Before XML Generation

## Problem Statement

No validation of config data before XML generation in `generate_job_xml()`. Empty or invalid values create malformed XML that may pass basic parsing but fail during AutoMap builds.

This is a CRITICAL data integrity issue that blocks the PR merge.

## Findings

### Affected Files
- `scripts/create-job.py:157-233` - `generate_job_xml()` function

### Evidence
Current code sets attributes without validation:
```python
# Line 172: No validation that group name is non-empty
group.set('name', group_config.get('name', ''))

# Line 182: No validation that format/name are non-empty
target.set('name', target_config.get('name', ''))
target.set('format', target_config.get('format', ''))
```

User can create invalid job file:
```json
{
  "targets": [{
    "name": "",
    "format": "",
    "formatType": "Application"
  }]
}
```

Generates technically valid but semantically broken XML:
```xml
<Target name="" format="" formatType="Application" build="True" ... />
```

## Proposed Solutions

### Option A: Add validation function before generation (Recommended)
- **Pros**: Comprehensive validation, clear error messages
- **Cons**: More code
- **Effort**: Small (2 hours)
- **Risk**: Low

```python
def validate_config(config: dict) -> list[str]:
    """Validate configuration before XML generation."""
    errors = []

    if not config.get('name', '').strip():
        errors.append("Job name cannot be empty")

    if not config.get('stationery', '').strip():
        errors.append("Stationery path cannot be empty")

    if not config.get('targets'):
        errors.append("At least one target is required")

    for i, target in enumerate(config.get('targets', [])):
        if not target.get('name', '').strip():
            errors.append(f"Target {i+1} name cannot be empty")
        if not target.get('format', '').strip():
            errors.append(f"Target {i+1} format cannot be empty")

    return errors
```

### Option B: Validate inline during generation
- **Pros**: Single pass through data
- **Cons**: Harder to collect all errors, less clear
- **Effort**: Small (1 hour)
- **Risk**: Medium

## Recommended Action

**Implement Option A** - Separate validation function called before `generate_job_xml()`.

## Technical Details

### Affected Files
1. `plugins/epublisher-automation/skills/automap/scripts/create-job.py`

### Fields to validate
- job name (non-empty)
- stationery path (non-empty)
- at least one target
- target name (non-empty)
- target format (non-empty)
- group names (non-empty, if groups exist)
- document paths (non-empty, if documents exist)

## Acceptance Criteria

- [ ] `validate_config()` function created
- [ ] Called before both interactive and config-file XML generation
- [ ] Clear error messages for each validation failure
- [ ] All required fields validated
- [ ] Exit with error code if validation fails

## Work Log

| Date | Action | Result |
|------|--------|--------|
| 2025-12-05 | Identified during code review | generate_job_xml lacks validation |
| 2025-12-05 | Approved during triage | Status: pending → ready |
| 2025-12-05 | Resolved: validate_config() function added | Status: ready → complete |

## Resources

- PR: https://github.com/quadralay/webworks-claude-skills/pull/1
