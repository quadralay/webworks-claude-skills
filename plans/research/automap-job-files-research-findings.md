# WebWorks ePublisher AutoMap Job File Research Findings

**Research Date**: 2025-12-05
**Purpose**: Gather comprehensive documentation for adding job file support to the automap skill

---

## Summary

WebWorks ePublisher AutoMap Job files (.waj) are XML-based automation configurations that reference Stationery projects and support script execution at various build lifecycle points. Job files provide a lean automation layer by inheriting format settings from Stationery while defining source documents, target configurations, and build scripts.

---

## 1. Version Information

**Current Product**: WebWorks ePublisher 2024.1+
**AutoMap Component**: WebWorks.Automap.exe (CLI automation tool)
**File Formats**:
- `.waj` - AutoMap Job files
- `.wxsp` - Stationery project files (referenced by job files)
- `.wep` - ePublisher Designer project files
- `.wrp` - ePublisher Express project files

---

## 2. Key Concepts

### What is a Job File?

AutoMap Job files (`.waj`) are XML configuration files that define automated build workflows for ePublisher. Unlike full project files, job files are lean because they:

1. **Reference Stationery**: Inherit all format configuration from a Stationery project (.wxsp)
2. **Define Sources**: Specify which documents to process and their organization
3. **Configure Targets**: Define which outputs to build with optional overrides
4. **Execute Scripts**: Run pre/post build scripts for automation integration

### Stationery Inheritance

```
Stationery (.wxsp)          Job File (.waj)
├── Format definitions  ←── References via <Project path="...wxsp"/>
├── Style mappings          ├── Source documents (Groups/Documents)
├── Target settings         ├── Target overrides (Conditions, Variables)
└── Customizations          └── Build flags (build, cleanOutput, deployTarget)
```

This separation enables:
- **Stationery**: Maintained by format designers, contains all customizations
- **Job files**: Maintained by content authors, defines what to build

---

## 3. Job File Structure

### Basic Structure

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

### Complex Target with Conditions and Variables

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

---

## 4. XML Element Reference

### Root Element: `<Job>`

| Attribute | Type | Description | Example |
|-----------|------|-------------|---------|
| `name` | string | Job identifier | `"en"`, `"publish"` |
| `version` | string | Schema version | `"1.0"` |

### `<Project>` Element

References the Stationery project that provides format configuration.

| Attribute | Type | Description | Example |
|-----------|------|-------------|---------|
| `path` | string | Relative or absolute path to Stationery | `"stationery\my.wxsp"` |

**Note**: Paths are typically relative to the job file location.

### `<Files>` / `<Group>` / `<Document>` Elements

Same structure as project files:
- `<Files>` - Container for all document groups
- `<Group name="...">` - Logical grouping of documents
- `<Document path="..."/>` - Individual source document reference

**Path Resolution**: Document paths are relative to the job file location unless absolute.

### `<Target>` Element

Defines a build target with optional overrides.

| Attribute | Type | Description | Values |
|-----------|------|-------------|--------|
| `name` | string | Target name (used for CLI `-t` parameter) | Any string |
| `format` | string | Format name from Stationery | "WebWorks Reverb 2.0", etc. |
| `formatType` | string | Format type | Usually `"Application"` |
| `build` | boolean | Whether to build this target | `"True"` or `"False"` |
| `deployTarget` | string | Deployment target name | Empty or target name |
| `cleanOutput` | boolean | Clean output before build | `"True"` or `"False"` |

### `<Conditions>` Element

Controls conditional content processing for single-source publishing.

**Container Attributes**:
| Attribute | Description |
|-----------|-------------|
| `Expression` | Condition expression (if using expressions) |
| `UseClassicConditions` | Use legacy condition syntax |
| `UseDocumentExpression` | Inherit from document |

**Child `<Condition>` Elements**:
| Attribute | Description |
|-----------|-------------|
| `name` | Condition name |
| `value` | `"True"` or `"False"` |
| `Passthrough` | Pass through to output unchanged |
| `UseDocumentValue` | Use value from source document |

