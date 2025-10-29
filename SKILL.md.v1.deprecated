---
name: epublisher-automap
description: WebWorks ePublisher AutoMap CLI integration for generating documentation output and customizing project files (asp/scss/xsl templates). Use when working with ePublisher projects, running AutoMap builds, copying customization files from installation to project directories, or modifying format templates for Reverb or other HTML5 outputs.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# WebWorks ePublisher AutoMap Integration

## Purpose

Automate WebWorks ePublisher AutoMap operations for building documentation and customizing output formats through CLI integration and file manipulation workflows.

## AutoMap CLI Operations

### Detecting AutoMap Installation

Locate AutoMap executable using Windows Registry (preferred method):

**64-bit Installation Registry Path:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\[VERSION]
```

**32-bit Installation Registry Path:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\[VERSION]
```

**Registry Key:** `ExePath` contains full path to the executable

**Detection Steps:**
1. Query registry for ePublisher AutoMap versions (both 64-bit and 32-bit paths)
2. Enumerate available versions and select the latest
3. Read `ExePath` value for the executable location
4. Validate the file exists at the specified path
5. Cache the path for session duration

**Fallback Method (if registry unavailable):**
- Check standard installation path: `C:\Program Files\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`
- Check 32-bit path: `C:\Program Files (x86)\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`
- Enumerate version directories and find the latest

**PowerShell Registry Query Example:**
```powershell
$path = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WebWorks\ePublisher AutoMap\2024.1").ExePath
```

**Bash/reg Command Example:**
```bash
reg query "HKLM\SOFTWARE\WebWorks\ePublisher AutoMap\2024.1" /v ExePath
```

For detailed implementation guidance, see `references/AUTOMAP_INSTALLATION_DETECTION.md`.

### Executing AutoMap Commands

**Basic Command Pattern:**
```bash
"[AutoMap-Path]" "[Project-File]" [Options]
```

**Common Command Options:**
- `-c, --clean`: Clean build (remove cached files before generation)
- `-l, --cleandeploy`: Clean deployment location before copying output
- `-t, --target "[TargetName]"`: Build specific target only (e.g., "WebWorks Reverb 2.0")
- `--deployfolder "[Path]"`: Override deployment destination

**Example Commands:**

Build all targets with clean:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l "C:\Projects\MyDoc\MyDoc.wep"
```

Build specific target:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l -t "WebWorks Reverb 2.0" "C:\Projects\MyDoc\MyDoc.wep"
```

Build with custom deployment:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l --deployfolder "C:\Output" "C:\Projects\MyDoc\MyDoc.wep"
```

**Execution Guidelines:**
1. Always use absolute paths for both executable and project files
2. Quote paths containing spaces
3. Set Bash tool timeout to 600000ms (10 minutes) for large projects
4. Capture both stdout and stderr for diagnostics
5. Check exit code: 0=success, non-zero=failure
6. Parse output for error messages and warnings

### Parsing AutoMap Output

Monitor console output for:
- **Success indicators:** "Generation completed successfully", "Output deployed to"
- **Error patterns:** "Error:", "Failed to", "Unable to", "Exception"
- **Warning patterns:** "Warning:", "Could not find"
- **Progress indicators:** "Processing", "Generating", "Transforming"

Report to user:
- Clear success/failure status
- Error messages with context
- Deployment location for successful builds
- Build duration and statistics

### Error Handling

**Common AutoMap Errors:**

**Error 1: Project file not found**
- Symptom: "Could not load project file"
- Solution: Verify project file path and existence

**Error 2: Source documents missing**
- Symptom: "Source document not found"
- Solution: Check project file references and source file locations

**Error 3: Target configuration invalid**
- Symptom: "Invalid target configuration"
- Solution: Review target settings in project file

**Error 4: Insufficient disk space**
- Symptom: "Unable to write output", "Disk full"
- Solution: Check available disk space in deployment location

**Error 5: Permission denied**
- Symptom: "Access denied", "Permission error"
- Solution: Verify write permissions on deployment folder

## ePublisher Project Structure

### Project File Types

**`.wep` (Designer Project / Stationery):**
- Precursor to Stationery format
- Contains format configurations and settings
- Located in project root directory

**`.wxsp` (Stationery Project):**
- Stationery project with no source documents
- Deep copy of all applicable installation XSL files
- Self-contained format definitions

**`.wrp` (Project):**
- Full project file (deep copy)
- Contains source document references
- Target configurations and deployment settings

### Project Recognition

Identify ePublisher projects by:
1. Presence of `.wep`, `.wrp`, or `.wxsp` files in directory
2. `Formats/` directory containing format-specific customizations
3. `Targets/` directory with target-specific overrides
4. `Source/` directory with input documents

**Project Detection:**
```bash
# Find project files
find . -maxdepth 1 -name "*.wep" -o -name "*.wrp" -o -name "*.wxsp"

