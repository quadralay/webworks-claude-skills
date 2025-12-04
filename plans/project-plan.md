# feat: Develop Claude Code Skill for WebWorks ePublisher AutoMap Integration

> **Historical Document Notice**
>
> This document describes the original planning phase for a monolithic skill approach.
> The project was released with a **modular multi-skill architecture** instead.
> This plan is preserved for historical context and technical reference only.
>
> **For current architecture and documentation:**
> - [README.md](../README.md) - Project overview with marketplace plugin structure
> - [SKILL_CATALOG.md](../docs/SKILL_CATALOG.md) - Overview of all 7 modular skills
> - [GETTING_STARTED.md](../docs/GETTING_STARTED.md) - Installation and usage guide
> - [epublisher-core SKILL.md](../plugins/epublisher-automation/skills/epublisher-core/SKILL.md) - Production-ready core skill

## Overview

Create a comprehensive Claude Code Skill that integrates WebWorks ePublisher AutoMap CLI with Claude Code, enabling AI-assisted documentation generation and format customization workflows. This skill will empower users to run AutoMap commands, modify ePublisher project files, and perform common customizations (`*.asp`, `*.scss`, `*.xsl` files) through an intelligent assistant that understands ePublisher's file resolver pattern and parallel construction architecture.

**Long-term Vision:** This skill will serve as the foundation for a Claude Code Marketplace plugin, making ePublisher automation accessible to the broader technical documentation community.

## Problem Statement / Motivation

### Current Pain Points

1. **Manual CLI Operations:** Users must manually construct complex AutoMap command lines with installation paths, project files, and target-specific parameters
2. **File Resolver Complexity:** Understanding and implementing ePublisher's parallel folder construction pattern for customizations requires deep product knowledge
3. **Customization Discovery:** Locating the correct files to copy from installation directories to project directories is time-consuming and error-prone
4. **Workflow Interruption:** Developers must context-switch between documentation, file explorers, and command-line interfaces to accomplish ePublisher tasks

### Why This Matters

WebWorks ePublisher users need to iterate rapidly on documentation output—adjusting styling, modifying templates, and regenerating content. Currently, this requires expert knowledge of:
- AutoMap CLI syntax and switches
- ePublisher's four-level override hierarchy (installation → stationery → format → target)
- File system conventions for parallel folder structures
- ASP/SCSS/XSL syntax and customization points

**AI-powered assistance can dramatically reduce the learning curve and accelerate iteration cycles**, especially valuable in the AI era where documentation teams are expected to deliver more with fewer resources.

## Proposed Solution

### Skill Architecture

Create a Claude Code Skill following the **System Skill Pattern** (CLI tool + SKILL.md + helper scripts):

```
epublisher-automap/
├── SKILL.md                      # Main skill definition with ePublisher knowledge
├── scripts/
│   ├── automap-wrapper.sh        # CLI wrapper with path detection
│   ├── detect-installation.sh    # Find AutoMap installation
│   └── copy-customization.py     # File copying with parallel structure
├── references/
│   ├── AUTOMAP_CLI_REFERENCE.md  # Detailed CLI documentation
│   └── FILE_RESOLVER_GUIDE.md    # Override hierarchy explained
└── templates/
    ├── asp/
    │   └── header-example.asp    # Common customization templates
    ├── scss/
    │   └── overrides-example.scss
    └── xsl/
        └── transform-example.xsl
```

### Core Capabilities

The skill will enable Claude Code to:

1. **Detect AutoMap Installation**
   - Query Windows Registry for AutoMap installation path
     - 64-bit: `HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\[VERSION]`
     - 32-bit: `HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\[VERSION]`
     - Read `ExePath` key for full path to executable
   - Identify installed ePublisher version from registry
   - Fallback to standard installation paths if registry unavailable
   - Validate AutoMap accessibility

2. **Run AutoMap Commands**
   - Build command-line arguments from project context
   - Execute AutoMap with appropriate parameters (`-u`, `--target`, etc.)
   - Parse build output for errors and warnings
   - Report generation success/failure

3. **Understand File Resolver Pattern**
   - Map installation files to correct project override paths
   - Maintain four-level override hierarchy awareness
   - Validate parallel folder structure requirements

