# WebWorks Agent Skills

AI-powered automation for WebWorks documentation tools including ePublisher, FrameMaker, and WebWorks utilities.

## Overview

This repository provides a collection of specialized Claude Code skills for WebWorks ePublisher development. The modular architecture allows Claude to provide focused, context-aware assistance for different aspects of ePublisher projects.

**Current Version:** 1.1.0

### Available Skills

- **epublisher-core** ✅ Production Ready - Build automation, project management, AutoMap CLI integration
- **epublisher-reverb-analyzer** ✅ Production Ready - Automated Reverb 2.0 output testing and validation

See [docs/SKILL_CATALOG.md](docs/SKILL_CATALOG.md) for detailed skill descriptions.

## Features

### 🚀 Build Automation (epublisher-core)

- Automatic AutoMap installation detection via Windows Registry
- Smart command construction with proper parameter handling
- Build progress monitoring and error reporting
- Support for clean builds, targeted generation, and custom deployments

### 📁 Project Management (epublisher-core)

- Parse project files (`.wep`, `.wrp`) to extract targets and formats
- Detect Base Format Version for correct customization sources
- List and manage source documents
- Validate source file paths
- Understand ePublisher's four-level override hierarchy

### 🧪 Output Testing & Validation (epublisher-reverb-analyzer)

- Automated browser testing of Reverb 2.0 output with Puppeteer
- JavaScript runtime validation and error detection
- Console monitoring for errors and warnings
- Context Sensitive Help (CSH) link analysis
- Component inspection (toolbar, header, footer, TOC, content area)
- FormatSettings validation against actual DOM structure
- Comprehensive test reports with actionable findings

## Installation

### Prerequisites

- **Windows operating system** (ePublisher is Windows-only)
- **WebWorks ePublisher 2024.1+** installed with AutoMap component
- **Claude Code** installed and configured
- **Git Bash** or similar Unix-like shell environment

### Install from GitHub

1. **Install via Claude Code plugin marketplace:**
   ```bash
   # After GitHub publication
   /plugin marketplace add quadralay/webworks-agent-skills
   /plugin install epublisher-automation@webworks-agent-skills
   ```

2. **Or install manually (Claude Code):**
   ```bash
   git clone https://github.com/quadralay/webworks-agent-skills.git
   cd webworks-agent-skills

   # Copy to Claude Code plugins directory
   mkdir -p "$APPDATA/Claude/plugins"
   cp -r plugins/epublisher-automation "$APPDATA/Claude/plugins/"
   ```

3. **For Claude Desktop users:**
   ```bash
   git clone https://github.com/quadralay/webworks-agent-skills.git
   cd webworks-agent-skills

   # Copy to Claude Desktop skills directory
   mkdir -p ~/.claude/skills
   cp -r plugins/epublisher-automation ~/.claude/skills/
   ```

   **Note:** The plugin is self-contained with all shared resources included, making it portable across Claude Code and Claude Desktop.

4. **Verify installation:**
   - Open Claude Code or Claude Desktop
   - Skills automatically activate when working with ePublisher projects
   - Test with: "Build this ePublisher project"

### Make Scripts Executable

```bash
chmod +x skills/*/scripts/*.sh shared/scripts/*.py
```

## Quick Start

See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) for detailed usage instructions.

### Example Usage

```
Build the project with all targets
What targets are configured in this project?
List all source documents
Analyze the Reverb output for this project
```

## Project Structure

```
webworks-agent-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace manifest
├── plugins/
│   └── epublisher-automation/   # ePublisher automation plugin (self-contained)
│       ├── skills/              # Production skills
│       │   ├── epublisher-core/         # ✅ Build automation
│       │   │   ├── SKILL.md
│       │   │   ├── scripts/
│       │   │   └── references/
│       │   └── epublisher-reverb-analyzer/  # ✅ Output testing
│       │       ├── SKILL.md
│       │       ├── package.json
│       │       ├── scripts/
│       │       └── references/
│       └── shared/              # Shared utilities (plugin-specific)
│           ├── scripts/
│           └── references/
├── docs/
│   ├── SKILL_CATALOG.md
│   └── GETTING_STARTED.md
├── archive/                     # Historical files
│   ├── PROJECT_PLAN.md
│   └── templates/
├── CONTRIBUTING.md
└── README.md
```

## Documentation

### Getting Started

- **[GETTING_STARTED.md](docs/GETTING_STARTED.md)** - Installation and basic usage
- **[SKILL_CATALOG.md](docs/SKILL_CATALOG.md)** - Complete skill reference

### Skills

- **[epublisher-core/SKILL.md](plugins/epublisher-automation/skills/epublisher-core/SKILL.md)** - Core skill definition
- **[epublisher-reverb-analyzer/SKILL.md](plugins/epublisher-automation/skills/epublisher-reverb-analyzer/SKILL.md)** - Analyzer skill definition
- **[FILE_RESOLVER_GUIDE.md](plugins/epublisher-automation/shared/references/FILE_RESOLVER_GUIDE.md)** - Override hierarchy guide

### Development

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[PROJECT_PLAN.md](archive/PROJECT_PLAN.md)** - Historical development plan (archived)

## Architecture

### Multi-Skill Design

The modular architecture splits functionality into focused skills:

- **Single Responsibility:** Each skill handles one domain
- **Progressive Disclosure:** Skills load only relevant context
- **Skill Composition:** Multiple skills work together automatically
- **Model-Driven:** Claude chooses appropriate skills based on task

**Benefits:**
- Reduced context window usage (30-70% improvement)
- Faster activation times
- More focused assistance
- Easier to extend and maintain

## Version Compatibility

- **Skill Version:** 1.1.0
- **ePublisher:** 2024.1+ (primary), 2020.2+ (legacy support)
- **AutoMap:** 2024.1+
- **Reverb Format:** WebWorks Reverb 2.0 only (analyzer skill)
- **Platform:** Windows only
- **Claude Code:** Latest version recommended

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development guidelines
- Testing requirements
- Pull request process

Priority areas:
- Enhancing existing skills
- Adding new testing capabilities
- Adding shared utilities
- Improving documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.1.0 (2025-11-03)

**Reverb Output Analyzer Release**

- ✅ Added epublisher-reverb-analyzer skill (production ready)
- ✅ Automated browser testing with Puppeteer
- ✅ Console error monitoring and validation
- ✅ Context Sensitive Help (CSH) link analysis
- ✅ Component inspection and FormatSettings validation
- ✅ Comprehensive test report generation
- ✅ Removed placeholder skills for simplified architecture
- ✅ Updated to four-level file resolver hierarchy documentation

### Version 1.0.0 (2025-01-29)

**Initial Release**

- ✅ Marketplace plugin structure following Anthropic patterns
- ✅ `epublisher-automation` plugin with modular skills
- ✅ epublisher-core skill (production ready)
- ✅ Self-contained plugin for easy installation
- ✅ Progressive skill loading for efficient context management
- ✅ Comprehensive documentation and contribution guidelines

---

**Status:** Production - 2 production-ready skills for ePublisher automation and testing

**Generated with Claude Code**
