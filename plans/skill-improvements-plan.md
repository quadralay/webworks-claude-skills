# Skill Improvements Plan

Plan for improving the WebWorks Agent Skills plugin based on Claude Code skill best practices.

**Created:** 2025-12-03
**Status:** In Progress

### Progress

| Phase | Status | Commit |
|-------|--------|--------|
| Phase 1: YAML Frontmatter | ✅ Complete | `70be117` |
| Task 5.1: Fix broken reference | ✅ Complete (restored script) | `70be117` |
| Phase 2: XML Structure | ✅ Complete | |
| Phase 3: Router Pattern | ✅ Complete | |
| Phase 4: Reduce Duplication | ✅ Complete | |
| Phase 6: Add Templates | Pending | |
| Phase 7: Version Compatibility | Pending | |

---

## Overview

This plan addresses improvements identified during a comprehensive review of the `epublisher-automation` plugin against Claude Code skill authoring best practices. The plugin has excellent domain knowledge and well-structured scripts, but needs updates to follow the recommended skill format.

### Current State

- 3 skills: `epublisher`, `automap`, `reverb`
- Good separation of concerns
- Comprehensive reference documentation
- Well-written scripts with proper error handling

### Target State

- All skills follow YAML frontmatter + XML structure pattern
- Router pattern implemented for complex skills
- Reduced duplication across files
- Clear success criteria for each skill
- Consistent templates for outputs

---

## Phase 1: YAML Frontmatter (High Priority) ✅ COMPLETE

Add required YAML frontmatter to all SKILL.md files.

> **Completed:** 2025-12-03 in commit `70be117`
> **Note:** YAML `name` field must match directory name (corrected from initial implementation)

### Task 1.1: Update epublisher/SKILL.md

**File:** `plugins/epublisher-automation/skills/epublisher/SKILL.md`

**Add at top of file:**
```yaml
---
name: epublisher-core
description: Core knowledge about WebWorks ePublisher projects, file structure, and conventions. Use when working with ePublisher project files, understanding file resolver hierarchy, or parsing targets and source documents.
---
```

### Task 1.2: Update automap/SKILL.md

**File:** `plugins/epublisher-automation/skills/automap/SKILL.md`

**Add at top of file:**
```yaml
---
name: epublisher-automap
description: Build automation for WebWorks ePublisher using AutoMap command-line interface. Use when executing builds, detecting installations, or automating publishing workflows.
---
```

### Task 1.3: Update reverb/SKILL.md

**File:** `plugins/epublisher-automation/skills/reverb/SKILL.md`

**Add at top of file:**
```yaml
---
name: epublisher-reverb-test-orchestrator
description: Analysis, testing, and customization tools for WebWorks Reverb 2.0 output. Use when testing Reverb output in browser, analyzing CSH links, customizing SCSS themes, or generating test reports.
---
```

---

## Phase 2: Convert to XML Structure (High Priority) ✅ COMPLETE

Replace markdown headings with semantic XML tags in SKILL.md files.

> **Completed:** 2025-12-04
> **Changes:** All three SKILL.md files converted to semantic XML structure with tags like `<objective>`, `<overview>`, `<key_concepts>`, `<scripts>`, `<references>`, `<success_criteria>`, etc. Reverb skill also includes `<intake>` and `<routing>` tags to prepare for Phase 3 router pattern.

### Task 2.1: Restructure epublisher/SKILL.md

**Current structure:**
```markdown
# epublisher
Core knowledge about...

## Overview
WebWorks ePublisher transforms...

## Key Concepts
### Project Structure
...
```

**Target structure:**
```xml
---
name: epublisher-core
description: ...
---

<objective>
Core knowledge about WebWorks ePublisher projects, file structure, and conventions.
</objective>

<overview>
WebWorks ePublisher transforms source documents (Word, FrameMaker, DITA, Markdown) into multiple output formats (Reverb, PDF, CHM, etc.) using a project-based workflow.
</overview>

<key_concepts>
...
</key_concepts>

<scripts>
...
</scripts>

<references>
- file-resolver-guide.md - Complete file resolution hierarchy
- project-parsing-guide.md - Detailed project file structure
- user-interaction-patterns.md - UX patterns for ePublisher workflows
</references>

<success_criteria>
- Project file parsed successfully
- Targets and formats extracted
- Source documents listed
- File resolver paths identified correctly
</success_criteria>
```

