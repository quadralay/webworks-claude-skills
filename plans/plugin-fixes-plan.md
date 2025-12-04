# Plugin Fixes Plan

Plan for addressing issues identified during comprehensive review of the `epublisher-automation` plugin.

**Created:** 2025-12-04
**Status:** Complete

### Progress

| Phase | Status | Commit |
|-------|--------|--------|
| Phase 1: Create plugin.json | ✅ Complete | a20f529 |
| Phase 2: Fix Node Version Check | ✅ Complete | 591ed40 |
| Phase 3: Document setup-dependencies.sh | ✅ Complete | ee6342a |
| Phase 4: Add Cross-Skill Guidance | ✅ Complete | f33aece |
| Phase 5: Add Troubleshooting Sections | ✅ Complete | 6acd017 |

---

## Overview

This plan addresses issues identified during a comprehensive review of the `epublisher-automation` plugin. The review found excellent documentation and script quality, but identified one critical issue and several medium-priority improvements.

### Current State

- 3 skills: `epublisher`, `automap`, `reverb`
- All SKILL.md files have valid YAML frontmatter
- All scripts documented and well-implemented
- Router pattern working in reverb skill
- Missing plugin.json (critical)
- Minor inconsistencies in documentation

### Target State

- Plugin properly registered with plugin.json
- Node version requirements consistent
- All scripts documented in SKILL.md
- Cross-skill relationships clearly documented
- Troubleshooting guidance for common errors

---

## Phase 1: Create plugin.json (Critical)

The plugin is missing the required `plugin.json` registration file.

### Task 1.1: Create plugin.json

**File:** `plugins/epublisher-automation/plugin.json`

**Content:**
```json
{
  "name": "epublisher-automation",
  "version": "1.0.0",
  "description": "Claude Code skills for WebWorks ePublisher automation including project management, build automation, and Reverb output testing",
  "author": "WebWorks",
  "skills": [
    {
      "name": "epublisher",
      "path": "skills/epublisher"
    },
    {
      "name": "automap",
      "path": "skills/automap"
    },
    {
      "name": "reverb",
      "path": "skills/reverb"
    }
  ],
  "keywords": [
    "epublisher",
    "webworks",
    "documentation",
    "reverb",
    "automap"
  ]
}
```

---

## Phase 2: Fix Node Version Check (Medium)

`package.json` requires Node >=18, but `setup-dependencies.sh` checks for >=14.

### Task 2.1: Update setup-dependencies.sh

**File:** `plugins/epublisher-automation/skills/reverb/scripts/setup-dependencies.sh`

**Current (line 62-68):**
```bash
# Check minimum version (14.0.0)
local major_version
major_version=$(echo "$node_version" | sed 's/v//' | cut -d. -f1)

if [[ "$major_version" -lt 14 ]]; then
    error_log "Node.js version 14+ required, found: $node_version"
    return 1
fi
```

**Replace with:**
```bash
# Check minimum version (18.0.0) - matches package.json requirement
local major_version
major_version=$(echo "$node_version" | sed 's/v//' | cut -d. -f1)

if [[ "$major_version" -lt 18 ]]; then
    error_log "Node.js version 18+ required, found: $node_version"
    error_log "See package.json engines requirement"
    return 1
fi
```

---

## Phase 3: Document setup-dependencies.sh (Medium)

The `setup-dependencies.sh` script is mentioned in the `<dependencies>` section but not listed in the `<scripts>` section of reverb/SKILL.md.

### Task 3.1: Add to scripts section

**File:** `plugins/epublisher-automation/skills/reverb/SKILL.md`

**Find the `<scripts>` section and add:**

```markdown
### setup-dependencies.sh

Installs Node.js dependencies for browser testing.

```bash
# Install dependencies (run once)
./scripts/setup-dependencies.sh
```

**Prerequisites:**
- Node.js 18+ installed
- npm available in PATH

**Exit codes:**
- 0: Dependencies installed successfully
- 1: Node.js not found or npm install failed
```

---

## Phase 4: Add Cross-Skill Guidance (Medium)

Document how the three skills relate and when to use each.

### Task 4.1: Add cross-skill section to epublisher/SKILL.md

**File:** `plugins/epublisher-automation/skills/epublisher/SKILL.md`

**Add before `</objective>` or after `<overview>`:**

```xml
<related_skills>

## Related Skills

This skill provides foundational knowledge used by other skills in this plugin:

| Skill | When to Use |
|-------|-------------|
| **automap** | After understanding project structure, use automap to execute builds |
| **reverb** | After building Reverb output, use reverb skill to test and customize |

**Typical workflow:**
1. Use **epublisher** to understand project files and targets
2. Use **automap** to build specific targets
3. Use **reverb** to test and customize Reverb 2.0 output

</related_skills>
```

### Task 4.2: Add cross-skill section to automap/SKILL.md

**File:** `plugins/epublisher-automation/skills/automap/SKILL.md`

**Add similar section:**

```xml
<related_skills>

## Related Skills

| Skill | Relationship |
|-------|--------------|
| **epublisher** | Use first to understand project structure and target names |
| **reverb** | Use after building Reverb output to test and customize |

</related_skills>
```

### Task 4.3: Add cross-skill section to reverb/SKILL.md

