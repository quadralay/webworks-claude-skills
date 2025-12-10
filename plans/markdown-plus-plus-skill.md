# feat: Markdown++ Claude Code Skill

## Overview

Create a new Claude Code skill for reading and writing Markdown++ documents. Markdown++ is an extended Markdown format created by WebWorks as both an output and interoperable source format within ePublisher 2024.1+.

The skill will be implemented as a **standalone plugin** (`markdown-plus-plus`) to encourage adoption beyond ePublisher workflows, with optional integration hooks for the existing `epublisher-automation` plugin.

## Problem Statement / Motivation

Markdown++ bridges proprietary authoring tools (FrameMaker, Word, DITA-XML) and Markdown ecosystems. AI models need guidance to:
- Understand Markdown++ syntax and extension patterns
- Generate properly formatted Markdown++ documents
- Validate their output against the specification

This skill enables AI models (Claude, ChatGPT, etc.) to create Markdown++ source documents from existing content or generate new documentation in the correct format.

## Proposed Solution

Create a **documentation-focused Claude Code skill** that teaches AI models how to read and write Markdown++ documents. The skill emphasizes:

1. **Comprehensive syntax reference** - Complete documentation of all extensions
2. **Examples and patterns** - Real-world usage examples for each extension type
3. **Validation script** - Simple Python script to validate generated output
4. **Best practices** - Guidance on when and how to use each extension

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Skill Placement** | Standalone plugin (`markdown-plus-plus`) | Encourages broader adoption; format-agnostic design |
| **Primary Focus** | Documentation + examples | AI models learn from examples; scripts are secondary |
| **Validation Script** | Python 3.10+ | Simple validation of AI-generated output |
| **No Conversion Scripts** | Removed | AI creates Markdown++ directly; no automated conversion needed |

## Technical Approach

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Markdown++ Skill                         │
├─────────────────────────────────────────────────────────────┤
│  SKILL.md                                                   │
│  ├── Format Overview                                        │
│  ├── Quick Reference Table                                  │
│  ├── Usage Examples                                         │
│  └── Common Patterns                                        │
├─────────────────────────────────────────────────────────────┤
│  references/                                                │
│  ├── syntax-reference.md   # Complete extension syntax     │
│  ├── examples.md           # Real-world document examples  │
│  └── best-practices.md     # When/how to use extensions    │
├─────────────────────────────────────────────────────────────┤
│  scripts/                                                   │
│  ├── validate-mdpp.py      # Validate syntax               │
│  └── requirements.txt      # Python dependencies           │
├─────────────────────────────────────────────────────────────┤
│  tests/                                                     │
│  ├── sample-basic.md       # Basic extensions              │
│  └── sample-full.md        # All extension types           │
└─────────────────────────────────────────────────────────────┘
```

### Markdown++ Extension Syntax

Based on WebWorks documentation, the skill must handle:

| Extension | Syntax | Scope |
|-----------|--------|-------|
| **Variables** | `$variable_name;` | Inline |
| **Custom Styles** | `<!--style:StyleName-->` | Block (above) or Inline (before) |
| **Custom Aliases** | `<!--#alias-name-->` | Links to `[text](#alias-name)` |
| **Conditions** | `<!--condition:name-->...<!--/condition-->` | Block or Inline |
| **File Includes** | `<!--include:path/to/file.md-->` | Block only |
| **Markers** | `<!--markers:{"Key": "value"}-->` or `<!--marker:key="value"-->` | Block or Inline |
| **Multiline Tables** | `<!-- multiline -->` above table | Block modifier |
| **Combined** | `<!-- style:Name ; #alias ; marker:x="y" -->` | Multiple commands |

### Condition Operators

| Operator | Syntax | Meaning |
|----------|--------|---------|
| Space | `condition1 condition2` | AND - all must be visible |
| Comma | `condition1,condition2` | OR - any can be visible |
| Exclamation | `!condition1` | NOT - visible when hidden |