### Task 2.2: Restructure automap/SKILL.md

**Target structure:**
```xml
---
name: epublisher-automap
description: ...
---

<objective>
Build automation for WebWorks ePublisher using AutoMap command-line interface.
</objective>

<quick_start>
### Detect Installation
...
### Run a Build
...
</quick_start>

<cli_reference>
...
</cli_reference>

<scripts>
...
</scripts>

<references>
- cli-reference.md - Complete CLI options and syntax
- cli-vs-administrator.md - When to use CLI vs GUI
- installation-detection.md - Installation paths and detection logic
</references>

<exit_codes>
...
</exit_codes>

<success_criteria>
- AutoMap installation detected
- Build executed without errors
- Output generated at expected location
- Exit code indicates success (0)
</success_criteria>
```

### Task 2.3: Restructure reverb/SKILL.md

**Target structure:**
```xml
---
name: epublisher-reverb-test-orchestrator
description: ...
---

<objective>
Analysis, testing, and customization tools for WebWorks Reverb 2.0 output.
</objective>

<intake>
What would you like to do?

1. Test Reverb output in browser
2. Analyze CSH links
3. Customize SCSS theme
4. Generate test report

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "test", "browser" | workflows/browser-testing.md |
| 2, "csh", "links" | workflows/csh-analysis.md |
| 3, "scss", "theme", "colors" | workflows/scss-theming.md |
| 4, "report" | workflows/generate-report.md |
</routing>

<capabilities>
| Feature | Script | Description |
|---------|--------|-------------|
| Browser Testing | browser-test.js | Load output in headless Chrome |
| CSH Analysis | parse-url-maps.sh | Extract topic mappings |
| SCSS Theming | extract-scss-variables.sh | Read theme values |
| Color Override | generate-color-override.sh | Generate brand colors |
</capabilities>

<references>
- See workflows/ for detailed procedures
</references>

<success_criteria>
- Reverb output loads without JavaScript errors
- All expected components present in DOM
- CSH links validate against url_maps.xml
- Theme changes compile without SCSS errors
</success_criteria>
```

---

## Phase 3: Add Router Pattern to Reverb Skill (High Priority) ✅ COMPLETE

Create workflow files for the reverb skill's distinct operations.

> **Completed:** 2025-12-04
> **Changes:** Created 4 workflow files in `skills/reverb/workflows/`:
> - `browser-testing.md` - Headless Chrome testing workflow
> - `csh-analysis.md` - CSH link parsing and validation workflow
> - `scss-theming.md` - SCSS variable extraction and color override workflow
> - `generate-report.md` - Comprehensive test report generation workflow

### Task 3.1: Create workflows directory

```bash
mkdir -p plugins/epublisher-automation/skills/reverb/workflows
```

### Task 3.2: Create browser-testing.md workflow

**File:** `plugins/epublisher-automation/skills/reverb/workflows/browser-testing.md`

**Content outline:**
```xml
<workflow>
Browser Testing Workflow
</workflow>

<required_reading>
None - all info in this file
</required_reading>

<process>
1. Detect Chrome installation
2. Locate Reverb entry point
3. Run browser-test.js
4. Analyze results
5. Report findings
</process>

<scripts>
- detect-chrome.sh
- detect-entry-point.sh
- browser-test.js
</scripts>

<success_criteria>
- Browser launches successfully
- Reverb runtime loads (Parcels.loaded_all === true)
- No console errors
- All expected components present
</success_criteria>
```

### Task 3.3: Create csh-analysis.md workflow

**File:** `plugins/epublisher-automation/skills/reverb/workflows/csh-analysis.md`

