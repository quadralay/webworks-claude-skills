---
name: epublisher-core
description: WebWorks ePublisher AutoMap build automation and project management. Detects installations, executes builds, parses project files, and manages source documents. Use when building ePublisher projects, running AutoMap, parsing targets, or managing source files.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
metadata:
  version: "1.1.0"
  category: "build-automation"
  status: "production"
  related-skills:
    - epublisher-reverb-browser-test
    - epublisher-reverb-scss-customizer
  documentation:
    installation: "./INSTALLATION.md"
    references:
      - "./references/AUTOMAP_CLI_REFERENCE.md"
      - "./references/PROJECT_PARSING_GUIDE.md"
      - "../../../shared/references/USER_INTERACTION_PATTERNS.md"
---

# ePublisher Core - Build Automation & Project Management

## Purpose

Automate WebWorks ePublisher AutoMap operations for building documentation projects, managing source files, and understanding project structure. This skill provides the foundation for all ePublisher development workflows.

**Core Capabilities:**
- Detect and validate ePublisher installations
- Execute AutoMap builds with comprehensive error handling
- Parse project files (.wep, .wrp, .wxsp) to extract configuration
- Manage source documents (add, remove, toggle inclusion)
- Determine Base Format Version for customization workflows
- Monitor build output and report results

## AutoMap CLI Operations

### Detecting AutoMap Installation

Locate AutoMap executable using Windows Registry (preferred method):

**Registry Paths:**

64-bit installation:
```
HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\[VERSION]
```

32-bit installation:
```
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\[VERSION]
```

**Registry Values:**

| Value Name | Type | Description | Example |
|------------|------|-------------|---------|
| `ExePath` | REG_SZ | Full path to AutoMap executable | `C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe` |
| `Version` | REG_SZ | Full version with build number | `24.1.4603` |

**Detection Workflow:**

1. Query registry to enumerate installed versions
2. Select requested version or latest available
3. Extract `ExePath` value from version key
4. Optionally extract build number from `Version` value (last fragment after dot)
5. Validate executable file exists at path
6. Cache path for session duration

**Registry Query Examples:**

Bash/reg - Get AutoMap path:
```bash
reg query "HKLM\SOFTWARE\WebWorks\ePublisher AutoMap\2024.1" /v ExePath
```

Bash/reg - Get version and build number:
```bash
# Get version string
version=$(reg query "HKLM\SOFTWARE\WebWorks\ePublisher AutoMap\2024.1" /v Version | grep "Version" | awk '{print $NF}')

# Extract build number (last fragment after final dot)
build_number=$(echo "$version" | awk -F'.' '{print $NF}')
```

Bash/reg - List all installed versions:
```bash
reg query "HKLM\SOFTWARE\WebWorks\ePublisher AutoMap" | grep "HKEY" | sed 's/.*\\//'
```

**Fallback Method:**

If registry unavailable, check standard installation paths:
- `C:\Program Files\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`
- `C:\Program Files (x86)\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`

Enumerate version directories to find latest installation.

**Helper Script:**

Use `scripts/detect-installation.sh` for robust detection with version selection and build number extraction:

```bash
./scripts/detect-installation.sh                  # Latest version
./scripts/detect-installation.sh --version 2024.1 # Specific version
./scripts/detect-installation.sh --show-build     # With build number
```

### Executing AutoMap Commands

**Basic Command Pattern:**
```bash
"[AutoMap-Path]" "[Project-File]" [Options]
```

**Common Options:**
- `-c, --clean` - Clean build (remove cached files)
- `-n, --nodeploy` - Skip deployment (output stays in project folder)
- `-l, --cleandeploy` - Clean deployment location before copying
- `-t, --target "[TargetName]"` - Build specific target only
- `--deployfolder "[Path]"` - Override deployment destination

**Quick Examples:**

Clean build all targets (no deploy):
```bash
"C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe" -c -n "C:\Projects\MyDoc\MyDoc.wep"
```

Build specific target:
```bash
"[AutoMap-Path]" -c -n -t "WebWorks Reverb 2.0" "[Project-File]"
```

