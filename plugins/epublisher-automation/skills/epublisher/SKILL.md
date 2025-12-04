# epublisher

Core knowledge about WebWorks ePublisher projects, file structure, and conventions. This skill provides foundational understanding without automation or format-specific details.

## Overview

WebWorks ePublisher transforms source documents (Word, FrameMaker, DITA, Markdown) into multiple output formats (Reverb, PDF, CHM, etc.) using a project-based workflow.

## Key Concepts

### Project Structure

An ePublisher project (`.wep` file) contains:
- **Targets**: Named output configurations (e.g., "WebWorks Reverb 2.0", "PDF")
- **Groups**: Collections of source documents
- **Documents**: Individual source files within groups
- **FormatSettings**: Configuration values for each target

### File Resolver Hierarchy

ePublisher resolves files through a 4-level hierarchy (highest to lowest priority):

1. **Target-Specific**: `[Project]/Targets/[TargetName]/`
2. **Format-Level**: `[Project]/Formats/[FormatName]/`
3. **Packaged Defaults**: `[Project]/Formats/[FormatName].base/`
4. **Installation**: `C:\Program Files\WebWorks\ePublisher\[version]\Formats\`

See `references/file-resolver-guide.md` for complete details.

### Project File Format

The `.wep` file is XML containing target definitions:

```xml
<Format Name="WebWorks Reverb 2.0"
        TargetID="abc123"
        TargetName="Help Output">
  <OutputDirectory>Output\Help</OutputDirectory>
  <FormatConfiguration>
    <FormatSetting Name="toolbar-generate" Value="true"/>
    <FormatSetting Name="header-generate" Value="false"/>
  </FormatConfiguration>
</Format>
```

### Source Document Groups

Documents are organized into groups within projects:

```xml
<Group Name="User Guide" GroupID="grp123">
  <Document Name="chapter1.docx" DocumentID="doc456"/>
  <Document Name="chapter2.docx" DocumentID="doc789"/>
</Group>
```

## Scripts

### parse-targets.sh

Extract target information from a project file:

```bash
./parse-targets.sh <project-file>
```

Returns JSON with target names, IDs, formats, and output directories.

### manage-sources.sh

List and manage source document groups:

```bash
./manage-sources.sh <project-file> [list|add|remove]
```

## Reference Files

- `file-resolver-guide.md` - Complete file resolution hierarchy
- `project-parsing-guide.md` - Detailed project file structure
- `user-interaction-patterns.md` - UX patterns for ePublisher workflows

## Common Tasks

### Find all targets in a project

```bash
./scripts/parse-targets.sh /path/to/project.wep
```

### Locate format customization files

Check the file resolver hierarchy:
1. First: `[Project]/Formats/[FormatName]/`
2. Then: `[Project]/Formats/[FormatName].base/`
3. Finally: Installation directory

### Identify source documents

```bash
./scripts/manage-sources.sh /path/to/project.wep list
```
