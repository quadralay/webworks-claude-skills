# ePublisher File Resolver and Override Hierarchy Guide

## Overview

WebWorks ePublisher uses a sophisticated file resolver system that allows customization of format files (templates, stylesheets, transforms) without modifying the installation files. Understanding this hierarchy is critical for successful customizations.

## The Three-Level Override Hierarchy

ePublisher resolves files using a priority-based hierarchy, from highest to lowest priority:

### Level 1: Target-Specific Overrides (Highest Priority)

**Location:** `[Project]\Targets\[TargetName]\[format-structure]\`

**Purpose:** Customizations that apply to a single target only

**Use Cases:**
- Target-specific branding (logos, colors unique to one output)
- Custom deployment configurations for a single target
- Test customizations before applying format-wide

**Example:**
```
C:\Projects\UserGuide\Targets\WebHelp-Internal\Pages\Connect.asp
C:\Projects\UserGuide\Targets\WebHelp-Internal\Pages\sass\skin.scss
```

**When to Use:**
- Customization applies to only one target
- Testing changes before broader deployment
- Target-specific branding or configuration

### Level 2: Format-Level Overrides (Medium Priority)

**Location:** `[Project]\Formats\[FormatName]\[format-structure]\`

**Purpose:** Customizations that apply to all targets using this format

**Use Cases:**
- Format-wide styling changes (colors, fonts, layout)
- Custom templates shared across all targets of this format
- Common branding elements for all outputs of this type

**Example:**
```
C:\Projects\UserGuide\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
C:\Projects\UserGuide\Formats\WebWorks Reverb 2.0\Pages\sass\_overrides.scss
```

**When to Use:**
- Customization should apply to all targets using this format
- Shared branding or styling across multiple outputs
- Common functionality needed by all targets

### Level 3: Installation Defaults (Lowest Priority / Fallback)

**Location:** `C:\Program Files\WebWorks\ePublisher\[version]\Formats\[FormatName]\[format-structure]\`

**Purpose:** System-wide default files provided by installation

**Use Cases:**
- Fallback files when no project overrides exist
- Reference for original file structure
- Source for copying files to project

**Example:**
```
C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\sass\skin.scss
```

**Important Rules:**
- **NEVER modify installation files directly**
- Always copy to project for customizations
- Installation files may be overwritten during upgrades

## Resolution Process

When ePublisher needs a file (e.g., `Pages\Connect.asp`), it searches in this order:

1. Check target-specific location: `Targets\[TargetName]\Pages\Connect.asp`
2. If not found, check format-level: `Formats\[FormatName]\Pages\Connect.asp`
3. If still not found, use installation default: `[Install]\Formats\[FormatName]\Pages\Connect.asp`

**The first file found wins** - ePublisher stops searching once a match is found.

## Parallel Folder Structure Requirement

### Critical Rule

**File and folder names MUST exactly match the installation hierarchy.**

This is not optional - it's a strict requirement for the file resolver to work.

### Example: Connect.asp Customization

**Installation File:**
```
C:\Program Files\WebWorks\ePublisher\2024.1\
  └─ Formats\
      └─ WebWorks Reverb 2.0\
          └─ Pages\
              └─ Connect.asp
```

**Valid Target-Specific Override:**
```
C:\Projects\MyDoc\
  └─ Targets\
      └─ MyWebHelp\
          └─ Pages\              ← Exact folder name match
              └─ Connect.asp     ← Exact file name match
```

**Valid Format-Level Override:**
```
C:\Projects\MyDoc\
  └─ Formats\
      └─ WebWorks Reverb 2.0\    ← Exact format name match
          └─ Pages\              ← Exact folder name match
              └─ Connect.asp     ← Exact file name match
```

**INVALID Examples:**

```
# Wrong folder name (Pages vs pages)
C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\pages\Connect.asp

# Wrong file name (connect.asp vs Connect.asp)
C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\connect.asp

# Missing intermediate folder (no Pages directory)
C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Connect.asp

# Wrong format name (missing "2.0")
C:\Projects\MyDoc\Formats\WebWorks Reverb\Pages\Connect.asp
```

### Why This Matters

The file resolver uses exact string matching for paths. Any deviation causes the resolver to skip your customization and fall back to the installation file, making your changes invisible in the output.

### Case Sensitivity

While Windows is case-insensitive for file system operations, **ePublisher's file resolver is case-sensitive** when matching paths. Always preserve exact casing from installation.

## Base Format Version and Customization Sources

### What is Base Format Version?

The Base Format Version determines which version of format files to use when creating customizations. Different ePublisher versions may have incompatible file structures.

### Determining Base Format Version

Extract from the `<Project>` element in `.wep` or `.wrp` or `.wxsp` files:

```xml
<Project RuntimeVersion="2024.1" FormatVersion="{Current}" ...>
```

**Logic:**
```
IF FormatVersion == "{Current}" THEN
    Base Format Version = RuntimeVersion
ELSE
    Base Format Version = FormatVersion