**Precedence**: NOT binds tightest, then AND (space), then OR (comma)

Example: `<!--condition:!print,web mobile-->` = `(!print) OR (web AND mobile)`

### Implementation Phases

#### Phase 1: Core Documentation

**Deliverables:**
- SKILL.md with comprehensive syntax reference and examples
- `references/syntax-reference.md` - Complete extension documentation
- `references/examples.md` - Real-world document examples
- Sample test files demonstrating all extensions

**Success Criteria:**
- [ ] All 7 extension types documented with syntax and examples
- [ ] Common patterns and best practices included
- [ ] AI models can generate valid Markdown++ from documentation alone

**Files to Create:**
```
plugins/markdown-plus-plus/
├── plugin.json
└── skills/
    └── markdown-plus-plus/
        ├── SKILL.md
        ├── references/
        │   ├── syntax-reference.md
        │   └── examples.md
        └── tests/
            ├── sample-basic.md
            └── sample-full.md
```

#### Phase 2: Validation Script

**Deliverables:**
- `validate-mdpp.py` - CLI for syntax validation
- Error reporting with line numbers and suggestions

**Success Criteria:**
- [ ] Validate all 7 extension types
- [ ] Detect unclosed conditions, malformed markers, invalid variable names
- [ ] Provide actionable error messages
- [ ] Exit codes follow conventions (0=success, 1=file error, 2=args, 3=validation)

**Files to Create:**
```
scripts/
├── validate-mdpp.py
└── requirements.txt
```

#### Phase 3: Best Practices & Integration

**Deliverables:**
- `references/best-practices.md` - When/how to use each extension
- Integration guidance for ePublisher workflows
- Related skills documentation

**Success Criteria:**
- [ ] Document when to use variables vs. conditions
- [ ] Explain style application patterns (block vs. inline)
- [ ] Provide ePublisher project context
- [ ] Link to related epublisher-automation skills

**Files to Create:**
```
references/
└── best-practices.md
```

## Acceptance Criteria

### Functional Requirements

- [ ] Document all 7 Markdown++ extension types with syntax and examples
- [ ] Provide real-world document examples showing common patterns
- [ ] Validation script detects syntax errors with file:line references
- [ ] AI models can generate valid Markdown++ using only the documentation

### Non-Functional Requirements

- [ ] SKILL.md under 500 lines (detail in references/)
- [ ] Clear, scannable syntax tables
- [ ] Examples for every extension type
- [ ] Validation script has Python 3.10+ compatibility

### Quality Gates

- [ ] Test samples cover all extension types
- [ ] Validation script has `--help` and proper exit codes
- [ ] Documentation reviewed for accuracy against WebWorks specs

## Dependencies & Prerequisites

### Required
- Python 3.10+ (for validation script only)

### Optional
- epublisher-automation plugin (for project integration)

## Risk Analysis & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| AI generates invalid syntax | Medium | Medium | Provide clear syntax rules and examples; validation script catches errors |
| Documentation too complex | Low | Medium | Keep SKILL.md scannable; use reference docs for detail |
| Missing edge cases | Medium | Low | Comprehensive examples; iterate based on usage |

## Technical Specification Details

### Validation Error Format

```python
{
    "type": "error",           # error | warning | info
    "code": "MDPP001",         # Unique error code
    "message": "Unclosed condition block",
    "file": "docs/intro.md",
    "line": 20,
    "context": "<!--condition:web-->",
    "suggestion": "Add <!--/condition--> to close the block"
}
```

### Validation Script CLI

```bash
python validate-mdpp.py <input_file> [options]

Options:
  --help          Show usage
  --verbose       Enable verbose output
  --json          Output errors as JSON
  --strict        Treat warnings as errors
```

### Validation Checks

