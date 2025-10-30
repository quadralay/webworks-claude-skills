---
name: epublisher-core
description: WebWorks ePublisher AutoMap build automation and project management. Detects installations, executes builds, parses project files, and manages source documents. Use when building ePublisher projects, running AutoMap, parsing targets, or managing source files.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
metadata:
  version: "1.0.0"
  category: "build-automation"
  status: "production"
---

# ePublisher Core - Build Automation & Project Management

## Purpose

Automate WebWorks ePublisher AutoMap operations for building documentation projects, managing source files, and understanding project structure. This skill provides the foundation for all ePublisher development workflows.

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

**Helper Script:**
Use `scripts/detect-installation.sh` for robust installation detection with version selection and fallback logic.

### Executing AutoMap Commands

**Basic Command Pattern:**
```bash
"[AutoMap-Path]" "[Project-File]" [Options]
```

**Common Command Options:**
- `-c, --clean`: Clean build (remove cached files before generation)
- `-n, --nodeploy`: Do not copy to deployment location
- `-l, --cleandeploy`: Clean deployment location before copying output
- `-t, --target "[TargetName]"`: Build specific target only (e.g., "WebWorks Reverb 2.0")
- `--deployfolder "[Path]"`: Override deployment destination

**Example Commands:**

Build all targets with clean:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n "C:\Projects\MyDoc\MyDoc.wep"
```

Build specific target:
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n -t "WebWorks Reverb 2.0" "C:\Projects\MyDoc\MyDoc.wep"
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

**Helper Script:**
Use `scripts/automap-wrapper.sh` for enhanced AutoMap execution with comprehensive error reporting and progress monitoring.

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

**Helper Script:**
Use `scripts/parse-targets.sh --version` to automatically detect Base Format Version.

**Why This Matters:**

When customization skills copy format files from the installation directory, they must use files from the correct format version:

**Correct approach:**
```bash
# For project with Base Format Version = 2020.2
source_path="C:\Program Files\WebWorks\ePublisher\2020.2\Formats\..."

# For project with Base Format Version = 2024.1
source_path="C:\Program Files\WebWorks\ePublisher\2024.1\Formats\..."
```

**Important Notes:**
- Always check Base Format Version before creating customizations
- Mixing format versions can cause build errors or unexpected output
- Older projects may intentionally use older formats for stability

### Parsing Project Files for Targets

Project files (`.wep`, `.wrp`) are XML files containing target and format configuration.

**Target/Format Element Structure:**

```xml
<Format TargetName="WebWorks Reverb 2.0"
        Name="WebWorks Reverb 2.0"
        Type="Application"
        TargetID="CC-Reverb-Target">
  <!-- Target configuration -->
</Format>
```

**Key Attributes:**
- `TargetName` - The target name used in AutoMap `-t` parameter
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

**Example Targets with Output Directory:**

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

**OutputDirectory Element:**
- If present: Output generated to this directory
- If absent: Output defaults to `Output\[TargetName]\`
- Can be absolute path or relative to project

**Use Cases:**

1. **List Available Targets:** Parse project file to show user all configured targets
2. **Validate Target Name:** Before executing AutoMap, confirm target exists
3. **Determine Format for Customization:** Use `Name` attribute to construct customization paths
4. **Find Generated Output:** Check for `<OutputDirectory>` to locate build output
5. **Batch Processing:** Extract all target names for sequential builds

**Helper Script:**
Use `scripts/parse-targets.sh` for comprehensive target parsing with JSON output support.

### Managing Source Files in Projects

Project files contain source document references organized in: `<Groups>` → `<Group>` → `<Document>`.

**Source File Structure:**

```xml
<Groups>
  <Group Name="Group1" Type="normal" Included="true" GroupID="w3KcSrHh-HI">
    <Document Path="Source\content-seed.md" Type="normal" Included="true" DocumentID="abc123xyz" />
    <Document Path="Source\getting-started.md" Type="normal" Included="true" DocumentID="def456uvw" />
  </Group>
  <Group Name="Reference" Type="normal" Included="true" GroupID="xYz987aBc">
    <Document Path="Source\api-reference.md" Type="normal" Included="true" DocumentID="ghi789rst" />
  </Group>