4. **Perform File Customizations**
   - Copy files from installation to project maintaining exact directory structure
   - Target-specific: `[Project]\Targets\[TargetName]\[format-structure]\`
   - Format-level: `[Project]\Formats\[FormatName]\[format-structure]\`
   - Modify copied files with user-requested changes
   - Track customizations with documentation

5. **Assist with Project Operations**
   - Parse `.wep` (Designer project, the precursor to Stationery), `.wxsp` (Stationery project with no source documents, deep copy of all applicable installation XSL files) and `.wrp` (Project, deep copy) files
   - Extract target information from `<Format>` elements:
     - `TargetName` attribute - for AutoMap `-t` parameter
     - `Name` attribute - for customization path construction
     - `Type` and `TargetID` attributes - for validation
   - Identify configured targets and formats
   - List available targets to users
   - Validate target names before AutoMap execution
   - Guide users through common customization workflows

### Example Workflows

**Workflow 1: Generate HTML5 (Reverb) Output**
```
User: "Build the Reverb target for this project"
Claude: [Locates .wep file, constructs AutoMap command, executes build, reports results]
```

**Workflow 2: Customize Header Template**
```
User: "I want to modify the header template to add our company logo"
Claude: [Identifies header.asp in installation, creates parallel structure, copies file, guides logo customization]
```

**Workflow 3: Style Override**
```
User: "Change the primary color scheme for Reverb output"
Claude: [Copies skin.scss, creates _overrides.scss, modifies SASS variables in `_*.scss` overrides, rebuilds output]
```

**Workflow 4: Customize Toolbar**
```
User: "Change the toolbar layout for Reverb output"
Claude: [Copies `Connect.asp`, `skin.scss`, creates `_overrides.scss`, rebuilds output]

## Technical Considerations

### Architecture Impacts

**Progressive Disclosure Pattern:**
- SKILL.md frontmatter (~40 tokens) always loaded for skill discovery
- Full SKILL.md body (~3-5k tokens) loaded only when skill triggered
- Supporting files in `references/` loaded on-demand for specific tasks
- Enables comprehensive ePublisher knowledge without context bloat

