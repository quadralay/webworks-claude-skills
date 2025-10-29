# ePublisher AutoMap Claude Code Skill

AI-powered automation for WebWorks ePublisher documentation generation and format customization.

## Overview

This Claude Code Skill integrates WebWorks ePublisher AutoMap CLI with Claude Code, enabling developers and technical writers to:

- **Run AutoMap builds** through natural language requests
- **Customize format files** (ASP templates, SCSS styles, XSL transforms) with AI guidance
- **Navigate the file resolver hierarchy** automatically
- **Manage project files** with intelligent assistance
- **Accelerate documentation workflows** through automation

## Features

### 🚀 AutoMap CLI Integration

- Automatic installation detection via Windows Registry
- Smart command construction with proper parameter handling
- Build progress monitoring and error reporting
- Support for clean builds, targeted generation, and custom deployments

### 📁 File Resolver Intelligence

- Understands ePublisher's three-level override hierarchy:
  1. Target-specific overrides (highest priority)
  2. Format-level overrides
  3. Installation defaults (fallback)
- Validates parallel folder structure requirements
- Ensures exact file and folder name matching

### 🎨 Customization Support

- Copy format files from installation to project with structure validation
- Apply customizations to ASP templates, SCSS stylesheets, and XSL transforms
- Implement best-practice override patterns (e.g., `_overrides.scss`)
- Document changes with clear comments

### 📋 Project Management

- Parse project files (`.wep`, `.wrp`) to extract targets and formats
- Detect Base Format Version for correct customization sources
- List and manage source documents
- Validate source file paths

## Installation

### Prerequisites

- **Windows operating system** (ePublisher is Windows-only)
- **WebWorks ePublisher 2024.1+** installed with AutoMap component
- **Claude Code** installed and configured
- **Git Bash** or similar Unix-like shell environment

### Install as Claude Code Skill

1. **Clone or download this repository:**
   ```bash
   git clone https://github.com/quadralay/epublisher-claude-code-skills.git
   cd epublisher-claude-code-skills
   ```

2. **Copy to Claude Code skills directory:**
   ```bash
   # Windows
   mkdir -p "$APPDATA/Claude/skills"
   cp -r . "$APPDATA/Claude/skills/epublisher-automap"
   ```

3. **Verify installation:**
   - Open Claude Code
   - The skill should automatically activate when you mention "ePublisher", "AutoMap", or work with `.wep`/`.wrp` files

### Make Scripts Executable

Ensure helper scripts have execute permissions:

```bash
chmod +x scripts/*.sh scripts/*.py
```

## Usage

### Basic Workflows

#### Generate Documentation Output

**You:** "Build the Reverb target for this project"

**Claude:**
- Locates project file (`.wep` or `.wrp`)
- Detects AutoMap installation
- Identifies target name
- Constructs and executes build command
- Reports success/failure with output location

#### Customize Header Template

**You:** "I want to modify the header template to add our company logo"

**Claude:**
- Identifies header file (`Connect.asp` for Reverb)
- Locates source in installation
- Asks for customization scope (format-level or target-specific)
- Creates parallel directory structure
- Copies file to project
- Guides you through logo customization

#### Change Color Scheme

**You:** "Change the primary color scheme for Reverb output to blue"

**Claude:**
- Copies `skin.scss` to project if needed
- Creates `_overrides.scss` file
- Adds color variable overrides
- Imports overrides in `skin.scss`
- Offers to rebuild project

#### List Available Targets

**You:** "What targets are configured in this project?"

**Claude:**
- Parses project file
- Extracts all `<Format>` elements
- Lists target names, format names, and output directories
- Can show detailed target information

### Script Usage

All scripts can also be used directly:

#### Detect AutoMap Installation

```bash
./scripts/detect-installation.sh
# Output: C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe

# Specific version
./scripts/detect-installation.sh --version 2020.2
```

#### Run AutoMap Build

```bash
./scripts/automap-wrapper.sh -c -l project.wep

# Build specific target
./scripts/automap-wrapper.sh -c -l -t "WebWorks Reverb 2.0" project.wep

# Custom deployment folder
./scripts/automap-wrapper.sh --deployfolder "C:\Output" project.wep
```

#### Parse Project Targets

```bash
# List all targets
./scripts/parse-targets.sh project.wep

# Detailed target information
./scripts/parse-targets.sh --list project.wep

# JSON output
./scripts/parse-targets.sh --json project.wep

# Get Base Format Version
./scripts/parse-targets.sh --version project.wep
```

#### Manage Source Files

