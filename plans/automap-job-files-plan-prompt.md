# Plan Prompt: Add AutoMap Job File Support to automap Skill

## Objective

Teach the `automap` skill to parse and work with AutoMap Job files (`.waj` extension) - a lean automation format that works with ePublisher Stationery projects and supports script execution capabilities similar to Claude Code hooks.

## Background

### What is a Job File?

AutoMap Job files (`.waj`) are XML configuration files that define automated build workflows for ePublisher. Job files reference an ePublisher Stationery project (`.wxsp`) to inherit format settings, making them lean while still containing:

- **Source documents**: Groups and documents to process
- **Target definitions**: Build targets with conditions, variables, and settings
- **Format overrides**: Per-target setting customizations
- **Script execution**: Pre/post build scripts (hook-like capability)

### Job File vs Project File Comparison

| Aspect | Project File (`.wep` or `.wrp`) | Job File (`.waj`) |
|--------|----------------------|-------------------|
| Purpose | Define complete project | Define build automation |
| References | N/A (self-contained) | Stationery (`.wxsp`) |
| Source docs | Embedded in project | Defined in job file |
| Format config | Full configuration | Inherited from Stationery |
| Per-target overrides | FormatSettings | Conditions, Variables, Settings |
| Size | Large (complete config) | Smaller (references Stationery) |
| Creation | ePublisher Designer or Express | AutoMap Administrator |
| Scripts | No | Yes (pre/post build) |

### Stationery Inheritance

The key architectural insight is that job files inherit all format configuration from the referenced Stationery project:

```
Stationery (.wxsp)          Job File (.waj)
├── Format definitions  ←── References via <Project path="...wxsp"/>
├── Style mappings          ├── Source documents (Groups/Documents)
├── Target settings         ├── Target overrides (Conditions, Variables)
└── Customizations          └── Build flags (build, cleanOutput, deployTarget)
```

This separation allows:
- **Stationery**: Maintained by format designers, contains all customizations
- **Job files**: Maintained by content authors, defines what to build

### Script Execution - The Hook-Like Capability

Job files can execute scripts at specific points in the build lifecycle:

1. **Pre-build scripts**: Run before the build starts
   - Validate prerequisites
   - Pull latest source files
   - Set environment variables
   - Check dependencies

2. **Post-build scripts**: Run after build completes
   - Deploy output files
   - Send notifications
   - Clean up temporary files
   - Trigger downstream processes

This is conceptually similar to Claude Code hooks which execute at specific points in the workflow.

**Note:** The exact script configuration syntax needs to be confirmed. The examined files did not contain script definitions, suggesting scripts may be configured separately or are optional.

## Actual Job File Structure

Based on examination of real `.waj` files:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Job name="en" version="1.0">
  <!-- Reference to Stationery project -->
  <Project path="relative\path\to\stationery.wxsp" />

  <!-- Source documents organized in groups -->
  <Files>
    <Group name="Book">
      <Document path="Source\en\topic.md" />
      <Document path="Source\en\chapter1.md" />
    </Group>
    <Group name="Reference">
      <Document path="..\shared\api-reference.md" />
    </Group>
  </Files>

  <!-- Target definitions -->
  <Targets>
    <Target name="WebWorks Reverb 2.0"
            format="WebWorks Reverb 2.0"
            formatType="Application"
            build="True"
            deployTarget=""
            cleanOutput="False">
      <!-- Per-target settings override -->
      <Settings>
        <Setting name="locale" value="en" />
      </Settings>
    </Target>
  </Targets>