**File Resolver Hierarchy (Priority Order):**
1. Target overrides: `[Project]\Targets\[TargetName]\`
2. Format overrides: `[Project]\Formats\[FormatName]\`
3. Installation defaults: `Program Files\WebWorks\ePublisher\[version]\Formats\`

**Critical Requirement:** File and folder names must exactly match installation hierarchy. The skill must enforce this constraint.

### Performance Implications

- **AutoMap Execution Time:** 2-10 minutes for large projects
  - Solution: Use Bash tool with extended timeout (600000ms)
  - Monitor progress through output streaming

- **Path Detection:** Registry-based detection is fast and reliable
  - Primary method: Query Windows Registry for `ExePath` value
  - Cache detected path for session duration
  - Fallback to file system search only if registry unavailable

### Security Considerations

**Permissions Required:**
- Read access to `C:\Program Files\WebWorks\ePublisher\` (installation directory)
- Write access to project directory for customizations
- Bash execution for AutoMap CLI invocation

**SKILL.md Configuration:**
```yaml
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
```

**Security Note:** Pre-authorizing Bash tool means Claude won't prompt for permission. This is appropriate for AutoMap since it's a trusted application, but skill should validate paths before operations.

### Version Compatibility

**Multi-Version Support:**
- Installation paths include version numbers: `ePublisher\2024.1\`, `ePublisher\2020.2\`, etc.
- Default format files may differ between versions
- Skill must detect version and handle version-specific syntax

**Backwards Compatibility:**
- Support AutoMap 2024.1+
- Handle both `.wep` and `.wrp` project file types
- Accommodate legacy folder structures

## Acceptance Criteria

### Functional Requirements

- [ ] Skill detects AutoMap installation path automatically (standard Windows locations)
- [ ] Skill executes AutoMap commands with proper parameter construction
- [ ] Skill parses AutoMap output and reports success/failure clearly
- [ ] Skill identifies `.wep` and `.wrp` project files in current directory
- [ ] Skill maps installation file paths to correct project override paths
- [ ] Skill creates parallel folder structures maintaining exact hierarchy
- [ ] Skill copies customization files (asp/scss/xsl) preserving structure
- [ ] Skill modifies copied files based on user requirements
- [ ] Skill documents customizations with comments and change tracking
- [ ] Skill handles all four file types: `*.asp`, `*.scss`, `*.xsl`

### Skill Discovery & Triggering

- [ ] Skill description includes clear trigger terms (ePublisher, AutoMap, documentation, asp/scss/xsl)
- [ ] Skill activates when user mentions "AutoMap", "ePublisher", or "generate documentation"
- [ ] Skill activates when user requests file customization for documentation output
- [ ] Skill remains inactive for unrelated coding tasks

### Documentation Requirements

- [ ] SKILL.md includes comprehensive AutoMap CLI documentation
- [ ] SKILL.md explains file resolver hierarchy with examples
- [ ] SKILL.md documents customization workflows for common scenarios
- [ ] Supporting files provide detailed reference material
- [ ] README.md explains skill installation and usage

### Quality Gates

- [ ] Skill tested with sample ePublisher project from reference repository
- [ ] Skill tested with multiple ePublisher versions (2020.1, 2024.1)
- [ ] Skill handles missing AutoMap installation gracefully
- [ ] Skill validates project structure before operations
- [ ] Skill provides clear error messages for common failure modes

## Success Metrics

### Efficiency Improvements

- **Baseline:** Manual AutoMap operation requires ~5-10 minutes (path lookup, command construction, execution, validation)
- **Target:** AI-assisted operation completes in ~2-3 minutes (simple natural language request → automated execution)
- **Measurement:** User time from request to validated output

### Adoption Indicators

- Skill usage frequency within ePublisher user community
- Positive feedback on issue complexity reduction
- Reduction in ePublisher CLI support requests
- Community contributions to skill improvements

### Quality Metrics

- AutoMap command success rate (target: >95%)
- File customization accuracy (parallel structure maintained: 100%)
- User satisfaction ratings (target: 4.5+/5)

## Dependencies & Risks

### Prerequisites

**Required Software:**
- WebWorks ePublisher 2024.1 or later installed
- AutoMap CLI component installed
- Windows operating system (ePublisher is Windows-only)
- Git for version control (optional but recommended)

**Development Dependencies:**
- Access to ePublisher installation for testing
- Sample ePublisher projects for validation
- Documentation resources (official guides, wikis)

### Technical Risks

**Risk 1: Installation Path Variations**
- **Impact:** Skill may fail to locate AutoMap executable
- **Mitigation:** Implement robust path detection with fallback prompts
- **Severity:** Medium

**Risk 2: Version-Specific CLI Changes**
- **Impact:** Commands may fail on older/newer ePublisher versions
- **Mitigation:** Version detection and version-specific command templates
- **Severity:** Low

**Risk 3: File Resolver Complexity**
- **Impact:** Incorrect override paths break customizations
- **Mitigation:** Strict validation of parallel structure requirements
- **Severity:** High (but mitigatable with thorough testing)

**Risk 4: Large Project Build Times**
- **Impact:** User may perceive skill as slow or unresponsive
- **Mitigation:** Progress indicators, output streaming, reasonable timeout settings
- **Severity:** Low

### Project Risks

**Marketplace Distribution Timeline:**
- Initial skill development: 1-2 weeks
- Testing and refinement: 1-2 weeks
- Community feedback and iteration: 2-4 weeks
- Marketplace submission preparation: 1 week

**Resource Constraints:**
- Requires ePublisher product expertise for validation
- Testing requires multiple ePublisher versions and project types
- Documentation requires understanding of target user workflows

## Implementation Phases

### Phase 1: Core Skill Foundation (Week 1)
- Create SKILL.md with basic ePublisher/AutoMap knowledge
- Implement installation path detection
- Add AutoMap command execution capability
- Test with simple project from reference repository

**Deliverables:**
- `SKILL.md` with frontmatter and core instructions
- `scripts/detect-installation.sh`
- `scripts/automap-wrapper.sh`

### Phase 2: File Customization Features (Week 2)
- Implement file resolver path mapping logic
- Add parallel structure creation
- Enable file copying with validation
- Support asp/scss/xsl file modifications

**Deliverables:**
- `scripts/copy-customization.py`
- `references/FILE_RESOLVER_GUIDE.md`
- Template files in `templates/`

### Phase 3: Testing & Refinement (Week 3)
- Test with multiple ePublisher versions
- Validate against reference projects
- Handle edge cases and error conditions
- Gather user feedback and iterate

**Deliverables:**
- Test results documentation
- Updated error handling
- Improved user guidance

### Phase 4: Distribution Preparation (Week 4)
- Create plugin structure for marketplace
- Write comprehensive README
- Add installation instructions
- Prepare submission materials

**Deliverables:**
- `.claude-plugin/plugin.json`
- Complete README.md
- LICENSE file
- Marketplace submission package

## References & Research

### Internal Project References

**Reference Projects (C:\wwepub\):**
- `webworks-claude-code-starter\CLAUDE.md:1` - Primary integration guide and workflow patterns
- `webworks-claude-code-starter\README.md:29-92` - 8-step workflow documentation
- `webworks-claude-code-starter\docs\automap-setup.md:1` - AutoMap CLI command reference
- `reverb2-both-name-logo-toolbar\CLAUDE.md:1` - Customization pattern examples
- `reverb2-both-name-logo-toolbar\Formats\WebWorks Reverb 2.0\Pages\Connect.asp:1` - ASP template example
- `reverb2-both-name-logo-toolbar\Formats\WebWorks Reverb 2.0\Pages\sass\skin.scss:1` - SCSS customization example
- `epub2628-reverb2-cache-buster\Formats\Shared\common\pages\pagetemplate.xsl:1` - XSL transform example

**Project Structure Patterns:**
- Installation: `C:\Program Files\WebWorks\ePublisher\2024.1\Formats\`
- Project customizations: `[ProjectRoot]\Formats\`
- Target-specific: `[ProjectRoot]\Targets\[TargetName]\`

### External Documentation

**Official WebWorks Resources:**
- AutoMap CLI Reference: https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.38.html
- File Override How It Works: https://static.webworks.com/docs/epublisher/latest/help/Advanced%20Customizations_%20Overrides_%20and%20Extensions/How%20It%20Works.2.10.html
- Understanding Customization: https://webworks.com/blog/post/2018/understanding-customization-in-epublisher
- Page Templates: http://wiki.webworks.com/DevCenter/Documentation/PageTemplates
- Project .wrp Structure: https://static.webworks.com/docs/epublisher/latest/help/Advanced%20Customizations_%20Overrides_%20and%20Extensions/How%20It%20Works.2.18.html
- Stationery .wep Structure: https://static.webworks.com/docs/epublisher/latest/help/Advanced%20Customizations_%20Overrides_%20and%20Extensions/How%20It%20Works.2.17.html

**Claude Code Skills Documentation:**
- Skills Reference: https://docs.claude.com/en/docs/claude-code/skills
- Plugins Reference: https://docs.claude.com/en/docs/claude-code/plugins-reference
- Agent Skills Engineering: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- System Skill Pattern: https://www.shruggingface.com/blog/the-system-skill-pattern
- Official Skills Repository: https://github.com/anthropics/skills
- How to Create Skills: https://support.claude.com/en/articles/12512198-how-to-create-custom-skills

**Community Resources:**
- Awesome Claude Skills: https://github.com/travisvn/awesome-claude-skills
- Awesome Claude Code: https://github.com/hesreallyhim/awesome-claude-code
- Obra Superpowers (20+ battle-tested skills): https://github.com/obra/superpowers

### Technical Specifications

**AutoMap Executable:**
- Default path: `C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe`
- Registry detection (preferred method):
  - 64-bit key: `HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\[VERSION]`
  - 32-bit key: `HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\[VERSION]`
  - Value: `ExePath` (full path to executable)
- Known switches: `-c` (clean), `-l` (clean deploy), `-t` (target), `--deployfolder`
- Exit codes: 0=success, non-zero=failure

**File Types:**
- Project files: `.wep` (Stationery), `.wrp` (Project), `.wxsp` (Stationery archive)
- Customization files: `.asp` (templates), `.scss` (stylesheets), `.xsl` (transforms), `.js` (Reverb javascript runtime)

**Project File Structure (XML):**

Project files contain `<Format>` elements defining each target:

```xml
<Format TargetName="WebWorks Reverb 2.0"
        Name="WebWorks Reverb 2.0"
        Type="Application"
        TargetID="CC-Reverb-Target">
  <OutputDirectory>Output\WebWorks Reverb 2.0</OutputDirectory>
  <!-- Other target configuration -->