END IF
```

**Examples:**

1. **Current format (most common):**
   ```xml
   <Project RuntimeVersion="2024.1" FormatVersion="{Current}">
   ```
   Base Format Version = `2024.1`

2. **Locked to older format:**
   ```xml
   <Project RuntimeVersion="2024.1" FormatVersion="2020.2">
   ```
   Base Format Version = `2020.2`

### Using Base Format Version

When copying files from installation to project, always use the Base Format Version:

**Correct:**
```bash
# For project with Base Format Version = 2020.2
source="C:\Program Files\WebWorks\ePublisher\2020.2\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
destination="C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
```

**Incorrect:**
```bash
# Using wrong version (2024.1 when project uses 2020.2)
source="C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
destination="C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
```

### Why Version Matters

- File structure may differ between versions
- XSL templates may have different parameters
- SCSS variables and mixins may change
- ASP page structure may evolve

Mixing versions can cause build errors or unexpected output.

## Common Customization Workflows

### Workflow 1: Copy Single File to Format Level

**Scenario:** Customize `Connect.asp` for all targets using WebWorks Reverb 2.0

**Steps:**

1. **Determine Base Format Version:**
   ```bash
   grep -oP '<Project[^>]*RuntimeVersion="\K[^"]+' project.wep
   # Output: 2024.1
   ```

2. **Locate source file in installation:**
   ```
   C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
   ```

3. **Construct destination path (format-level):**
   ```
   C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
   ```

4. **Create directory structure:**
   ```bash
   mkdir -p "C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages"
   ```

5. **Copy file:**
   ```bash
   cp "C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp" \
      "C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
   ```

6. **Verify structure:**
   - ✓ Format name matches: `WebWorks Reverb 2.0`
   - ✓ Folder name matches: `Pages`
   - ✓ File name matches: `Connect.asp`

### Workflow 2: Copy File to Target-Specific Location

**Scenario:** Customize `skin.scss` for only the "Internal WebHelp" target

**Steps:**

1. **Determine target name:**
   ```bash
   grep -oP 'TargetName="\K[^"]+' project.wep
   # Find: "Internal WebHelp"
   ```

2. **Determine format name:**
   ```bash
   grep '<Format .*TargetName="Internal WebHelp"' project.wep | grep -oP 'Name="\K[^"]+'
   # Output: WebWorks Reverb 2.0
   ```

3. **Locate source:**
   ```
   C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\sass\skin.scss
   ```

4. **Construct destination (target-specific):**
   ```
   C:\Projects\MyDoc\Targets\Internal WebHelp\Pages\sass\skin.scss
   ```

5. **Create structure and copy:**
   ```bash
   mkdir -p "C:\Projects\MyDoc\Targets\Internal WebHelp\Pages\sass"
   cp "C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\sass\skin.scss" \
      "C:\Projects\MyDoc\Targets\Internal WebHelp\Pages\sass\skin.scss"
   ```

### Workflow 3: SCSS Override Pattern (Best Practice)

**Scenario:** Customize colors without modifying `skin.scss` directly

**Why:** Easier to upgrade and maintain; clear separation of custom vs. default styles

**Steps:**

1. **Copy `skin.scss` to project** (format or target level)

2. **Create `_overrides.scss` in same directory:**
   ```scss
   // Custom color overrides
   // Modified: 2025-01-27 - Updated brand colors

   $primary-color: #007ACC;
   $secondary-color: #005A9C;

   // Override toolbar styling
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

3. **Add import to end of `skin.scss`:**
   ```scss
   // ... existing skin.scss content ...

   // Custom overrides - keep this import last for proper CSS specificity
   @import "overrides";
   ```

4. **Benefits:**
   - All customizations in one file (`_overrides.scss`)
   - Original `skin.scss` mostly unchanged (easier to compare with installation)
   - Clear documentation of what was customized
   - Proper CSS specificity (overrides load last)

## File Types and Locations

### ASP Templates (`.asp`)

**Purpose:** Define HTML page structure and dynamic content

**Common Files:**
- `Connect.asp` - Main page template (Reverb)
- `Page.asp` - Content page template
- `Header.asp` - Page header
- `Footer.asp` - Page footer
- `Search.asp` - Search page
- `Body.asp` - PDF body template (PDF - XSL-FO)
- `Title.asp` - PDF title page (PDF - XSL-FO)