</Job>
```

### Complex Target Example

Targets can include conditions, variables, and merge settings:

```xml
<Target name="Designer"
        format="WebWorks Reverb 2.0"
        formatType="Application"
        build="True"
        deployTarget="Designer Help"
        cleanOutput="False">

  <!-- Conditional content processing -->
  <Conditions Expression="" UseClassicConditions="False" UseDocumentExpression="True">
    <Condition name="OnlineOnly" value="True" Passthrough="False" UseDocumentValue="False" />
    <Condition name="PrintOnly" value="False" Passthrough="False" UseDocumentValue="False" />
    <Condition name="DesignerOnly" value="True" Passthrough="False" UseDocumentValue="False" />
  </Conditions>

  <!-- Document variables -->
  <Variables>
    <Variable name="ProductVersion" value="2025.1" UseDocumentValue="False" />
    <Variable name="PublicationDate" value="November 06, 2025" UseDocumentValue="False" />
    <Variable name="bookname" value="ePublisher Designer Guide" UseDocumentValue="False" />
  </Variables>

  <!-- PDF merge settings (for multi-group PDFs) -->
  <MergeSettings title="">
    <Group name="Welcome to ePublisher" />
    <Group name="ePublisher Interface" />
  </MergeSettings>
</Target>
```

## XML Element Reference

### Root Element: `<Job>`

| Attribute | Description | Example |
|-----------|-------------|---------|
| `name` | Job identifier | `"en"`, `"publish"` |
| `version` | Schema version | `"1.0"` |

### `<Project>` Element

| Attribute | Description | Example |
|-----------|-------------|---------|
| `path` | Relative or absolute path to Stationery | `"stationery\my.wxsp"` |

### `<Files>` / `<Group>` / `<Document>` Elements

Same structure as project files:
- `<Files>` contains `<Group>` elements
- `<Group>` has `name` attribute, contains `<Document>` elements
- `<Document>` has `path` attribute (relative paths supported)

### `<Target>` Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Target name (used for CLI `-t` parameter) |
| `format` | string | Format name from Stationery |
| `formatType` | string | Usually `"Application"` |
| `build` | boolean | `"True"` or `"False"` - whether to build this target |
| `deployTarget` | string | Deployment target name (can be empty) |
| `cleanOutput` | boolean | Clean output before build |

### `<Conditions>` Element

Controls conditional content processing:

| Attribute | Description |
|-----------|-------------|
| `Expression` | Condition expression (if using expressions) |
| `UseClassicConditions` | Use legacy condition syntax |
| `UseDocumentExpression` | Inherit from document |

Child `<Condition>` elements:
| Attribute | Description |
|-----------|-------------|
| `name` | Condition name |
| `value` | `"True"` or `"False"` |
| `Passthrough` | Pass through to output unchanged |
| `UseDocumentValue` | Use value from source document |

### `<Variables>` Element

Defines document variable overrides:

| Attribute | Description |
|-----------|-------------|
| `name` | Variable name |
| `value` | Variable value |
| `UseDocumentValue` | Use value from source document |

### `<Settings>` Element

Per-target format setting overrides:

```xml
<Settings>
  <Setting name="locale" value="en" />