### `<Variables>` Element

Defines document variable overrides for this target.

| Attribute | Description |
|-----------|-------------|
| `name` | Variable name |
| `value` | Variable value |
| `UseDocumentValue` | Use value from source document instead |

### `<Settings>` Element

Per-target format setting overrides.

```xml
<Settings>
  <Setting name="locale" value="en" />
  <Setting name="custom-property" value="value" />
</Settings>
```

### `<MergeSettings>` Element

Controls PDF merging for multi-group outputs.

| Attribute | Description |
|-----------|-------------|
| `title` | Merged document title |

Contains `<Group name="..."/>` elements defining merge order.

---

## 5. Script Configuration

### Script Capabilities

AutoMap provides scripting capabilities for automation integration:
- **Pre-build scripts**: Run before the build starts
- **Post-build scripts**: Run after build completes
- **Per-target scripts**: Execute for specific targets
- **Document retrieval scripts**: Fetch sources from version control

### Script Execution Context

**Working Directory**:
- During generation: Current working directory is set to the job file's directory
- Scripts execute from the job folder itself (referenced as `${JobDir}`)

**Available Variables** (accessible via `${VariableName}`):

**Job-Level Variables** (available in all script types):
| Variable | Description |
|----------|-------------|
| `JobDir` | Path of the job `.waj` file directory |
| `JobFile` | Name of the job `.waj` file |
| `JobName` | Name of the job |
| `ProjectDir` | Path to the temporary project file created by AutoMap |
| `ProjectFile` | Name of the temporary project file |
| `BuildAction` | Indicates whether processing is pre-build or post-build |

**Target-Level Variables** (available in target scripts only):
| Variable | Description |
|----------|-------------|
| `TargetName` | Name of the target being generated |
| `TargetOutputDir` | Output path of the target |
| `TargetDeployKey` | Deployment target name |
| `DeployFolder` | Deployment directory path |
| `ErrorCount` | Number of errors reported during generation |

**Document Script Variables** (available in document retrieval scripts):
| Variable | Description |
|----------|-------------|
| `GroupName` | Name of the documents group being processed |
| `FileListName` | Name of the file containing the list of source documents |
| `FileListPath` | Path of the file containing the list of source documents |

### Script Editor

AutoMap has a built-in script editor that:
- Accepts text-based scripts only (formatting is lost)
- Saves entered text into a batch file and executes it
- Works similarly to DOS batch files
- Requires complete and valid syntax (fails on errors)

**Best Practice**: Create complex scripts separately and call them from the AutoMap editor:
```batch
REM Call external script with parameters
call C:\scripts\pre-build.bat "${JobDir}" "${TargetName}"
```

### Script Examples

**Show Time and Date** (Pre-build script):
```batch
@echo off
time /t
date /t
```

**Using Scripting Variables** (generates diagnostic report):
```batch
@echo off
echo Target: ${TargetName}
echo Job: ${JobName} (${JobFile})
echo Script Phase: ${BuildAction}
echo Deploy to: ${DeployFolder}
echo Errors: ${ErrorCount}
```

### Script Return Handling

**Document Retrieval Scripts**:
- If script returns successfully, AutoMap looks for a text file at `${FileListPath}`
- File should contain line-delimited list of documents to add to the group
- Script failure stops the build process

**Pre/Post Build Scripts**:
- Script failure typically stops the build
- Exit code 0 indicates success
- Non-zero exit codes indicate failure

### Variable Availability Timeline