**File:** `plugins/epublisher-automation/skills/reverb/SKILL.md`

**Add similar section:**

```xml
<related_skills>

## Related Skills

| Skill | Relationship |
|-------|--------------|
| **epublisher** | Use to understand project structure before testing |
| **automap** | Use to rebuild output after SCSS customizations |

**After customizing themes:** Use the automap skill to rebuild:
```bash
./automap-wrapper.sh -c -n -t "WebWorks Reverb 2.0" project.wep
```

</related_skills>
```

---

## Phase 5: Add Troubleshooting Sections (Low)

Add common error scenarios and solutions to each skill.

### Task 5.1: Add troubleshooting to epublisher/SKILL.md

**File:** `plugins/epublisher-automation/skills/epublisher/SKILL.md`

**Add section:**

```xml
<troubleshooting>

## Troubleshooting

### "No targets found in project"

**Cause:** Project file doesn't contain `<Format>` elements.

**Solutions:**
1. Verify file is a valid .wep/.wrp/.wxsp file
2. Check if project was created in a compatible ePublisher version
3. Open project in ePublisher Administrator to verify structure

### "Project file not found"

**Cause:** Path is incorrect or file doesn't exist.

**Solutions:**
1. Use absolute Windows paths (e.g., `C:\Projects\MyDoc.wep`)
2. Check for spaces in path (quote the path)
3. Verify file extension is .wep, .wrp, or .wxsp

### "Invalid project file extension"

**Cause:** File is not a recognized ePublisher project type.

**Solutions:**
1. Use .wep (WebWorks ePublisher Project)
2. Use .wrp (WebWorks ePublisher Report Project)
3. Use .wxsp (WebWorks ePublisher Stationery Project)

</troubleshooting>
```

### Task 5.2: Add troubleshooting to automap/SKILL.md

**File:** `plugins/epublisher-automation/skills/automap/SKILL.md`

**Add section:**

```xml
<troubleshooting>

## Troubleshooting

### "AutoMap installation not found"

**Cause:** AutoMap not installed or not in expected location.

**Solutions:**
1. Verify ePublisher AutoMap is installed
2. Check registry: `HKLM\SOFTWARE\WebWorks\ePublisher AutoMap`
3. Check filesystem: `C:\Program Files\WebWorks\ePublisher\[version]\`
4. Use `--verbose` flag for detailed detection output

### "Build failed with exit code 1"

**Cause:** ePublisher build encountered errors.

**Solutions:**
1. Check AutoMap output for specific error messages
2. Verify source documents exist and are accessible
3. Open project in ePublisher Administrator to check for issues
4. Try building with `-c` (clean) flag

### "Target not found"

**Cause:** Specified target name doesn't exist in project.

**Solutions:**
1. Use `parse-targets.sh` to list available targets
2. Verify target name spelling (case-sensitive)
3. Check project file for available `<Format>` elements

</troubleshooting>
```

### Task 5.3: Add troubleshooting to reverb/SKILL.md

**File:** `plugins/epublisher-automation/skills/reverb/SKILL.md`

**Add section:**

```xml
<troubleshooting>

## Troubleshooting

### "Chrome not found"

**Cause:** Chrome/Chromium not installed or not in expected location.

**Solutions:**
1. Install Chrome from https://www.google.com/chrome/
2. Set `CHROME_PATH` environment variable
3. Edge Chromium can be used as fallback

### "Timeout waiting for Reverb to load"

**Cause:** Reverb output failed to initialize within timeout.

**Solutions:**
1. Increase timeout: `TIMEOUT=60000 node browser-test.js ...`
2. Check for JavaScript errors in output
3. Verify output was built successfully
4. Try loading output manually in browser

### "url_maps.xml not found"

**Cause:** CSH link file doesn't exist in output.

**Solutions:**
1. Verify build completed successfully
2. Check that CSH is enabled in FormatSettings
3. Look in `[Output]/wwhdata/common/` directory

### "SCSS compilation failed"

**Cause:** Invalid SCSS syntax in customization file.

**Solutions:**
1. Validate hex color format (#RRGGBB)
2. Check for missing semicolons
3. Verify variable names match Reverb schema
4. Use `--validate-only` flag to check before copying

</troubleshooting>
```

---

## Implementation Order

### Critical (Do First)
1. Phase 1: Create plugin.json

### Medium Priority
2. Phase 2: Fix Node version check
3. Phase 3: Document setup-dependencies.sh
4. Phase 4: Add cross-skill guidance

### Low Priority
5. Phase 5: Add troubleshooting sections

---

## Validation Checklist

After implementation, verify:

- [ ] `plugin.json` exists at `plugins/epublisher-automation/plugin.json`
- [ ] `setup-dependencies.sh` checks for Node >=18
- [ ] `setup-dependencies.sh` is documented in reverb SKILL.md scripts section
- [ ] All three SKILL.md files have `<related_skills>` section
- [ ] All three SKILL.md files have `<troubleshooting>` section
- [ ] Plugin loads correctly in Claude Code

---

## Notes

- All changes are additive (no existing content removed)
- Script implementations remain unchanged
- Focus on documentation completeness
- Test plugin registration after creating plugin.json