</Groups>
```

**FrameMaker Book Structure:**

```xml
<Groups>
  <Group Name="Exploring ePublisher" Type="normal" Included="true" GroupID="dohcaj00OHA">
    <Book Type="book" Included="true" DocumentID="9CK1vFTe-0A" Path="Source Docs\Adobe FrameMaker\Exploring ePublisher.book">
      <Document Type="normal" Included="true" DocumentID="PNwbOCS_JSw" Path="Source Docs\Adobe FrameMaker\Understanding ePublisher.fm" />
    </Book>
  </Group>
</Groups>
```

**Key Attributes:**

**Group Element:**
- `Name` - Display name for the group
- `Type` - Group type (typically "normal")
- `Included` - Boolean ("true"/"false") to include/exclude group
- `GroupID` - Unique identifier (required, auto-generated)

**Document Element:**
- `Path` - **Most Important** - Path to source file (relative or absolute)
- `Type` - Document type (typically "normal")
- `Included` - Boolean ("true"/"false") to include/exclude document
- `DocumentID` - Unique identifier (required, auto-generated)

**Book Element:**
- `Path` - **Most Important** - Path to source file (relative or absolute)
- `Type` - Document type ("book" for FrameMaker book)
- `Included` - Boolean ("true"/"false") to include/exclude book
- `DocumentID` - Unique identifier (required, auto-generated)

**Common Operations:**

**1. List All Source Files:**
```bash
# Extract all document paths
grep -oP 'Document Path="\K[^"]+' project.wep