**During Job Creation** (in Job Editor):
- `JobDir` and `JobFile` are NOT available (job not saved yet)
- `ProjectDir` and `ProjectFile` are NOT available (project doesn't exist)
- Current working directory: Job file's directory

**During Generation** (build execution):
- ALL variables are available
- Current working directory: Job file's directory
- Variables resolved at execution time

---

## 6. Command-Line Interface

### Basic Command Pattern

```bash
"[AutoMap-Path]" "[Job-File]" [Options]
```

**Components**:
- `[AutoMap-Path]`: Full path to `WebWorks.Automap.exe`
- `[Job-File]`: Full path to `.waj` job file
- `[Options]`: Build configuration flags and parameters

**Default Installation Path**:
```
C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe
```

**Important**: WebWorks.Automap.exe depends on other files in its folder. Do not move or copy it.

### Command-Line Switches

**User Formats Directory**:
```bash
-u, --userformats "[Path]"
```
Specifies the user format directory location.

**Note**: The documentation indicates "There are different command-line switches that are valid when processing a WebWorks AutoMap job file versus a WebWorks ePublisher Designer project," but specific job file switches require further research from the official CLI reference.

### Command Examples

**Basic Job Execution**:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" "C:\projects\my-proj\automap-en.waj"
```

**With User Formats**:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -u "C:\MyFormats" "C:\projects\my-proj\automap-en.waj"
```

### Exit Codes

- `0` - Success
- Non-zero - Failure (specific codes vary)

---

## 7. Best Practices

### Script Development

1. **Develop scripts separately**: Create scripts in external files and call them from AutoMap
2. **Use absolute paths**: Avoid ambiguity in script file references
3. **Test scripts standalone**: Verify scripts work before integration
4. **Handle errors explicitly**: Check exit codes and provide clear error messages
5. **Log script output**: Capture script execution details for troubleshooting

### Variable Usage

1. **Verify variable scope**: Ensure variables are available in your script type
2. **Quote paths**: Use quotes around variables that may contain spaces: `"${DeployFolder}"`
3. **Validate availability**: Check variables exist before using them
4. **Document dependencies**: Note which variables your scripts require

### Path Handling

1. **Use relative paths for portability**: Makes job files relocatable
2. **Resolve relative paths from job location**: All paths are relative to `.waj` file
3. **Handle Windows path separators**: Use backslashes in XML, convert in bash if needed
4. **Validate Stationery path**: Ensure referenced Stationery exists before build

### Build Configuration

1. **Use `build="False"` for conditional targets**: Disable targets without removing them
2. **Override deployment per target**: Use `deployTarget` for target-specific deployment
3. **Group related documents**: Organize sources logically for maintainability
4. **Document conditions and variables**: Comment or document target-specific overrides

---

## 8. Common Issues and Solutions

### Issue: Stationery Not Found

**Symptom**: Build fails with "Cannot find Stationery project"

**Causes**:
- Incorrect relative path in `<Project path="..."/>`
- Stationery moved or deleted
- Job file moved without updating Stationery reference

**Solutions**:
1. Verify Stationery path is correct relative to job file
2. Use absolute path as temporary workaround
3. Update job file if Stationery location changed

### Issue: Script Variables Not Available

**Symptom**: Script references `${VariableName}` but value is empty

**Causes**:
- Variable not available in current script context
- Job not saved yet (creation vs generation)
- Typo in variable name

**Solutions**:
1. Verify variable scope (job/target/document level)
2. Check variable name spelling
3. Ensure script runs during generation, not creation

### Issue: Script Execution Fails

**Symptom**: Build stops with script error

**Causes**:
- Script syntax error
- Missing external dependencies
- Path resolution issues
- Permission denied

**Solutions**:
1. Test script standalone with sample variables
2. Check all external tool paths
3. Verify file permissions
4. Use absolute paths for external tools

### Issue: Document Retrieval Script Doesn't Add Files

**Symptom**: Document group empty after script executes

**Causes**:
- Script didn't create file at `${FileListPath}`
- File format incorrect (not line-delimited)
- Script returned non-zero exit code

**Solutions**:
1. Verify script creates file at exact path
2. Ensure one file path per line
3. Check script exit code (should be 0)
4. Test file list format manually

---

## 9. Job File vs Project File Comparison

| Aspect | Project File (`.wep`/`.wrp`) | Job File (`.waj`) |
|--------|------------------------------|-------------------|
| **Purpose** | Define complete project | Define build automation |
| **References** | Self-contained | References Stationery (`.wxsp`) |
| **Source docs** | Embedded in project | Defined in job file |
| **Format config** | Full configuration | Inherited from Stationery |
| **Per-target overrides** | FormatSettings only | Conditions, Variables, Settings |
| **Size** | Large (complete config) | Smaller (references Stationery) |
| **Creation tool** | ePublisher Designer or Express | AutoMap Administrator |
| **Script support** | No | Yes (pre/post build) |
| **Scheduling** | No | Yes (Windows Task Scheduler) |
| **CLI execution** | WebWorks.Automap.exe | WebWorks.Automap.exe (same tool) |

---

## 10. Integration Patterns

### Version Control Integration

Job files can include scripts to retrieve source documents from version control:

```batch
@echo off
REM Pre-build script: Update from Git
cd "${JobDir}"
git pull origin main
if errorlevel 1 exit /b 1
```

### Build Server Integration

Job files are ideal for CI/CD pipelines:

1. **Pre-build**: Validate prerequisites, pull sources
2. **Build**: Generate all targets with `build="True"`
3. **Post-build**: Deploy outputs, send notifications

### Multi-Locale Publishing

Use separate job files per locale, all referencing same Stationery:

```
automap-en.waj  →  stationery.wxsp
automap-de.waj  →  stationery.wxsp
automap-fr.waj  →  stationery.wxsp
```

Each job file:
- References different source document folders
- Overrides locale setting per target
- Uses same format configuration from Stationery

---

## 11. Skill Enhancement Requirements

### New Reference Documentation

**Create**: `references/job-file-guide.md`

Content:
- Job file structure (XML schema with examples)
- Element and attribute reference tables
- Stationery inheritance explanation
- Script execution lifecycle and variables
- Path resolution rules
- Examples (simple, multi-target, localized)
- Comparison with project files
- Troubleshooting guide

### SKILL.md Updates

1. Add `.waj` to supported file types
2. Document Stationery relationship
3. Add job file section to Quick Start
4. Update CLI reference for job file execution
5. Add job-specific troubleshooting

### New Python Scripts

| Script | Purpose |
|--------|---------|
| `parse-job.py` | Extract job configuration from `.waj` files |
| `validate-job.py` | Validate job structure and Stationery reference |
| `list-job-targets.py` | List targets with build status, conditions, variables |

### Wrapper Script Updates

Update `automap-wrapper.sh`:
- Detect if input is `.waj` vs `.wep`
- Resolve Stationery path for validation
- Handle job-specific CLI options
- Filter targets by `build="True"` attribute
- Report script execution context

---

## 12. Research Gaps and Follow-Up

### Items Requiring Further Investigation

1. **Complete CLI Reference for Job Files**
   - Full list of command-line switches specific to `.waj` files
   - Differences from project file CLI options
   - Official CLI Syntax and Reference section

2. **Script XML Schema**
   - Exact XML element structure for scripts in job files
   - Where scripts are defined in the XML hierarchy
   - Script type attribute values
   - None of the examined real-world `.waj` files contained script definitions

3. **Schedule Integration**
   - How Windows Task Scheduler references job files
   - Schedule storage (in job file or external)
   - Best practices for scheduled jobs

4. **Error Handling Details**
   - Specific error codes from WebWorks.Automap.exe
   - Script failure recovery mechanisms
   - Partial build handling

### Recommended Research Approach

1. **Create Sample Job with Scripts**: Use AutoMap Administrator to create a job with pre/post build scripts, then examine the XML
2. **Test CLI Options**: Execute job files with various CLI switches to document behavior
3. **Contact WebWorks Support**: Request official XML schema documentation for `.waj` format
4. **Examine AutoMap Administrator**: Reverse-engineer UI to understand all available options

---

## 13. Sources and References

### Official Documentation

- [Using Scripting Variables Example](https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.35.html) - Demonstrates variable usage in AutoMap scripts
- [WebWorks ePublisher: AutoMap Product Page](https://webworks.com/products/epublisher/automap) - Overview of AutoMap capabilities
- [WebWorks ePublisher – Automap 9.0 FAQ](https://www.webworks.com/Support/ePublisher/Legacy_Docs/Tech_Notes/Common/EX_AM9_0_FAQ.shtml) - Legacy FAQ with technical details
- [HelpCenter/FAQ - WebWorks Wiki](http://wiki.webworks.com/HelpCenter/FAQ) - Community knowledge base

### Documentation Attempted (Access Issues)

- AutoMap Overview: `https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.01.html` - Navigation hub only
- AutoMap Scripts: `https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.28.html` - Navigation hub only
- CLI Reference: `https://static.webworks.com/docs/epublisher/latest/help/ePublisher%20Interface/Automating%20Projects.4.38.html` - 404 error

**Note**: Many documentation pages are navigation hubs rather than detailed technical references. Actual content is in subsections that experienced access issues during research.

### Internal Documentation

- `C:\wwepub\webworks-agent-skills\plugins\epublisher-automation\skills\automap\references\cli-reference.md` - Existing CLI reference (project files)
- `C:\wwepub\webworks-agent-skills\plans\automap-job-files-plan-prompt.md` - Original plan with job file examples

### Real-World Examples

**Simple Job Files**:
- `C:\wwepub\reverb2-header-dropdown\automap-en.waj` (and de, es, fr, it variants)

**Complex Job Files**:
- `C:\Projects\epublisher-docs\automap-jobs\publish-help-designer.waj`
- `C:\Projects\epublisher-docs\automap-jobs\publish-help-automap.waj`
- `C:\Projects\epublisher-docs\automap-jobs\publish-help-express.waj`

---

## 14. Implementation Roadmap

### Phase 1: Documentation

1. Create `references/job-file-guide.md` with structure and examples
2. Document XML elements and attributes
3. Explain Stationery inheritance model
4. Include script execution lifecycle (based on current findings)

### Phase 2: Python Scripts

1. Implement `parse-job.py`:
   - Extract job name, Stationery reference
   - List document groups and files
   - List targets with attributes
   - Extract conditions, variables, settings per target

2. Implement `validate-job.py`:
   - Check XML structure
   - Verify Stationery path exists
   - Validate document paths
   - Check target configuration completeness

3. Implement `list-job-targets.py`:
   - Display targets with build status
   - Show conditions and variables
   - Highlight overrides
   - Format for human readability

### Phase 3: Integration

1. Update `SKILL.md`:
   - Add job file section to overview
   - Document `.waj` support in Quick Start
   - Add job file troubleshooting

2. Update `automap-wrapper.sh`:
   - Detect `.waj` vs `.wep` input
   - Resolve and validate Stationery reference
   - Filter targets by `build="True"`
   - Support job-specific CLI options

3. Update `cli-reference.md`:
   - Add job file CLI patterns
   - Document differences from project files
   - Include job file examples

### Phase 4: Testing and Validation

1. Test with simple job files (locale variants)
2. Test with complex job files (conditions, variables)
3. Verify Stationery resolution
4. Test script variable documentation
5. Validate CLI execution

### Phase 5: Script Research (Optional)

1. Create sample job with scripts in AutoMap Administrator
2. Document exact XML structure
3. Test script execution and variable availability
4. Update documentation with findings

---

## 15. Success Criteria

- [ ] Job file XML structure fully documented with real examples
- [ ] Stationery inheritance clearly explained
- [ ] Script execution lifecycle documented (variables, working directory, error handling)
- [ ] `parse-job.py` extracts all job configuration
- [ ] `validate-job.py` checks structure and Stationery reference
- [ ] `list-job-targets.py` shows targets with build status
- [ ] SKILL.md updated with comprehensive job file content
- [ ] `automap-wrapper.sh` handles `.waj` files correctly
- [ ] `cli-reference.md` includes job file CLI patterns
- [ ] Troubleshooting covers common job file issues
- [ ] All changes tested with real job files

---

**End of Research Findings**