# Verify project structure
ls -la Formats/ Targets/ Source/
```

### Determining Base Format Version

The Base Format Version determines which version of format files (templates, stylesheets, transforms) to use when creating customizations. This is critical because different format versions may have incompatible file structures.

**Project Root Element Structure:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project Version="1.1.2.0"
         ProjectID="W8CC-Starter-001"
         ChangeID="CC-Initial-Setup"
         RuntimeVersion="2024.1"
         FormatVersion="{Current}"
         xmlns="urn:WebWorks-Publish-Project">
  <!-- Project content -->
</Project>
```

**Key Attributes:**

- `Version` - Project file schema version (e.g., "1.1.2.0")
- `ProjectID` - Unique identifier for the project
- `RuntimeVersion` - ePublisher version used to last save project (e.g., "2024.1")
- `FormatVersion` - Format version override (typically "{Current}" or specific version)
- `ChangeID` - Incremental build tracking (can be ignored)

**Base Format Version Logic:**

```
IF FormatVersion == "{Current}" THEN
    Base Format Version = RuntimeVersion
ELSE
    Base Format Version = FormatVersion
END IF
```

**Examples:**

Example 1 - Current format (most common):
```xml
<Project RuntimeVersion="2024.1" FormatVersion="{Current}" ...>
```
Base Format Version = `2024.1` (uses current runtime version)

Example 2 - Locked to older format:
```xml
<Project RuntimeVersion="2024.1" FormatVersion="2020.2" ...>
```
Base Format Version = `2020.2` (uses older format for compatibility)

**Extracting Version Information:**

```bash
# Get RuntimeVersion
grep -oP '<Project[^>]*RuntimeVersion="\K[^"]+' project.wep

# Get FormatVersion
grep -oP '<Project[^>]*FormatVersion="\K[^"]+' project.wep

# Determine Base Format Version (bash logic)
runtime=$(grep -oP '<Project[^>]*RuntimeVersion="\K[^"]+' project.wep)
format=$(grep -oP '<Project[^>]*FormatVersion="\K[^"]+' project.wep)
if [ "$format" = "{Current}" ]; then
    base_format_version="$runtime"
else
    base_format_version="$format"
fi
echo "Base Format Version: $base_format_version"
```

**Why This Matters for Customization:**

When copying format files from the installation directory to create customizations, you must use files from the correct format version:

**Correct approach:**
```bash
# For project with Base Format Version = 2020.2
source_path="C:\Program Files\WebWorks\ePublisher\2020.2\Formats\WebWorks Reverb 2.0\..."

# For project with Base Format Version = 2024.1
source_path="C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\..."
```

**Important Notes:**
- Always check Base Format Version before creating customizations
- Mixing format versions can cause build errors or unexpected output
- Older projects may intentionally use older formats for stability
- When upgrading a project, consider whether to update FormatVersion to {Current}

### Parsing Project Files for Targets

Project files (`.wep`, `.wrp`) are XML files containing target and format configuration.

**Target/Format Element Structure:**

Project files contain `<Format>` elements that define each target:

```xml
<Format TargetName="WebWorks Reverb 2.0"
        Name="WebWorks Reverb 2.0"
        Type="Application"
        TargetID="CC-Reverb-Target">
  <!-- Target configuration -->
</Format>
```