# Show paths with inclusion status
grep '<Document ' project.wep | grep -oP 'Path="\K[^"]+|Included="\K[^"]+'
```

**2. Check If Document Included:**
```bash
# Find specific document and check status
grep 'Path="Source\\content-seed.md"' project.wep | grep -oP 'Included="\K[^"]+'
```

**3. Add New Document:**
- Generate unique DocumentID (alphanumeric string)
- Add `<Document>` element inside existing `<Group>`
- Ensure proper XML structure and escaping

**4. Remove Document:**
- Use Edit tool to remove entire `<Document>` element
- Ensure no orphaned formatting

**5. Toggle Document Inclusion:**
- Change `Included="true"` to `Included="false"` (or vice versa)
- Allows temporary exclusion without removing reference

**6. Add New Group:**
- Generate unique GroupID
- Create `<Group>` element with attributes
- Add one or more `<Document>` child elements

**6. Add New Book:**
- Generate unique DocumentID
- Add `<Book>` element with attributes, no child elements
- Ensure proper XML structure and escaping

**ID Generation Guidelines:**
- **Format:** Alphanumeric string (typically 11 chars for GroupID)
- **Example GroupID:** `w3KcSrHh-HI`, `xYz987aBc`
- **Example DocumentID:** `abc123xyz`, `def456uvw`
- **Generation:** Use random alphanumeric characters

**Document Type Reference:**

Common document/book types:
- `normal` - Markdown files (.md)
- `normal` - DITA XML files (.ditamap, .dita, .xml)
- `normal` - Microsoft Word documents (.docx)
- `normal` - FrameMaker documents (.fm)
- `book` - FrameMaker books (.bk, .book)

**Path Handling:**
- Use backslashes (`\`) for Windows paths in XML
- Relative paths are relative to project file directory
- Always verify source file exists before adding

**Helper Script:**
Use `scripts/manage-sources.sh` for listing, validating, and managing source documents.

## File Resolver Pattern Overview

ePublisher uses a three-level file resolver hierarchy for customizations:

**Level 1: Target-Specific** (highest priority)
```
[Project]\Targets\[TargetName]\[format-structure]\
```

**Level 2: Format-Level** (medium priority)
```
[Project]\Formats\[FormatName]\[format-structure]\
```

**Level 3: Installation** (fallback)
```
C:\Program Files\WebWorks\ePublisher\[version]\Formats\[FormatName]\[format-structure]\
```

**Critical Requirement:** File and folder names MUST exactly match installation hierarchy (case-sensitive).

**Note:** Detailed file resolver documentation and customization workflows are provided by specialized customization skills (epublisher-reverb-css, epublisher-pdf-page-layout, etc.).

See `{baseDir}/../../../shared/references/FILE_RESOLVER_GUIDE.md` for comprehensive file resolver documentation.

## Helper Scripts

This skill includes several helper scripts located in `scripts/`:

### detect-installation.sh

Robust AutoMap installation detection with multiple strategies:
- Registry-based detection (64-bit and 32-bit)
- Filesystem fallback search
- Version selection and filtering
- Verbose output for troubleshooting

**Usage:**
```bash
./scripts/detect-installation.sh                  # Detect latest version
./scripts/detect-installation.sh --version 2020.2 # Specific version
./scripts/detect-installation.sh --verbose        # Detailed output
```

### automap-wrapper.sh

Enhanced AutoMap CLI wrapper with error reporting:
- Clean builds with cache clearing
- Target-specific generation
- Custom deployment folders
- Progress monitoring
- Comprehensive error messages

**Usage:**
```bash
./scripts/automap-wrapper.sh -c -l project.wep              # Clean build all
./scripts/automap-wrapper.sh -t "WebWorks Reverb 2.0" project.wep  # Specific target
./scripts/automap-wrapper.sh --deployfolder "C:\Output" project.wep  # Custom output
```

### parse-targets.sh

Parse project files to extract target and format information:
- List all targets
- Extract format names
- Detect Base Format Version
- JSON output support
- Detailed target configuration

**Usage:**
```bash
./scripts/parse-targets.sh project.wep            # List targets
./scripts/parse-targets.sh --list project.wep     # Detailed info
./scripts/parse-targets.sh --json project.wep     # JSON output
./scripts/parse-targets.sh --version project.wep  # Base Format Version
```

### manage-sources.sh

Manage source documents in project files:
- List all source documents
- Validate source file paths exist
- Toggle document inclusion
- Display group hierarchy
- Check document status

**Usage:**
```bash
./scripts/manage-sources.sh --list project.wep       # List all sources
./scripts/manage-sources.sh --validate project.wep   # Check paths exist
./scripts/manage-sources.sh --toggle "Source\file.md" project.wep  # Toggle inclusion
```

## Common Workflows

### Build Project

1. Detect AutoMap installation using detect-installation.sh
2. Parse project file to identify targets
3. Execute build using automap-wrapper.sh
4. Monitor output for errors
5. Report deployment location on success

### List Project Targets

1. Find project file (.wep/.wrp) in current directory
2. Parse targets using parse-targets.sh
3. Display target names, format names, and output locations

### Manage Source Documents

1. Parse source documents using manage-sources.sh
2. List all documents with inclusion status
3. Validate source file paths exist
4. Toggle inclusion status as needed

### Check Project Configuration

1. Detect Base Format Version using parse-targets.sh --version
2. List targets and formats
3. Validate source documents
4. Report project summary to user

## Integration with Customization Skills

This core skill provides foundation services for customization skills:

- **Installation Detection:** Customization skills use Base Format Version to locate source files
- **File Resolver Understanding:** Customization skills use hierarchy knowledge to place files correctly
- **Project Structure:** Customization skills navigate project directories using core patterns

Customization skills (epublisher-reverb-css, epublisher-pdf-page-layout, etc.) build on this foundation to provide specialized format customization assistance.