</Settings>
```

### `<MergeSettings>` Element

Controls PDF merging for multi-group outputs:

| Attribute | Description |
|-----------|-------------|
| `title` | Merged document title |

Contains `<Group name="..."/>` elements defining merge order.

## Research Tasks

### Reference Documentation

- **AutoMap Overview**: https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.01.html
- **AutoMap Scripts**: https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.28.html

Use WebFetch to extract details from these documentation pages during plan execution.

### Items to Investigate

1. **Script execution syntax**
   - The examined files did not contain script definitions
   - Fetch script configuration details from the Scripts documentation link above
   - Document the script elements once syntax is confirmed

2. **Script execution semantics**
   - What working directory are scripts executed from?
   - What environment variables are available?
   - How is script output captured?
   - What happens on script failure?

3. **CLI support for job files**
   - Does `WebWorks.Automap.exe` accept `.waj` files directly?
   - Or is there a separate job execution mechanism?

4. **Relationship to scheduling**
   - Are schedules stored in the job file?
   - Or are they Windows Task Scheduler entries that reference job files?

## Skill Enhancement Requirements

### New Reference File

Create `references/job-file-guide.md`:

- Job file structure (XML schema) - use actual examples from this prompt
- Element and attribute reference table
- Stationery inheritance explanation
- Script execution lifecycle (once syntax is confirmed)
- Examples:
  - Simple job (single target, few documents)
  - Multi-target job with conditions and variables
  - Localized job using Settings overrides
- Comparison with project files

### SKILL.md Updates

1. Add `.waj` to supported file types in overview
2. Document Stationery relationship
3. Add job file section to Quick Start
4. Update CLI reference for job file usage
5. Add troubleshooting for job-specific errors:
   - "Stationery not found"
   - "Invalid target format"
   - "Condition processing errors"

### New/Updated Scripts

| Script | Purpose |
|--------|---------|
| `parse-job.py` | Extract job configuration from `.waj` files |
| `validate-job.py` | Validate job file structure and Stationery reference |
| `list-job-targets.py` | List targets with build status and conditions |

### Wrapper Script Updates

Update `automap-wrapper.sh` to:
- Detect if input is `.waj` vs `.wep`
- Resolve Stationery path for validation
- Handle job-specific command-line options
- Filter targets by `build="True"` attribute

## Considerations

### Stationery Resolution

Job files reference Stationery with relative paths. The skill should:
- Resolve relative paths from job file location
- Validate Stationery exists before build
- Report clear errors when Stationery is missing

### Build Flag Filtering

The `build="True|False"` attribute on targets allows selective building:
- Default behavior: Only build targets with `build="True"`
- CLI override: Allow building specific targets regardless of flag
- Batch mode: Build all enabled targets in sequence

### Conditions and Variables

Job files can override conditions and variables per-target:
- Useful for single-source publishing (online vs print)
- Product-specific outputs (Designer vs Express edition)
- Localization (different variable values per locale)

### Script Security (Once Confirmed)

If job files can execute arbitrary scripts:
- Should the skill warn about script execution?
- Should script paths be validated?
- What guidance for safe script practices?

### Hook Pattern Documentation

If scripts behave like hooks, document the pattern:

```
Pre-build hooks → Build process → Post-build hooks
      ↓                ↓                ↓
   Validate       Generate          Deploy
```

### Cross-Platform Concerns

- Job files use Windows-style backslash paths
- Relative paths like `..\shared\` need proper resolution
- Git Bash path translation may be needed

## Out of Scope

- Creating jobs programmatically (use AutoMap Administrator)
- Schedule management (Windows Task Scheduler domain)
- Script authoring (general shell/PowerShell knowledge)
- Interactive job testing (use AutoMap Administrator)
- Stationery creation/editing (use ePublisher Designer)

## Success Criteria

After implementation:

- [ ] Job file structure fully documented with real examples
- [ ] Stationery inheritance clearly explained
- [ ] `parse-job.py` extracts all job configuration (name, stationery, files, targets)
- [ ] `validate-job.py` checks structure and Stationery reference exists
- [ ] `list-job-targets.py` shows targets with build status
- [ ] SKILL.md updated with job file content
- [ ] Wrapper script handles `.waj` files
- [ ] Troubleshooting covers common job file issues

## Execution Approach

1. **Documentation phase**: Write `job-file-guide.md` using examples from this prompt
2. **Script phase**: Create Python parsing scripts
3. **Integration phase**: Update SKILL.md and wrapper script
4. **Testing phase**: Validate with real job files from:
   - `C:\wwepub\reverb2-header-dropdown\automap-en.waj`
   - `C:\Projects\epublisher-docs\automap-jobs\*.waj`
5. **Script research**: If script execution is needed, create a job with scripts and document the syntax

## Sample Job Files for Testing

| File | Purpose |
|------|---------|
| `C:\wwepub\reverb2-header-dropdown\automap-en.waj` | Simple: single target, few documents, Settings override |
| `C:\Projects\epublisher-docs\automap-jobs\publish-help-designer.waj` | Complex: multiple targets, conditions, variables, merge settings |

---

## Instructions for Plan Execution

When executing this prompt to create the implementation plan:

1. **Use provided examples**: The actual XML structure is documented above
2. **Ask about scripts**: If script execution is a priority, request a sample job with scripts
3. **Create phased plan**: Break into manageable phases with clear deliverables
4. **Consider dependencies**: SKILL.md updates depend on reference documentation
5. **Include validation steps**: Each phase should have verification criteria
