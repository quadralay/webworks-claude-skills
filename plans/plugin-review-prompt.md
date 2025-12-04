# Plugin Review Prompt

Use this prompt to conduct a comprehensive review of the epublisher-automation plugin.

---

## Prompt

Conduct a thorough, holistic review of the `plugins/epublisher-automation` plugin. This plugin provides Claude Code skills for WebWorks ePublisher automation.

### Review Scope

**1. Skill Structure & Best Practices**
- Do all SKILL.md files have valid YAML frontmatter with `name` and `description`?
- Does each `name` match its directory name?
- Are semantic XML tags used consistently across all skills?
- Do skills have clear `<objective>`, `<success_criteria>`, and appropriate sections?
- Is the router pattern in reverb skill working correctly (intake → routing → workflows)?

**2. Script Inventory & Functionality**
- List all scripts in each skill's `scripts/` directory
- Are all scripts referenced in SKILL.md files?
- Are there any orphaned scripts not documented anywhere?
- Do scripts have appropriate error handling and usage documentation?
- Are script dependencies documented (Node.js, Chrome, etc.)?

**3. Reference Documentation**
- Are all files in `references/` directories referenced from SKILL.md?
- Is there duplicate content between SKILL.md and reference files?
- Are cross-references between skills accurate (e.g., reverb referencing automap for builds)?

**4. Templates & Outputs**
- Are templates referenced in the appropriate workflows?
- Do script outputs match template structures?
- Is the relationship between scripts and templates clear?

**5. Workflows (reverb skill)**
- Do all 4 workflow files have consistent structure?
- Are `<required_reading>` sections accurate?
- Do `<success_criteria>` align with workflow steps?
- Are script references in workflows correct?

**6. Cross-Skill Integration**
- How do the 3 skills relate to each other?
- Is the intended usage flow clear (epublisher → automap → reverb)?
- Are there missing handoff points between skills?

**7. Gaps & Missing Pieces**
- Are there features mentioned but not implemented?
- Are there scripts that need corresponding documentation?
- What common user tasks might not be covered?
- Are error scenarios and troubleshooting documented?

**8. Consistency Check**
- File naming conventions
- Code style in scripts (bash vs Python)
- Documentation tone and formatting
- XML tag naming patterns

### Deliverables

1. **Findings summary** - Categorized list of issues found
2. **Severity assessment** - Critical, Medium, Low for each finding
3. **Recommendations** - Specific fixes or improvements
4. **Validation checklist** - Items to verify after fixes

### Files to Review

```
plugins/epublisher-automation/
├── skills/
│   ├── epublisher/
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── references/
│   ├── automap/
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── references/
│   └── reverb/
│       ├── SKILL.md
│       ├── scripts/
│       ├── references/
│       ├── workflows/
│       └── templates/
└── plugin.json
```

Start by reading all SKILL.md files, then systematically review each area above. Report findings as you go.