**Key Attributes:**
- `TargetName` - The target name used in AutoMap `-t` parameter (e.g., "WebWorks Reverb 2.0")
- `Name` - The format name used for customization paths (e.g., "WebWorks Reverb 2.0")
- `Type` - Format type (typically "Application")
- `TargetID` - Unique identifier for this target in the project

**Extracting Target Information:**

```bash
# List all target names in a project
grep -oP 'TargetName="\K[^"]+' project.wep

# List all format names
grep -oP '<Format[^>]*Name="\K[^"]+' project.wep

# Get full Format elements
grep '<Format ' project.wep
```

**Example Project File Targets:**

```xml
<!-- HTML5 (Reverb) Output with Default Output Location -->
<Format TargetName="WebWorks Reverb 2.0"
        Name="WebWorks Reverb 2.0"
        Type="Application"
        TargetID="Reverb-Target">
</Format>

<!-- PDF Output with Custom Output Directory -->
<Format TargetName="PDF - XSL-FO"
        Name="PDF - XSL-FO"
        Type="Application"
        TargetID="PDF-Target">
  <OutputDirectory>C:\CustomOutput\PDF</OutputDirectory>
</Format>
```

**Key Attributes and Elements:**

- **TargetName** - Target identifier for AutoMap `-t` parameter
- **Name** - Format name for customization path construction (`Formats\[Name]\`)
- **Type** - Format type (typically "Application")
- **TargetID** - Unique identifier for the target
- **OutputDirectory** (optional child element) - Custom output location
  - If present: Output generated to this directory
  - If absent: Output defaults to `Output\[TargetName]\`
  - Can be absolute path (e.g., `C:\CustomOutput\PDF`) or relative to project

**Use Cases:**

1. **List Available Targets:**
   Parse project file to show user all configured targets

2. **Validate Target Name:**
   Before executing AutoMap, confirm target exists in project

3. **Determine Format for Customization:**
   Use `Name` attribute to construct correct customization paths:
   - `Formats\[Name]\...`
   - `Targets\[TargetName]\...`

4. **Find Generated Output:**
   Check for `<OutputDirectory>` child element to determine where output was generated:
   - If `<OutputDirectory>` exists: Use that path
   - Otherwise: Default to `Output\[TargetName]\`

5. **Batch Processing:**
   Extract all target names for building multiple targets sequentially

### Managing Source Files in Projects

Project files contain source document references organized in a hierarchical structure: `<Groups>` → `<Group>` → `<Document>`.

**Source File Structure:**

```xml
<Groups>
  <Group Name="Group1" Type="normal" Included="true" GroupID="w3KcSrHh-HI">
    <Document Path="Source\content-seed.md" Type="fm-maker" Included="true" DocumentID="abc123xyz" />
    <Document Path="Source\getting-started.md" Type="fm-maker" Included="true" DocumentID="def456uvw" />
  </Group>
  <Group Name="Reference" Type="normal" Included="true" GroupID="xYz987aBc">
    <Document Path="Source\api-reference.md" Type="fm-maker" Included="true" DocumentID="ghi789rst" />
  </Group>
</Groups>
```

**Key Attributes:**

**Group Element:**
- `Name` - Display name for the group
- `Type` - Group type (typically "normal")
- `Included` - Boolean ("true"/"false") to include/exclude group from generation
- `GroupID` - Unique identifier for the group (required, auto-generated)
- `ChangeID` - Incremental build tracking (can be ignored, not needed for AutoMap)

**Document Element:**
- `Path` - **Most Important** - Path to source file (relative to project or absolute)
  - Relative: `Source\content-seed.md`
  - Absolute: `C:\Docs\content-seed.md`
- `Type` - Document type (e.g., "fm-maker" for Markdown, "fm-html" for HTML)
- `Included` - Boolean ("true"/"false") to include/exclude from generation
- `DocumentID` - Unique identifier for the document (required, auto-generated)
- `ChangeID` - Incremental build tracking (can be ignored)

**Common Operations:**

**1. List All Source Files:**
```bash
# Extract all document paths
grep -oP 'Document Path="\K[^"]+' project.wep

# Show document paths with inclusion status
grep '<Document ' project.wep | grep -oP 'Path="\K[^"]+|Included="\K[^"]+'
```

**2. Check If Document Included:**
```bash
# Find specific document and check Included status
grep 'Path="Source\\content-seed.md"' project.wep | grep -oP 'Included="\K[^"]+'
```

**3. Add New Document to Project:**
- Generate unique DocumentID (e.g., using random alphanumeric string)
- Optionally generate unique ChangeID (or omit)
- Add `<Document>` element inside existing `<Group>`
- Ensure proper XML structure and escaping

**4. Remove Document from Project:**
- Use Edit tool to remove entire `<Document>` element
- Ensure no orphaned formatting or whitespace

**5. Toggle Document Inclusion:**
- Change `Included="true"` to `Included="false"` (or vice versa)
- Allows temporary exclusion without removing document reference

**6. Add New Group:**
- Generate unique GroupID
- Create `<Group>` element with attributes
- Add one or more `<Document>` child elements

**ID Generation Guidelines:**

When adding new groups or documents, generate unique IDs:
- **Format:** Alphanumeric string (typically 11 characters for GroupID, variable for DocumentID)
- **Example GroupID:** `w3KcSrHh-HI`, `xYz987aBc`
- **Example DocumentID:** `abc123xyz`, `def456uvw`
- **Generation:** Use random alphanumeric characters (letters and numbers)

**Example: Adding a New Document**

```xml
<!-- Before -->
<Group Name="Group1" Type="normal" Included="true" GroupID="w3KcSrHh-HI">
  <Document Path="Source\content-seed.md" Type="fm-maker" Included="true" DocumentID="abc123xyz" />
</Group>

<!-- After: Add new document to existing group -->
<Group Name="Group1" Type="normal" Included="true" GroupID="w3KcSrHh-HI">
  <Document Path="Source\content-seed.md" Type="fm-maker" Included="true" DocumentID="abc123xyz" />
  <Document Path="Source\new-chapter.md" Type="fm-maker" Included="true" DocumentID="jkl012mno" />
</Group>
```

**Example: Adding a New Group with Documents**

```xml
<!-- Add after existing groups -->
<Group Name="Tutorials" Type="normal" Included="true" GroupID="aBc123DeF">
  <Document Path="Source\tutorial-intro.md" Type="fm-maker" Included="true" DocumentID="pqr345stu" />
  <Document Path="Source\tutorial-advanced.md" Type="fm-maker" Included="true" DocumentID="vwx678yz0" />
</Group>
```

**Example: Excluding Document from Generation**

```xml
<!-- Temporarily exclude without deleting -->
<Document Path="Source\draft-content.md" Type="fm-maker" Included="false" DocumentID="abc999xyz" />
```

**Document Type Reference:**

Common document types:
- `fm-maker` - Markdown files (.md)
- `fm-html` - HTML files (.html, .htm)
- `fm-dita` - DITA XML files (.dita, .xml)
- `fm-word` - Microsoft Word documents (.docx)
- `fm-unstructured` - FrameMaker unstructured files (.fm)

**Path Handling:**

- Use backslashes (`\`) for Windows paths in XML
- Use forward slashes (`/`) for cross-platform compatibility
- Relative paths are relative to project file directory
- Always verify source file exists at specified path before adding

**Validation Before Generation:**

Before running AutoMap, verify:
1. All `Path` attributes point to existing files
2. All `DocumentID` and `GroupID` values are unique
3. At least one document has `Included="true"`
4. No XML syntax errors in modified structure

## File Resolver Pattern

### Understanding the Override Hierarchy

ePublisher uses a three-level file resolver hierarchy (highest to lowest priority):

**Level 1: Target-Specific Overrides**
```
[Project]\Targets\[TargetName]\[format-structure]\
```
- Highest priority
- Applies to specific target only
- Use for target-specific branding, logos, or configurations

**Level 2: Format-Level Overrides**
```
[Project]\Formats\[FormatName]\[format-structure]\
```
- Medium priority
- Applies to all targets using this format
- Use for format-wide customizations

**Level 3: Installation Defaults**
```
C:\Program Files\WebWorks\ePublisher\[version]\Formats\[FormatName]\[format-structure]\
```
- Lowest priority (fallback)
- System-wide defaults
- Never modify files in installation directory

### Critical Requirements

**Parallel Folder Structure:**
- File and folder names MUST exactly match installation hierarchy
- Case-sensitive matching required
- Only copy files being customized (not entire directories)
- Maintain exact relative paths from format root

**Example Mapping:**

Installation file:
```
C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
```

Target-specific override:
```
C:\Projects\MyDoc\Targets\MyWebHelp\Pages\Connect.asp
```

Format-level override:
```
C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
```

### File Types for Customization

**ASP Templates (`.asp`):**
- Active Server Pages template files
- Define HTML page structure and dynamic content
- Common files: `Connect.asp`, `Page.asp`, `Header.asp`, `Footer.asp`, `Search.asp`, `Body.asp` (PDF - XSL-FO), `Title.asp` (PDF - XSL-FO)
- Located in: `Formats\[FormatName]\Pages\`

**SCSS Stylesheets (`.scss`):**
- Sass stylesheet files
- Control visual styling and layout
- Common files: `skin.scss`, `_overrides.scss`, `_variables.scss`
- Located in: `Formats\[FormatName]\Pages\sass\`
- Best practice: Create `_overrides.scss` and import at end of `skin.scss`

**XSL Transforms (`.xsl`):**
- XSLT transformation files
- Process content and generate output
- Common files: `content.xsl`, `pages.xsl`, `pagetemplate.xsl`, various content transforms
- Located in: `Formats\[FormatName]\Transforms\` or `Formats\Shared\common\pages\`

**JavaScript Files (`.js`):**
- Reverb runtime JavaScript
- Client-side functionality
- Located in: `Formats\[FormatName]\Pages\scripts\`

## File Customization Workflows

### Workflow 1: Copy File from Installation to Project

**Standard Process:**

1. **Identify Source File**
   - Determine which file needs customization
   - Locate file in installation Formats directory
   - Note the exact relative path from format root

2. **Determine Override Level**
   - Target-specific: Customization applies to one target only
   - Format-level: Customization applies to all targets using format
   - Choose appropriate level based on scope

3. **Create Directory Structure**
   - Build parallel directory path in project
   - Create intermediate directories if needed
   - Maintain exact folder names and casing

4. **Copy File**
   - Use Read tool to verify source file content
   - Copy to project location maintaining structure
   - Preserve file permissions and attributes

5. **Validate Copy**
   - Confirm file exists in target location
   - Verify content matches source
   - Inform user of customization path with exact location

**Example: Copy Connect.asp for Target-Specific Customization**

Source:
```
C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
```

Target:
```
C:\Projects\MyDoc\Targets\MyWebHelp\Pages\Connect.asp
```

Steps:
```bash
# Create directory structure
mkdir -p "C:\Projects\MyDoc\Targets\MyWebHelp\Pages"

# Copy file
cp "C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp" \
   "C:\Projects\MyDoc\Targets\MyWebHelp\Pages\Connect.asp"
```

### Workflow 2: Modify Customization File

After copying file to project:

1. **Read Current Content**
   - Use Read tool to examine entire file
   - Identify sections requiring modification
   - Note file structure and formatting

2. **Apply Modifications**
   - Use Edit tool for targeted changes
   - Maintain original formatting and indentation
   - Preserve existing functionality unless explicitly changing

3. **Add Documentation**
   - Add comments documenting changes
   - Include date and purpose of modification
   - Mark customization boundaries clearly

4. **Validate Syntax**
   - Check file-specific syntax:
     - ASP: HTML + ASP tags + JavaScript
     - SCSS: Sass compilation rules and variables
     - XSL: XSLT 1.0 syntax and templates
     - JS: JavaScript ES5+ syntax

5. **Test Changes**
   - Rebuild project with AutoMap
   - Verify customizations appear in output
   - Check for errors in build log

**Example: Modify SCSS for Color Scheme**

Create `_overrides.scss`:
```scss
// Custom color scheme
// Modified: 2025-01-27 - Changed primary brand colors

$primary-color: #007ACC;
$secondary-color: #005A9C;
$accent-color: #00BCF2;

// Override toolbar background
.toolbar {
  background-color: $primary-color;
}

// Override link colors
a {
  color: $primary-color;

  &:hover {
    color: $secondary-color;
  }
}
```

Import at end of `skin.scss`:
```scss
// Existing skin.scss content...

// Custom overrides - keep this import last for proper CSS specificity
@import "overrides";
```

### Workflow 3: Create SCSS Override Pattern

Best practice for SCSS customizations:

1. **Copy `skin.scss`** to project (format or target level)
2. **Create `_overrides.scss`** in same directory
3. **Add import** to end of `skin.scss`: `@import "overrides";`
4. **Place all customizations** in `_overrides.scss`
5. **Never modify** existing rules directly in `skin.scss`

Benefits:
- Maintains clear separation of custom vs. default styles
- Easier to upgrade (only need to update skin.scss)
- Proper CSS specificity (overrides load last)
- Better documentation of customizations

### Workflow 4: Customize ASP Template

Common ASP customizations:

**Add Company Logo to Header:**
1. Copy `Connect.asp` to project
2. Locate logo image reference section
3. Modify image path to custom logo
4. Copy logo image to project `Pages\images\` directory

**Modify Toolbar Layout:**
1. Copy `Connect.asp` to project
2. Locate toolbar section (search for `class="toolbar"`)
3. Add/remove toolbar buttons as needed
4. Adjust layout structure

**Add Custom JavaScript:**
1. Copy page template file
2. Locate `<script>` section or create new one
3. Add custom JavaScript functionality
4. Reference external JS files if needed

### Workflow 5: Customize XSL Transform

Common XSL customizations:

**Modify Content Processing:**
1. Identify which XSL file handles desired content
2. Copy to project maintaining directory structure
3. Modify XSLT templates for custom behavior
4. Test with sample content

**Add Custom Attributes:**
1. Locate attribute processing template
2. Add custom attribute handling logic
3. Ensure proper namespace declarations

**Important:** ePublisher uses XSLT 1.0 (Microsoft .NET runtime). Advanced XSLT 2.0+ features are not supported.

## Common Workflows

### Workflow A: Generate HTML5 (Reverb) Output

**User Request:** "Build the Reverb target for this project"

**Steps:**
1. Locate `.wep` or `.wrp` file in current directory using Glob
2. Parse project file to extract available targets:
   ```bash
   grep -oP 'TargetName="\K[^"]+' project.wep
   ```
3. Identify Reverb target (typically "WebWorks Reverb 2.0" or similar)
   - If multiple targets exist, find one containing "Reverb" or "WebWorks Reverb"
   - If only one target exists, use it
   - If ambiguous, ask user to specify
4. Detect AutoMap installation path via registry
5. Construct command: `"[AutoMap]" -c -l -t "[TargetName]" "[ProjectFile]"`
6. Execute with Bash tool (timeout: 600000ms)
7. Monitor output for success/failure
8. Report result with deployment location

### Workflow B: Customize Header Template

**User Request:** "I want to modify the header template to add our company logo"

**Steps:**
1. Confirm current project (check for .wep/.wrp file)
2. Ask user for scope: target-specific or format-level
3. Identify header file: typically `Connect.asp` in Reverb format
4. Detect AutoMap installation to find formats directory
5. Locate source: `[Install]\Formats\WebWorks Reverb 2.0\Pages\Connect.asp`
6. Create target directory structure
7. Copy `Connect.asp` to project
8. Inform user: "Header template copied to [path] - ready for customization"
9. Offer to make specific modifications if user describes them

### Workflow C: Change Color Scheme

**User Request:** "Change the primary color scheme for Reverb output"

**Steps:**
1. Determine customization scope (target vs. format level)
2. Locate SCSS directory in installation
3. Copy `skin.scss` to project
4. Create `_overrides.scss` in same directory
5. Add SCSS override import to end of `skin.scss`
6. Ask user for specific colors or offer common color schemes
7. Write color variables to `_overrides.scss`
8. Offer to rebuild project to preview changes

### Workflow D: Customize Toolbar Layout

**User Request:** "Change the toolbar layout for Reverb output"

**Steps:**
1. Identify files: `Connect.asp` (structure) and `skin.scss` (styling)
2. Determine customization level
3. Copy both files to project
4. Create `_overrides.scss` for style changes
5. Modify `Connect.asp` toolbar section for structural changes
6. Document changes in comments
7. Offer to rebuild and verify changes

### Workflow E: Batch Build All Targets

**User Request:** "Build all targets in this project"

**Steps:**
1. Locate project file
2. Parse project file to identify configured targets:
   ```bash
   grep -oP 'TargetName="\K[^"]+' project.wep
   ```
3. Report to user: "Found [N] targets: [list of target names]"
4. Execute AutoMap without `-t` flag to build all targets (builds all in one execution)
   - OR build each target sequentially with separate AutoMap calls for better progress reporting
5. Monitor progress for each target
6. Report individual target results
7. Summarize overall success/failure with build times

### Workflow F: Build with Custom Deployment Location

**User Request:** "Generate output to a specific folder"

**Steps:**
1. Confirm desired deployment path with user
2. Verify path exists or create it
3. Execute AutoMap with `--deployfolder "[CustomPath]"`
4. Monitor build process
5. Verify output files in custom location
6. Report success with file count and location

## Best Practices

### Path Handling
- Always use absolute paths for AutoMap executable and project files
- Quote all paths containing spaces
- Use forward slashes for cross-platform compatibility when possible
- Normalize Windows path separators in Bash commands

### Performance Optimization
- Cache AutoMap installation path for session (avoid repeated registry queries)
- Use appropriate Bash timeout based on project size (default: 600000ms / 10 minutes)
- Monitor output streaming for large projects to show progress
- Consider using `-c` flag only when necessary (clean builds are slower)

### File Safety
- Always read files before modifying to understand structure
- Create backups before destructive operations (use git or manual copies)
- Validate syntax after modifications
- Preserve original formatting, indentation, and line endings
- Test changes with AutoMap build before committing

### Version Management
- Detect ePublisher version from registry or installation path
- Note version-specific behavior differences
- Warn if project version mismatches installation version
- Support AutoMap 2024.1+ primarily, handle legacy gracefully

### Documentation
- Document all customizations with comments in files
- Include date, author, and purpose of changes
- Use consistent comment markers (e.g., `/* CUSTOM: description */`)
- Track customizations in project README or documentation

### Error Communication
- Provide clear, actionable error messages to users
- Include specific file paths and line numbers when relevant
- Suggest concrete solutions for common problems
- Escalate to user when automated resolution not possible

## Troubleshooting

### AutoMap Not Found
**Symptom:** Cannot locate AutoMap executable

**Solutions:**
1. Query Windows Registry (both 64-bit and 32-bit paths)
2. Check standard installation paths
3. Search Program Files directories
4. Ask user for installation location
5. Verify AutoMap component is installed (not just ePublisher Designer)

### Project File Not Found
**Symptom:** No `.wep`, `.wrp`, or `.wxsp` files in directory

**Solutions:**
1. Use Glob to search current directory and subdirectories
2. Ask user for project file location
3. Verify file extension and naming
4. Check if in correct working directory

### Build Failures
**Symptom:** AutoMap returns non-zero exit code

**Solutions:**
1. Examine console output for specific error messages
2. Validate project file structure and syntax
3. Check source document paths and availability
4. Verify target configuration completeness
5. Review deployment folder permissions and disk space
6. Check for locked files in output directory
7. Try build with `-c` flag for clean generation

### Customization Not Applied
**Symptom:** Modified files don't affect output

**Solutions:**
1. Verify files copied to correct project location (not installation)
2. Check exact folder and file naming matches installation
3. Confirm format name is correct (e.g., "WebWorks Reverb 2.0")
4. Validate override level (target vs. format)
5. Rebuild project with `-c` flag to clear cache
6. Check for syntax errors in customized files
7. Verify file wasn't overridden at higher priority level

### Permission Errors
**Symptom:** Cannot read/write files

**Solutions:**
1. Verify read access to installation directory
2. Confirm write permissions on project directory
3. Check file is not locked by another process (ePublisher Designer, editor)
4. Close ePublisher Designer if project is open
5. Run with appropriate privileges if needed
6. Check antivirus/security software interference

### SCSS Compilation Errors
**Symptom:** Build fails with SCSS/Sass errors

**Solutions:**
1. Validate SCSS syntax (variables, nesting, imports)
2. Verify `@import` statements use correct paths
3. Check variable definitions exist before use
4. Ensure no SCSS 2.0+ features (ePublisher uses older compiler)
5. Review bracket matching and statement terminators

### XSL Transform Errors
**Symptom:** Build fails with XSLT errors

**Solutions:**
1. Validate XML well-formedness
2. Check namespace declarations
3. Verify XSLT 1.0 compatibility (no 2.0+ features)
4. Ensure template match patterns are valid
5. Review XPath expressions for syntax
6. Check for unclosed elements or attributes

## Examples

### Example 1: Complete Workflow - Add Custom Logo

**User:** "I want to add my company logo to the Reverb output header"

**Response:**
1. Detect project file
2. Ask: "Should this apply to all targets or just a specific target?"
3. Based on response, choose format-level or target-specific
4. Copy `Connect.asp` from installation to project
5. Guide user: "I've copied the header template to [path]. To add your logo:"
   - "Place your logo file in [project]\Formats\WebWorks Reverb 2.0\Pages\images\"
   - "I'll modify Connect.asp to reference your logo"
6. Modify ASP file to include logo image tag
7. Offer to rebuild project to preview changes

### Example 2: Quick Build Command

**User:** "Build this project"

**Response:**
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -l "C:\Projects\UserGuide\UserGuide.wep"
```

Output monitoring shows:
```
Processing source documents...
Generating WebWorks Reverb 2.0 output...
Deploying to C:\Projects\UserGuide\Output\WebWorks Reverb 2.0\
Generation completed successfully in 2m 34s
```

Report to user: "Build completed successfully. Output deployed to: C:\Projects\UserGuide\Output\WebWorks Reverb 2.0\"

### Example 3: SCSS Color Customization

**User:** "Make the toolbar blue and links green"

**Response:**
1. Copy `skin.scss` to project (if not already present)
2. Create `_overrides.scss`
3. Add to `_overrides.scss`:
```scss
// Custom colors - Modified 2025-01-27
$toolbar-bg: #0066CC;  // Blue toolbar
$link-color: #00AA00;  // Green links

.toolbar {
  background-color: $toolbar-bg;
}

a {
  color: $link-color;

  &:hover {
    color: darken($link-color, 15%);
  }
}
```
4. Add import to `skin.scss`: `@import "overrides";`
5. Rebuild project
6. Report: "Colors updated. Toolbar is now blue and links are green. Check output at [path]"

## Limitations

- **Windows-only:** ePublisher and AutoMap run on Windows only
- **XSLT 1.0:** XSL transforms limited to XSLT 1.0 (Microsoft .NET runtime)
- **Installation required:** Requires full ePublisher installation with AutoMap component
- **Version compatibility:** Skill targets ePublisher 2024.1+, may require adjustments for older versions
- **File locking:** Cannot modify files while ePublisher Designer has project open
- **Registry access:** Registry-based detection requires standard user permissions

## Security Considerations

This skill requires:
- **Read access:** Windows Registry and ePublisher installation directory
- **Write access:** Project directory for customizations and output folder for builds
- **Execute permissions:** AutoMap CLI invocation via Bash tool

Always verify:
1. AutoMap installation is from trusted source (official WebWorks installer)
2. Project directory has appropriate write permissions
3. Workspace is authorized for automation
4. File paths are validated before operations
5. User-provided paths are sanitized

## Additional Resources

For detailed information, see supporting documentation:
- `references/AUTOMAP_INSTALLATION_DETECTION.md` - Registry-based installation detection
- `references/FILE_RESOLVER_GUIDE.md` - Override hierarchy and parallel construction
- `references/AUTOMAP_CLI_REFERENCE.md` - Complete CLI command reference

---

**Skill Version:** 1.0.0
**Last Updated:** 2025-01-27
**Compatibility:** ePublisher AutoMap 2024.1+
**Status:** Phase 1 - Core Skill Foundation