```bash
# List all source documents
./scripts/manage-sources.sh --list project.wep

# Validate source paths exist
./scripts/manage-sources.sh --validate project.wep

# Toggle document inclusion
./scripts/manage-sources.sh --toggle "Source\chapter1.md" project.wep
```

#### Copy Customization Files

```bash
./scripts/copy-customization.py \
    --source "C:\Program Files\WebWorks\ePublisher\2024.1\Formats\WebWorks Reverb 2.0\Pages\Connect.asp" \
    --destination "C:\Projects\MyDoc\Formats\WebWorks Reverb 2.0\Pages\Connect.asp"

# Validate structure without copying
./scripts/copy-customization.py --source "..." --destination "..." --validate-only

# Dry run
./scripts/copy-customization.py --source "..." --destination "..." --dry-run
```

## Project Structure

```
epublisher-claude-code-skills/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata for marketplace
├── scripts/
│   ├── detect-installation.sh   # AutoMap installation detection
│   ├── automap-wrapper.sh       # AutoMap CLI wrapper
│   ├── parse-targets.sh         # Project file parsing
│   ├── manage-sources.sh        # Source document management
│   ├── copy-customization.py    # File copying with validation
│   └── README.md                # Script documentation
├── references/
│   ├── AUTOMAP_INSTALLATION_DETECTION.md  # Installation detection guide
│   └── FILE_RESOLVER_GUIDE.md   # Override hierarchy documentation
├── templates/
│   ├── asp/
│   │   └── header-customization-example.asp
│   ├── scss/
│   │   └── _overrides-example.scss
│   ├── xsl/
│   │   └── content-customization-example.xsl
│   └── README.md                # Template usage guide
├── SKILL.md                     # Main skill definition
├── PROJECT_PLAN.md              # Development plan and roadmap
├── README.md                    # This file
└── LICENSE                      # MIT License
```

## Documentation

### Core Documentation

- **[SKILL.md](SKILL.md)** - Complete skill definition with ePublisher knowledge
- **[PROJECT_PLAN.md](PROJECT_PLAN.md)** - Detailed project plan and implementation phases

### Reference Guides

- **[AUTOMAP_INSTALLATION_DETECTION.md](references/AUTOMAP_INSTALLATION_DETECTION.md)** - Registry-based installation detection
- **[FILE_RESOLVER_GUIDE.md](references/FILE_RESOLVER_GUIDE.md)** - Override hierarchy and parallel structure guide

### Templates

- **[SCSS Overrides Example](templates/scss/_overrides-example.scss)** - Complete SCSS customization template
- **[ASP Header Example](templates/asp/header-customization-example.asp)** - ASP template customization patterns
- **[XSL Transform Example](templates/xsl/content-customization-example.xsl)** - XSLT customization patterns

## Key Concepts

### Base Format Version

The Base Format Version determines which ePublisher installation version to use when copying format files for customizations.

**Extraction Logic:**
```
IF FormatVersion == "{Current}" THEN
    Base Format Version = RuntimeVersion
ELSE
    Base Format Version = FormatVersion
END IF
```

**Usage:**
Always copy customization files from the installation directory matching the Base Format Version:
```
C:\Program Files\WebWorks\ePublisher\[Base Format Version]\Formats\...
```

### Override Hierarchy

ePublisher resolves files using a three-level priority system:

1. **Target-specific** (highest): `Targets\[TargetName]\[structure]\`
2. **Format-level** (medium): `Formats\[FormatName]\[structure]\`
3. **Installation** (fallback): `C:\Program Files\WebWorks\ePublisher\[version]\Formats\[structure]\`

### Parallel Folder Structure

**Critical Requirement:** File and folder names MUST exactly match installation hierarchy.

**Correct:**
```
Installation: C:\...\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
Project:      C:\...\Formats\WebWorks Reverb 2.0\Pages\Connect.asp
```

**Incorrect:**
```
# Wrong case
C:\...\Formats\WebWorks Reverb 2.0\pages\Connect.asp