**Location:** `Formats\[FormatName]\Pages\`

**Customization Use Cases:**
- Add company logos
- Modify toolbar layout
- Customize header/footer content
- Add custom JavaScript
- Modify page metadata

### SCSS Stylesheets (`.scss`)

**Purpose:** Control visual styling and layout

**Common Files:**
- `skin.scss` - Main stylesheet (imports all others)
- `_overrides.scss` - Custom overrides (create this)
- `_variables.scss` - SCSS variables
- `_mixins.scss` - SCSS mixins
- `_layout.scss` - Layout definitions

**Location:** `Formats\[FormatName]\Pages\sass\`

**Customization Use Cases:**
- Change color schemes
- Modify fonts and typography
- Adjust layout and spacing
- Customize toolbar styling
- Override default styles

**Best Practice:** Always use `_overrides.scss` pattern

### XSL Transforms (`.xsl`)

**Purpose:** Process content and generate output

**Common Files:**
- `content.xsl` - Content transformation
- `pages.xsl` - Page generation
- `pagetemplate.xsl` - Page template processing
- Various element-specific transforms

**Locations:**
- `Formats\[FormatName]\Transforms\`
- `Formats\Shared\common\pages\`
- `Formats\Shared\common\transforms\`

**Customization Use Cases:**
- Modify content processing
- Add custom attributes
- Change output structure
- Customize element rendering

**Important:** ePublisher uses XSLT 1.0 (Microsoft .NET runtime) - advanced XSLT 2.0+ features are not supported.

### JavaScript Files (`.js`)

**Purpose:** Client-side functionality (Reverb runtime)

**Common Files:**
- Reverb runtime scripts
- Search functionality
- Navigation behavior

**Location:** `Formats\[FormatName]\Pages\scripts\`

**Customization Use Cases:**
- Add custom client-side behavior
- Modify search functionality
- Customize navigation

## Validation and Testing

### Pre-Customization Checklist

Before copying files:

- [ ] Determined Base Format Version
- [ ] Located source file in correct installation version
- [ ] Verified source file exists and is readable
- [ ] Identified target customization level (format vs. target)
- [ ] Constructed destination path with exact structure match
- [ ] Verified all folder and file names match exactly (including case)

### Post-Customization Checklist

After copying files:

- [ ] Verified file exists at destination
- [ ] Compared file size with source (should match)
- [ ] Checked parallel structure is maintained
- [ ] Rebuilt project with AutoMap
- [ ] Verified customization appears in output
- [ ] Checked build log for errors
- [ ] Tested in browser/viewer

### Common Validation Errors

**Error:** Customization doesn't appear in output

**Causes:**
- Wrong folder or file name (case mismatch)
- Missing intermediate directories
- Wrong format name in path
- File copied to wrong override level
- Build cache not cleared

**Solution:**
- Verify exact structure match with installation
- Rebuild with `-c` flag to clear cache
- Check build log for file resolution messages

**Error:** Build fails after customization

**Causes:**
- Syntax error in customized file (ASP, SCSS, XSL)
- Missing dependency or import
- Version incompatibility

**Solution:**
- Validate file syntax
- Compare with installation version
- Check ePublisher build log for specific error

## Advanced Topics

### Multiple Override Levels

Files can exist at multiple override levels simultaneously. ePublisher uses the highest priority match:

**Example:**
```
Installation: C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
Format-level: C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
Target-level: C:\Projects\MyDoc\Targets\Internal\Pages\Connect.asp
```

For "Internal" target, ePublisher uses: Target-level (highest priority)
For other targets, ePublisher uses: Format-level

### Shared Formats Directory

Some XSL files are in `Formats\Shared\` and apply across all formats:

```
C:\Program Files\WebWorks\ePublisher\2024.1\Formats\Shared\common\pages\pagetemplate.xsl
```

Override at format level:
```
C:\Projects\MyDoc\Formats\Shared\common\pages\pagetemplate.xsl
```

### Version Upgrade Considerations

When upgrading ePublisher:

1. Review customized files for compatibility
2. Compare with new installation files
3. Merge new features/fixes into customizations
4. Test all customizations after upgrade
5. Consider updating FormatVersion to {Current}

## Tools and Scripts

### copy-customization.py

Use the provided Python script for validated file copying:

```bash
./scripts/copy-customization.py \
    --source "C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp" \
    --destination "C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"
```

**Features:**
- Validates parallel structure automatically
- Creates directories as needed
- Checks source file exists
- Verifies successful copy
- Provides clear error messages

### Manual Validation

Verify structure manually:

```bash
# Extract relative path from installation file
# Installation: C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
# Relative: WebWorks Reverb 2.0\Pages\Connect.asp

# Verify destination ends with exact relative path
# Destination: C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
# Suffix: WebWorks Reverb 2.0\Pages\Connect.asp ← Match!
```

## Summary

**Key Takeaways:**

1. **Three-level hierarchy:** Target → Format → Installation (highest to lowest priority)
2. **Parallel structure is mandatory:** File and folder names must match exactly
3. **Never modify installation files:** Always copy to project for customizations
4. **Use Base Format Version:** Match installation version with project version
5. **Prefer `_overrides.scss` pattern:** Easier to maintain and upgrade
6. **Test after every customization:** Rebuild and verify changes appear
7. **Document your changes:** Add comments explaining customizations

**When in doubt:**
- Use copy-customization.py script for validation
- Compare paths character-by-character with installation
- Rebuild with `-c` flag to clear cache
- Check build log for file resolution details

---

**Document Version:** 1.0
**Last Updated:** 2025-01-27
**Compatibility:** ePublisher 2024.1+
