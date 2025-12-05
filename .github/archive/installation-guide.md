# ePublisher Core Skill - Installation Guide

**For Human Developers**

This installation guide is for developers setting up the ePublisher Core skill. The skill itself uses this skill for LLM-based automation of ePublisher projects.

## Prerequisites

### Required Software

**Windows Operating System**
- Windows 10 or later
- Administrator access for ePublisher installation

**WebWorks ePublisher 2024.1 or later**
- Full installation (not Express edition)
- ePublisher AutoMap component installed
- Default installation path: `C:\Program Files\WebWorks\ePublisher\2024.1\`

**Node.js 18.x or later**
- Required for Claude Code CLI
- Download from: https://nodejs.org/

**Git Bash or MSYS2**
- Required for running bash scripts on Windows
- Git Bash included with Git for Windows
- Download Git for Windows: https://gitforwindows.org/

### Optional Software

**Google Chrome**
- Required only for Reverb analyzer skill (browser testing)
- Not needed for core ePublisher automation

## Installation Steps

### 1. Install ePublisher

Download and install WebWorks ePublisher 2024.1 or later from the official website.

**Default installation creates:**
```
C:\Program Files\WebWorks\ePublisher\2024.1\
├── ePublisher AutoMap\
│   ├── WebWorks.Automap.exe (CLI version)
│   └── WebWorks.Automap.Administrator.exe (GUI version)
├── Formats\
│   └── WebWorks Reverb 2.0\
│       ├── Files\
│       ├── *.asp transformation files
│       └── *.xsl stylesheets
└── [other components]
```

### 2. Verify ePublisher Installation

The skill includes a detection script to verify your installation:

```bash
cd plugins/epublisher-automation/skills/epublisher-core/scripts
./detect-installation.sh
```

**Expected output:**
```
ePublisher Installation Detected:
  Version: 2024.1
  AutoMap Path: C:/Program Files/WebWorks/ePublisher/2024.1/ePublisher AutoMap/WebWorks.Automap.exe
  Formats Path: C:/Program Files/WebWorks/ePublisher/2024.1/Formats
```

### 3. Install Claude Code CLI

Follow the official Claude Code installation instructions:
https://docs.claude.com/en/docs/claude-code

### 4. Clone or Set Up Project

```bash
git clone [repository-url] webworks-claude-skills
cd webworks-claude-skills
```

### 5. Configure Permissions (Optional)

Claude Code may ask for permission to execute certain bash commands. You can pre-approve common operations by adding to `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(./scripts/detect-installation.sh:*)",
      "Bash(./scripts/parse-targets.sh:*)",
      "Bash(./scripts/manage-sources.sh:*)"
    ]
  }
}
```

## Verification

### Test AutoMap Execution

Create a test project file or use an existing `.wep` file:

```bash
cd plugins/epublisher-automation/skills/epublisher-core/scripts

# Parse targets from a project
./parse-targets.sh /path/to/project.wep

# List source documents
./manage-sources.sh --list /path/to/project.wep
```

### Test Skill Integration

Launch Claude Code in your project directory:

```bash
claude-code
```

Ask Claude to use the ePublisher skill:
```
"What targets are in the project at C:\MyProject\project.wep?"
```

## Environment Notes

### Windows Path Handling

The scripts automatically handle Windows vs Unix path conversions:
- Windows style: `C:\Path\To\File.wep`
- Unix style (Git Bash): `/c/Path/To/File.wep`

AutoMap requires Windows-style paths with backslashes. The scripts handle conversion automatically.

### Git Bash Configuration

Ensure your Git Bash can access Windows Program Files:

```bash
# Test access
ls "/c/Program Files/WebWorks/ePublisher/2024.1/"
```

If you see errors, check your MSYS2 environment configuration.

## Troubleshooting

### AutoMap Not Found

**Problem:** `detect-installation.sh` cannot find AutoMap

**Solutions:**
1. Verify ePublisher is installed at default location
2. Check installation directory manually:
   ```bash
   ls "/c/Program Files/WebWorks/ePublisher/"
   ```
3. If installed to custom location, update the detection script's search paths

### Permission Denied Errors

**Problem:** Cannot execute bash scripts

**Solutions:**
1. Ensure scripts have execute permissions:
   ```bash
   chmod +x scripts/*.sh
   ```
2. Run Git Bash as Administrator if needed

### Project File Not Found

**Problem:** Scripts cannot find `.wep` file

**Solutions:**
1. Use absolute paths, not relative paths
2. Quote paths containing spaces:
   ```bash
   ./parse-targets.sh "C:\My Projects\project.wep"
   ```
3. Verify file exists:
   ```bash
   test -f "C:\My Projects\project.wep" && echo "Found" || echo "Not found"
   ```

### AutoMap Execution Fails

**Problem:** AutoMap command returns errors

**Solutions:**
1. Verify source documents exist (check project file paths)
2. Ensure output directories are writable
3. Check AutoMap CLI reference for common errors:
   - See `references/cli-reference.md`

## Next Steps

Once installation is verified:

1. **Review the main SKILL.md** for capability overview
2. **Explore reference documentation** in `references/` directory
3. **Test with a sample project** to understand workflow
4. **Review helper scripts** in `scripts/` directory

## Support

For issues specific to:
- **ePublisher software**: Contact WebWorks support
- **Claude Code**: See https://docs.claude.com/en/docs/claude-code
- **This skill**: Open an issue in the project repository

---

**Version**: 1.0.0
**Last Updated**: 2025-11-04
**Target**: ePublisher 2024.1+