</Format>
```

Key attributes and elements:
- `TargetName` - Target name for AutoMap `-t` parameter
- `Name` - Format name for customization paths
- `Type` - Format type (typically "Application")
- `TargetID` - Unique target identifier
- `<OutputDirectory>` (optional child element) - Custom output location
  - If present: Output generated to this directory
  - If absent: Output defaults to `Output\[TargetName]\`

**Target Detection:**
```bash
# Extract all target names from project file
grep -oP 'TargetName="\K[^"]+' project.wep

# Extract all format names
grep -oP '<Format[^>]*Name="\K[^"]+' project.wep

# Parse targets with output directory detection
./scripts/parse-targets.sh --list project.wep
./scripts/parse-targets.sh --json project.wep

# Get Base Format Version
./scripts/parse-targets.sh --version project.wep
```

**Base Format Version:**

The Base Format Version determines which ePublisher installation directory version to use when copying format files for customizations. Extract from `<Project>` element:

```xml
<Project RuntimeVersion="2024.1" FormatVersion="{Current}" ...>
```

Logic:
- If `FormatVersion="{Current}"` → Base Format Version = `RuntimeVersion`
- Otherwise → Base Format Version = `FormatVersion`

This is critical for Phase 2 customization work because format files vary between versions.

**Override Resolution Priority:**
1. Target-specific: `[Project]\Targets\[TargetName]\`
2. Format-level: `[Project]\Formats\[FormatName]\`
3. Installation: `Program Files\WebWorks\ePublisher\[Base Format Version]\Formats\`

---

**Labels:** enhancement, documentation, claude-code, skill, automap, epublisher

**Estimated Effort:** 4 weeks (1 week per phase)

**Target Milestone:** v1.0.0 - Claude Code Marketplace Distribution

Generated with Claude Code