**Execution Best Practices:**
1. Always use absolute paths (both executable and project file)
2. Quote all paths containing spaces
3. Set Bash tool timeout to 600000ms (10 minutes) for large projects
4. Capture both stdout and stderr
5. Check exit code: 0=success, non-zero=failure

**Output Monitoring:**

Watch for these patterns:
- **Success:** "Generation completed successfully", "Output deployed to"
- **Errors:** "Error:", "Failed to", "Unable to", "Exception"
- **Warnings:** "Warning:", "Could not find"

**Common Errors:**

| Error | Cause | Solution |
|-------|-------|----------|
| Project file not found | Invalid path | Verify project file path |
| Source document missing | Broken reference | Check source file locations |
| Invalid target configuration | Corrupted settings | Review target XML in project file |
| Insufficient disk space | Output drive full | Check available space |
| Permission denied | Restricted folder | Verify write permissions |

**See Also:** [`references/AUTOMAP_CLI_REFERENCE.md`](./references/AUTOMAP_CLI_REFERENCE.md) for comprehensive AutoMap CLI documentation, timeout guidelines, and troubleshooting.

## ePublisher Project Structure

### Project File Types

**`.wep` (Designer Project / Stationery):**
- Precursor to Stationery format
- Contains format configurations and settings
- Located in project root directory

**`.wxsp` (Stationery Project):**
- Stationery project with no source documents
- Deep copy of all installation XSL files
- Self-contained format definitions

**`.wrp` (Project):**
- Full project file (deep copy)
- Contains source document references
- Target configurations and deployment settings

### Project Recognition

Identify ePublisher projects by:
1. Presence of `.wep`, `.wrp`, or `.wxsp` files
2. `Formats/` directory with format-specific customizations
3. `Targets/` directory with target-specific overrides

**Quick Detection:**
```bash
# Find project files
find . -maxdepth 1 -name "*.wep" -o -name "*.wrp" -o -name "*.wxsp"
```

### Determining Base Format Version

The Base Format Version determines which installation format files to use for customizations. This is **critical** for customization skills.

**Project Root Element:**

```xml
<Project Version="1.1.2.0"
         RuntimeVersion="2024.1"
         FormatVersion="{Current}"
         xmlns="urn:WebWorks-Publish-Project">
  <!-- Project content -->
</Project>
```

**Key Attributes:**
- `RuntimeVersion` - ePublisher version that last saved project (e.g., "2024.1")
- `FormatVersion` - Format version override (typically "{Current}" or specific version like "2020.2")

**Base Format Version Logic:**

```
IF FormatVersion == "{Current}" THEN
    Base Format Version = RuntimeVersion
ELSE
    Base Format Version = FormatVersion
END IF
```

**Examples:**

Most common (current format):
```xml
<Project RuntimeVersion="2024.1" FormatVersion="{Current}" ...>
```
→ Base Format Version = `2024.1`

Locked to older format for compatibility:
```xml
<Project RuntimeVersion="2024.1" FormatVersion="2020.2" ...>
```
→ Base Format Version = `2020.2`

**Why This Matters:**

Customization skills must copy format files from the correct installation version:

```bash
# For Base Format Version = 2024.1
source="C:\Program Files\WebWorks\ePublisher\2024.1\Formats\..."

# For Base Format Version = 2020.2
source="C:\Program Files\WebWorks\ePublisher\2020.2\Formats\..."
```

Mixing format versions causes build errors or unexpected output.

**Helper Script:**
```bash
./scripts/parse-targets.sh --version project.wep  # Shows Base Format Version
```

### Parsing Project Files for Targets

Project files are XML containing target/format configuration.

**Target/Format Element:**

```xml
<Format TargetName="WebWorks Reverb 2.0"
        Name="WebWorks Reverb 2.0"
        Type="Application"
        TargetID="RrzaU8EqDdU">
  <OutputDirectory>Output\WebWorks Reverb 2.0</OutputDirectory>
</Format>
```