**Content outline:**
```xml
<workflow>
CSH Link Analysis Workflow
</workflow>

<process>
1. Locate url_maps.xml in output
2. Parse topic mappings
3. Validate link structure
4. Report findings
</process>

<scripts>
- parse-url-maps.sh
</scripts>

<success_criteria>
- url_maps.xml parsed successfully
- Topic IDs extracted
- Links validated
</success_criteria>
```

### Task 3.4: Create scss-theming.md workflow

**File:** `plugins/epublisher-automation/skills/reverb/workflows/scss-theming.md`

**Content outline:**
```xml
<workflow>
SCSS Theme Customization Workflow
</workflow>

<required_reading>
- ../references/scss-variables.md (if created)
- OR inline neo variables reference
</required_reading>

<process>
1. Extract current SCSS variables
2. Identify customization level (target vs format)
3. Generate color override file
4. Apply to project
5. Rebuild with automap skill
</process>

<scripts>
- extract-scss-variables.sh
- generate-color-override.sh
</scripts>

<success_criteria>
- SCSS variables extracted
- Override file generated at correct location
- Build completes without SCSS errors
</success_criteria>
```

### Task 3.5: Create generate-report.md workflow

**File:** `plugins/epublisher-automation/skills/reverb/workflows/generate-report.md`

**Content outline:**
```xml
<workflow>
Test Report Generation Workflow
</workflow>

<process>
1. Run browser test
2. Parse CSH links
3. Aggregate results
4. Generate formatted report
</process>

<scripts>
- generate-report.sh
</scripts>

<success_criteria>
- All tests executed
- Report generated with all sections
</success_criteria>
```

---

## Phase 4: Reduce Duplication (Medium Priority) ✅ COMPLETE

Remove duplicate content from SKILL.md files that already exists in references.

> **Completed:** 2025-12-04
> **Changes:**
> - epublisher/SKILL.md: Already simplified in Phase 2 with brief hierarchy summary + reference pointer
> - automap/SKILL.md: Removed duplicate Examples section, kept quick reference table with pointer to cli-reference.md

### Task 4.1: Simplify epublisher/SKILL.md

**Current:** Full file resolver hierarchy duplicated from `references/file-resolver-guide.md`

**Action:** Replace with brief summary + reference pointer:

```xml
<file_resolver>
ePublisher resolves files through a 4-level hierarchy (highest to lowest priority):

1. Target-Specific: `[Project]/Targets/[TargetName]/`
2. Format-Level: `[Project]/Formats/[FormatName]/`
3. Packaged Defaults: `[Project]/Formats/[FormatName].base/`
4. Installation: `C:\Program Files\WebWorks\ePublisher\[version]\Formats\`

**For complete details, see:** references/file-resolver-guide.md
</file_resolver>
```

### Task 4.2: Simplify automap/SKILL.md

**Current:** Full CLI reference duplicated from `references/cli-reference.md`

**Action:** Keep quick reference table, remove detailed examples:

```xml
<cli_quick_reference>
| Option | Description |
|--------|-------------|
| `-target <name>` | Build specific target |
| `-clean` | Clean before build |
| `-nodeploy` | Skip deployment |

**For complete CLI reference, see:** references/cli-reference.md
</cli_quick_reference>
```

---

## Phase 5: Fix Broken References (Medium Priority)

### Task 5.1: ~~Remove non-existent script reference~~ Restore copy-customization.py ✅ COMPLETE

> **Completed:** 2025-12-03 in commit `70be117`
> **Resolution:** Restored script from revision `54f0dbe` (v1.0.0) instead of removing reference

**File:** `plugins/epublisher-automation/skills/epublisher/scripts/copy-customization.py`

**Action:** ~~Remove or update the `copy-customization.py` reference since the script doesn't exist~~ Restored script and enhanced documentation:

**Current:**
```markdown
### copy-customization.py

Use the provided Python script for validated file copying:
...
```