# Missing folder
C:\...\Formats\WebWorks Reverb 2.0\Connect.asp
```

## Best Practices

### SCSS Customizations

1. Copy `skin.scss` to project
2. Create `_overrides.scss` in same directory
3. Place ALL custom styles in `_overrides.scss`
4. Add `@import "overrides";` to END of `skin.scss`
5. Never modify original rules directly

**Benefits:** Easier upgrades, clear separation of custom vs. default

### ASP Customizations

1. Copy template file from installation
2. Add comments documenting all changes
3. Validate HTML output
4. Test JavaScript in multiple browsers
5. Consider accessibility (ARIA, keyboard navigation)

### XSL Customizations

1. Remember: XSLT 1.0 only (no 2.0+ features)
2. Document template purpose and changes
3. Validate XML well-formedness
4. Test with various content types
5. Keep transformations simple for performance

### General Guidelines

- Always use Base Format Version for source files
- Test after every customization
- Rebuild with `-c` flag when in doubt
- Document all changes with comments
- Version control your customizations

## Troubleshooting

### AutoMap Not Found

**Problem:** Cannot locate AutoMap executable

**Solutions:**
- Verify ePublisher AutoMap is installed
- Check Windows Registry keys
- Run `scripts/detect-installation.sh --verbose`
- Manually specify installation path if needed

### Customization Not Appearing

**Problem:** Modified files don't affect output

**Solutions:**
- Verify exact folder/file name match (case-sensitive)
- Check parallel structure is correct
- Rebuild with `-c` flag to clear cache
- Compare path with installation structure
- Review build log for file resolution

### Build Failures

**Problem:** AutoMap returns errors

**Solutions:**
- Check syntax in customized files
- Verify source document paths
- Review deployment folder permissions
- Examine build log for specific errors
- Try clean build with `-c -l` flags

### Script Execution Errors

**Problem:** Scripts fail to run

**Solutions:**
- Ensure execute permissions: `chmod +x scripts/*.sh`
- Verify Git Bash or compatible shell
- Check Python 3 installed (for `.py` scripts)
- Run with `--verbose` flag for details

## Version Compatibility

- **Skill Version:** 1.0.0
- **ePublisher:** 2024.1+ (primary), 2020.2+ (legacy support)
- **AutoMap:** 2024.1+
- **Platform:** Windows only
- **Claude Code:** Latest version recommended

## Performance Considerations

- **AutoMap builds:** 2-10 minutes for large projects (use 10-minute timeout)
- **Registry detection:** Fast and reliable (< 1 second)
- **File operations:** Near-instant for single files
- **Script execution:** Typically < 1 second

## Security

### Permissions Required

- **Read:** Windows Registry, ePublisher installation directory
- **Write:** Project directory for customizations
- **Execute:** AutoMap CLI via Bash

### Best Practices

- Only use skill in trusted workspaces
- Verify AutoMap is from official WebWorks installer
- Review generated commands before execution
- Sanitize user-provided paths
- Don't modify installation files directly

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly
4. **Document** new features or changes
5. **Commit** with clear messages
6. **Push** to your branch
7. **Open** a Pull Request

### Development Setup

```bash
# Clone repository
git clone https://github.com/quadralay/epublisher-claude-code-skills.git
cd epublisher-claude-code-skills

# Make scripts executable
chmod +x scripts/*.sh scripts/*.py

# Test scripts
./scripts/detect-installation.sh --help
./scripts/automap-wrapper.sh --help
./scripts/parse-targets.sh --help
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **WebWorks** / **Quadralay Corporation** - ePublisher platform
- **Anthropic** - Claude Code framework and skills system
- **Community contributors** - Testing, feedback, and improvements

## Support

- **Issues:** [GitHub Issues](https://github.com/quadralay/epublisher-claude-code-skills/issues)
- **Documentation:** [Wiki](https://github.com/quadralay/epublisher-claude-code-skills/wiki)
- **ePublisher Support:** [WebWorks Support](https://www.webworks.com/support/)

## Roadmap

### Future Enhancements

- [ ] Support for additional ePublisher formats (CHM, Eclipse, EPUB)
- [ ] Automated testing suite for all scripts
- [ ] Visual customization preview before building
- [ ] Template library expansion
- [ ] Multi-language documentation support
- [ ] Integration with CI/CD pipelines
- [ ] GUI wrapper for script commands

### Planned Features

- **Phase 3:** Comprehensive testing and edge case handling
- **Phase 4:** Claude Code Marketplace distribution
- **Future:** Advanced customization patterns and workflows

## Changelog

### Version 1.0.0 (2025-01-27)

**Initial Release**

- ✅ Core AutoMap CLI integration
- ✅ Registry-based installation detection
- ✅ Project file parsing (targets, formats, sources)
- ✅ File resolver hierarchy support
- ✅ Customization copying with validation
- ✅ Base Format Version detection
- ✅ Comprehensive documentation
- ✅ Example templates (ASP, SCSS, XSL)
- ✅ Helper scripts for all operations

---

**Status:** ✅ Production Ready (v1.0.0)

**Generated with Claude Code**