| Check | Error Code | Description |
|-------|------------|-------------|
| Unclosed condition | MDPP001 | `<!--condition:x-->` without `<!--/condition-->` |
| Invalid variable name | MDPP002 | Variable contains spaces or invalid characters |
| Malformed marker JSON | MDPP003 | `<!--markers:{...}-->` with invalid JSON |
| Invalid style placement | MDPP004 | Style tag not immediately before element |
| Circular include | MDPP005 | File includes itself (directly or indirectly) |
| Missing include file | MDPP006 | Referenced file does not exist |
| Invalid condition syntax | MDPP007 | Malformed condition expression |

## References & Research

### Internal References

| File | Purpose |
|------|---------|
| `plugins/epublisher-automation/skills/automap/SKILL.md` | Skill structure pattern |
| `plugins/epublisher-automation/skills/automap/scripts/lib/` | Shared library pattern |
| `plugins/epublisher-automation/plugin.json` | Plugin manifest format |
| `plans/add-automap-job-file-support.md` | Plan document example |

### External References

| Resource | URL |
|----------|-----|
| Markdown++ Cheatsheet | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.27.html |
| Markdown++ Variables | Variables syntax and usage |
| Custom Styles | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.22.html |
| Multiline Tables | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.21.html |
| Conditions | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.25.html |
| File Includes | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.26.html |
| Markers | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.24.html |
| Custom Aliases | https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.23.html |
| CommonMark Spec | https://spec.commonmark.org/0.30/ |
| markdown-it-py | https://github.com/executablebooks/markdown-it-py |

### Related PRs/Issues

- ePublisher 2024.1+ introduced Markdown++ format
- Part of WebWorks documentation modernization initiative

## MVP

### plugin.json

```json
{
  "name": "markdown-plus-plus",
  "version": "1.0.0",
  "description": "Parse, validate, and generate Markdown++ documents with extended syntax for variables, conditions, styles, and more",
  "author": "WebWorks",
  "skills": [
    {
      "name": "markdown-plus-plus",
      "path": "skills/markdown-plus-plus"
    }
  ],
  "keywords": ["markdown", "markdown++", "mdpp", "documentation", "webworks", "epublisher"]
}
```

### SKILL.md

```markdown
---
name: markdown-plus-plus
description: Read and write Markdown++ documents with extended syntax for variables, conditions, custom styles, file includes, and markers. Use when creating Markdown++ source documents for ePublisher, generating documentation with conditional content, or working with extended Markdown formats.
---

<objective>

# markdown-plus-plus

Read and write Markdown++ documents - an extended Markdown format with variables, conditions, custom styles, file includes, and markers.
</objective>

<overview>

## Overview

Markdown++ extends CommonMark with HTML comment-based extensions. All extensions (except variables) use HTML comments for backward compatibility with standard Markdown renderers.

### Quick Reference

| Extension | Syntax | Scope |
|-----------|--------|-------|
| Variables | `$variable_name;` | Inline - reusable content |
| Styles | `<!--style:Name-->` | Block (above) or Inline (before) |
| Aliases | `<!--#alias-name-->` | Anchor for `[text](#alias-name)` links |
| Conditions | `<!--condition:name-->...<!--/condition-->` | Show/hide content by format |
| Includes | `<!--include:path/to/file.md-->` | Insert file contents |
| Markers | `<!--markers:{"Key": "val"}-->` | Metadata for search/processing |
| Multiline Tables | `<!-- multiline -->` | Enable block content in cells |

</overview>

<syntax_examples>

## Syntax Examples

### Variables
```markdown
Welcome to $product_name;, version $version;.
The **$product_name;** application supports...
```
- Alphanumeric, hyphens, underscores only
- Must end with semicolon
- No spaces in variable names

### Custom Styles

**Block-level** (place on line above):
```markdown
<!--style:CustomHeading-->
# My Heading
```

**Inline** (place immediately before):
```markdown
This is <!--style:Emphasis-->**important text**.
```

### Conditions

**Block content**:
```markdown
<!--condition:web-->
Visit our [website](https://example.com) for updates.
<!--/condition-->

<!--condition:print-->
See Appendix A for additional resources.
<!--/condition-->
```