**Key Attributes:**
- `TargetName` - Used in AutoMap `-t` parameter (MOST IMPORTANT for builds)
- `Name` - Format name for customization paths (e.g., "WebWorks Reverb 2.0")
- `TargetID` - Unique identifier for this target
- `<OutputDirectory>` - Output location (optional, defaults to `Output\[TargetName]\`)

**Common Operations:**

List all targets:
```bash
grep -oP 'TargetName="\K[^"]+' project.wep
```

Validate target exists before building:
```bash
grep 'TargetName="WebWorks Reverb 2.0"' project.wep
```

**Use Cases:**
1. List available targets for user
2. Validate target name before AutoMap execution
3. Determine format name for customization paths
4. Find generated output location

**See Also:** [`references/PROJECT_PARSING_GUIDE.md`](./references/PROJECT_PARSING_GUIDE.md) for comprehensive project file parsing documentation and source document management.

### Managing Source Files

Project files contain source document references in XML structure:

```xml
<Groups>
  <Group Name="Getting Started" Type="normal" Included="true" GroupID="w3KcSrHh-HI">
    <Document Path="Source\content-seed.md" Type="normal" Included="true" DocumentID="abc123xyz" />
    <Document Path="Source\getting-started.md" Type="normal" Included="true" DocumentID="def456uvw" />
  </Group>
</Groups>
```

**Key Attributes:**
- `Path` - **Most Important** - Path to source file (relative or absolute)
- `Included` - Boolean ("true"/"false") to include/exclude
- `DocumentID` - Unique identifier (required, auto-generated)
- `GroupID` - Unique group identifier

**Common Operations:**

List all source files:
```bash
grep -oP 'Document Path="\K[^"]+' project.wep
```

Check if document is included:
```bash
grep 'Path="Source\\content-seed.md"' project.wep | grep -oP 'Included="\K[^"]+'
```

**ID Generation Guidelines:**
- Use random alphanumeric characters
- GroupID: typically 11 chars (e.g., `w3KcSrHh-HI`)
- DocumentID: typically 8-11 chars (e.g., `abc123xyz`)

**See Also:** [`references/PROJECT_PARSING_GUIDE.md`](./references/PROJECT_PARSING_GUIDE.md) for detailed source management operations (add, remove, toggle inclusion).

## File Resolver Pattern Overview

ePublisher uses a four-level file resolver hierarchy for customizations:

**Level 1: Target-Specific** (highest priority)
```
[Project]\Targets\[TargetName]\[format-structure]\
```

**Level 2: Format-Level** (medium priority)
```
[Project]\Formats\[FormatName]\[format-structure]\
```

**Level 3: Packaged Installation Defaults** (Isolates Project from installation changes when using ePublisher Express)
```
[Project]\Formats\[FormatName].base\[format-structure]\
```

**Level 4: Installation** (fallback)
```
C:\Program Files\WebWorks\ePublisher\[version]\Formats\[FormatName]\[format-structure]\
```

**Critical:** File and folder names MUST exactly match installation hierarchy (case-sensitive).

**Note:** Detailed file resolver documentation and customization workflows are provided by specialized customization skills (epublisher-reverb-scss-customizer, epublisher-pdf-page-layout, etc.).

**See Also:** `shared/references/FILE_RESOLVER_GUIDE.md` for comprehensive file resolver documentation.

## Helper Scripts

Helper scripts located in `scripts/` directory:

| Script | Purpose |
|--------|---------|
| `detect-installation.sh` | Robust AutoMap installation detection with registry queries, build number extraction, and version selection |
| `automap-wrapper.sh` | Enhanced AutoMap CLI wrapper with error reporting and progress monitoring |
| `parse-targets.sh` | Parse project files to extract targets, formats, and Base Format Version |
| `manage-sources.sh` | Manage source documents (list, validate, toggle inclusion) |

**Usage Examples:**

```bash
# Detect AutoMap
./scripts/detect-installation.sh --version 2024.1

# Build project
./scripts/automap-wrapper.sh -c -n -t "WebWorks Reverb 2.0" project.wep

# List targets
./scripts/parse-targets.sh --list project.wep

# Validate sources
./scripts/manage-sources.sh --validate project.wep
```

**See Also:**
- [`references/AUTOMAP_CLI_REFERENCE.md`](./references/AUTOMAP_CLI_REFERENCE.md) - Detailed script documentation
- [`INSTALLATION.md`](./INSTALLATION.md) - Installation and setup guide (for humans)

## Handling User Requests

### Distinguishing Between Queries and Creation Requests

When a user asks about something that doesn't exist, clarify their intent before proceeding.

**User Query Indicators (inform only):**
- "What is...", "Show me...", "List...", "Where is..."
- Asking about items in informational context
- **Response:** Provide information, acknowledge non-existence

**Creation Request Indicators (create new items):**
- "Add...", "Create...", "Make...", "Set up..."
- "I need a new..."
- Specific parameters provided
- **Response:** Proceed with creation

**Ambiguous Verbs:**
- **"generate"** - Can mean "show" OR "create" - **ALWAYS clarify**
- **"get"** - Usually "retrieve/show" unless context suggests creation
- **"provide"** - Usually "show" unless "provide me with a new..."

**Best Practice:**

When something doesn't exist:
1. **Acknowledge** non-existence clearly
2. **Provide context** - show what DOES exist
3. **Offer creation** if applicable
4. **Never assume** creation intent without confirmation

**Examples:**

Request: "What targets are in this project?"
→ Parse and list existing targets only.

Request: "Can you generate Target 2?"
→ "Target 2 doesn't exist. Only 'Target 1' is configured. Would you like me to create 'Target 2'?"

Request: "Add Target 2 with Reverb format"
→ Proceed with creation (clear intent).

Request: "Show me the PDF target"
→ "No PDF target configured. Only 'Target 1' (Reverb) exists. Would you like to create a PDF target?"

**See Also:** [`shared/references/USER_INTERACTION_PATTERNS.md`](../../../shared/references/USER_INTERACTION_PATTERNS.md) for comprehensive user intent disambiguation patterns and examples.

## Common Workflows

### Build Project

1. Detect AutoMap installation using `detect-installation.sh`
2. Parse project file to identify targets
3. Execute build using `automap-wrapper.sh` or AutoMap directly
4. Monitor output for errors/warnings
5. Report deployment location on success

### List Project Targets

1. Find project file (.wep/.wrp/.wxsp) in directory
2. Parse targets using `parse-targets.sh`
3. Display target names, format names, output locations

### Manage Source Documents

1. Parse source documents using `manage-sources.sh --list`
2. List all documents with inclusion status
3. Validate source file paths exist
4. Toggle inclusion status as needed

### Check Project Configuration

1. Detect Base Format Version using `parse-targets.sh --version`
2. List targets and formats
3. Validate source documents
4. Report project summary to user

## Integration with Customization Skills

This core skill provides foundation services for customization skills:

**Services Provided:**
- **Installation Detection** - Customization skills use Base Format Version to locate source files
- **File Resolver Understanding** - Customization skills use hierarchy knowledge to place files correctly
- **Project Structure Navigation** - Customization skills navigate project directories using core patterns
- **Build Execution** - Customization skills trigger rebuilds after making changes

**Related Customization Skills:**
- `epublisher-reverb-scss-customizer` - Modify Reverb SCSS variables (_colors.scss, _sizes.scss, etc.)
- `epublisher-reverb-browser-test` - Test Reverb output in browsers
- `epublisher-pdf-page-layout` - Customize PDF page layouts (future)

## Version History

**v1.1.0** (2025-11-04)
- Extracted detailed content to reference files (progressive disclosure)
- Created AUTOMAP_CLI_REFERENCE.md for comprehensive CLI documentation
- Created PROJECT_PARSING_GUIDE.md for project file parsing
- Moved USER_INTERACTION_PATTERNS.md to shared references
- Added INSTALLATION.md for human developers
- Reduced SKILL.md from 691 to ~400 lines (42% reduction)
- Enhanced metadata with related-skills and documentation links

**v1.0.0** (2025-11-01)
- Initial release
- Core AutoMap automation
- Project file parsing
- Source document management
- Base Format Version detection