**Options:**
1. Remove the section entirely
2. Create the script
3. Replace with bash equivalent using existing scripts

**Recommended:** Remove the section and add a note about manual validation.

### Task 5.2: Verify all referenced scripts exist

**Scripts referenced in reverb/SKILL.md:**
- [x] browser-test.js - EXISTS
- [x] parse-url-maps.sh - EXISTS
- [x] extract-scss-variables.sh - EXISTS
- [x] generate-color-override.sh - EXISTS
- [x] detect-entry-point.sh - EXISTS
- [x] generate-report.sh - EXISTS
- [x] detect-chrome.sh - EXISTS
- [x] setup-dependencies.sh - EXISTS

All reverb scripts verified.

---

## Phase 6: Add Templates (Low Priority)

### Task 6.1: Create templates directory

```bash
mkdir -p plugins/epublisher-automation/skills/reverb/templates
```

### Task 6.2: Create build-report template

**File:** `plugins/epublisher-automation/skills/reverb/templates/build-report.json`

```json
{
  "project": "",
  "target": "",
  "buildTime": "",
  "status": "success|failure",
  "errors": [],
  "warnings": [],
  "output": {
    "location": "",
    "fileCount": 0
  }
}
```

### Task 6.3: Create test-results template

**File:** `plugins/epublisher-automation/skills/reverb/templates/test-results.json`

```json
{
  "success": true,
  "reverbLoaded": true,
  "loadTime": 0,
  "errors": [],
  "warnings": [],
  "components": {
    "toolbar": { "present": true },
    "header": { "present": true },
    "footer": { "present": true },
    "toc": { "present": true, "itemCount": 0 },
    "content": { "present": true }
  },
  "csh": {
    "topicCount": 0,
    "validLinks": 0,
    "brokenLinks": 0
  }
}
```

---

## Phase 7: Add Version Compatibility Reference (Low Priority)

### Task 7.1: Create version-compatibility.md

**File:** `plugins/epublisher-automation/skills/epublisher/references/version-compatibility.md`

```markdown
# Version Compatibility

## Supported Versions

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| ePublisher | 2020.2 | 2024.1+ | Primary development target |
| AutoMap | 2024.1 | Latest | Required for automation |
| Reverb Format | 2.0 | 2.0 | Only Reverb 2.0 supported |
| Chrome | 90+ | Latest | For browser testing |
| Node.js | 16+ | 18+ | For Puppeteer scripts |
| Platform | Windows | Windows 10/11 | ePublisher is Windows-only |

## Breaking Changes by Version

### ePublisher 2024.1
- New AutoMap CLI executable name
- Updated registry paths

### ePublisher 2020.2
- Legacy support baseline
- Different file resolver behavior in some cases

## Detecting Version

Use `parse-targets.sh --version` to detect Base Format Version from project files.
```

---

## Implementation Order

### Quick Wins (Do First)
1. ~~Phase 1: Add YAML frontmatter (15 minutes)~~ ✅ Complete
2. ~~Task 5.1: Remove broken script reference (5 minutes)~~ ✅ Complete (restored script instead)

### Core Improvements
3. ~~Phase 2: Convert to XML structure (1-2 hours)~~ ✅ Complete
4. Phase 4: Reduce duplication (30 minutes)

### Router Pattern
5. Phase 3: Add reverb workflows (1 hour)

### Polish
6. Phase 6: Add templates (30 minutes)
7. Phase 7: Add version compatibility (20 minutes)

---

## Validation Checklist

After implementation, verify:

- [x] All SKILL.md files have valid YAML frontmatter
- [x] No markdown headings (##, ###) in SKILL.md body
- [x] All referenced scripts exist
- [x] All referenced files exist
- [x] Reverb skill router works correctly (workflows created)
- [ ] Skills activate appropriately in Claude Code
- [ ] Build automation still works end-to-end

---

## Notes

- Keep existing script implementations unchanged - they are well-written
- Preserve all domain knowledge in references
- Test with real ePublisher project after changes
- Consider adding integration tests for scripts