**Operators**:
- Space = AND: `<!--condition:web production-->`
- Comma = OR: `<!--condition:web,print-->`
- Exclamation = NOT: `<!--condition:!internal-->`

### File Includes
```markdown
<!--include:shared/header.md-->
<!--include:../common/footer.md-->
```
- Paths relative to containing file
- Recursive includes supported

### Markers
```markdown
<!--markers:{"Keywords": "api, documentation", "Author": "WebWorks"}-->

<!--marker:Keywords="api, documentation"-->
```

### Combined Commands
```markdown
<!-- style:CustomStyle ; #my-alias ; marker:Keywords="example" -->
# Heading with Style, Alias, and Marker
```

</syntax_examples>

<validation>

## Validation

Use the validation script to check Markdown++ syntax:
```bash
python scripts/validate-mdpp.py document.md
```

See `references/syntax-reference.md` for complete syntax rules.

</validation>

<references>

## Reference Files

- `references/syntax-reference.md` - Complete extension syntax documentation
- `references/examples.md` - Real-world document examples
- `references/best-practices.md` - When and how to use each extension

</references>

<related_skills>

## Related Skills

| Skill | Relationship |
|-------|--------------|
| epublisher | Understand project structure containing Markdown++ sources |
| automap | Build ePublisher projects with Markdown++ source documents |
| reverb | Test output generated from Markdown++ sources |

</related_skills>

<success_criteria>

## Success Criteria

- Markdown++ document uses correct syntax for all extensions
- Variables use valid names (alphanumeric, hyphens, underscores)
- Conditions have matching opening and closing tags
- File includes use valid relative paths
- Markers contain valid JSON (for `markers:` format)
</success_criteria>
```

### sample-full.md (test file)

```markdown
<!--#document-start-->
<!--markers:{"Author": "WebWorks", "Version": "1.0"}-->

# $product_name; Documentation

Welcome to <!--style:ProductName-->**$product_name;**<!--style:Normal-->, version $version;.

## Getting Started

<!--condition:web-->
Visit our [website](https://example.com) for the latest updates.
<!--/condition-->

<!--condition:print-->
See Appendix A for additional resources.
<!--/condition-->

<!--condition:!internal-->
This documentation is for external users.
<!--/condition-->

## Features

<!--style:FeatureList-->
- Feature One: $feature_1_desc;
- Feature Two: $feature_2_desc;
- Feature Three: $feature_3_desc;

## Shared Content

<!--include:shared/header.md-->

## Data Tables

<!-- multiline -->
| Feature | Description | Status |
|---------|-------------|--------|
| Variables | Store reusable values like `$product_name;` | Active |
| Conditions | Show content based on output format

Example:
```markdown
<!--condition:web-->
Web only content
<!--/condition-->
```
| Active |

## Links

See [Document Start](#document-start) for the beginning.

<!--marker:Keywords="markdown, documentation, webworks"-->
```

## Clarifications Needed

Before implementation, these questions should be answered:

### Critical (Blocks Implementation)

1. **Variable Case Sensitivity**: Is `$Product;` the same as `$product;`?
   - **Assumption**: Case-sensitive (different variables)

2. **Base Markdown Specification**: CommonMark 0.30 or GFM?
   - **Assumption**: CommonMark 0.30 with GFM table extensions

3. **Maximum Include Depth**: How many levels of nested includes?
   - **Assumption**: 10 levels maximum, configurable

### Important (Affects UX)

4. **Whitespace in Extensions**: Is `<!-- style:Name -->` valid?
   - **Assumption**: Leading/trailing spaces inside comments are optional

5. **Extension Case Sensitivity**: Is `<!--STYLE:Name-->` valid?
   - **Assumption**: Keywords case-insensitive, values case-sensitive

6. **Multiple Styles on Element**: How to handle `<!--style:A--><!--style:B-->`?
   - **Assumption**: Warn, apply last style

---

*Plan created: 2025-12-09*
*Status: Ready for review*
