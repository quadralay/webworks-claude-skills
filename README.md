# WebWorks Agent Skills

AI-powered automation for WebWorks documentation tools including ePublisher, FrameMaker, and WebWorks utilities.

## Overview

This repository provides a collection of specialized Claude Code skills for WebWorks ePublisher development. The modular architecture allows Claude to provide focused, context-aware assistance for different aspects of ePublisher projects.

**Current Version:** 2.0.0 (Multi-Skill Architecture)

### Available Skills

- **epublisher-core** ✅ Production Ready - Build automation, project management, AutoMap CLI integration
- **epublisher-reverb-css** 🚧 Placeholder - Reverb CSS customization
- **epublisher-pdf-page-layout** 🚧 Placeholder - PDF XSL-FO page layout
- **epublisher-reverb-toolbar** 🚧 Placeholder - Reverb toolbar customization
- **epublisher-reverb-header** 🚧 Placeholder - Reverb header customization
- **epublisher-reverb-footer** 🚧 Placeholder - Reverb footer customization
- **epublisher-reverb-page** 🚧 Placeholder - Reverb page template customization

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
- Understand ePublisher's three-level override hierarchy

### 🎨 Customization Support (Planned)

Future specialized skills will provide AI-guided customization for:
- Reverb 2.0 CSS and styling
- PDF page layout and formatting
- Reverb component-specific templates (toolbar, header, footer, page)
- Other ePublisher output formats

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

### Build a Project

```
Build the project with all targets
```

### List Targets

```
What targets are configured in this project?
```

### Manage Sources

```
List all source documents
```

### Customization (Coming Soon)

```
Customize the Reverb header to add a company logo
```

(Customization skills are placeholders in v2.0.0)

## Project Structure

```
webworks-agent-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace manifest
├── plugins/
│   └── epublisher-automation/   # ePublisher automation plugin (self-contained)
│       ├── skills/              # All 7 ePublisher skills
│       │   ├── epublisher-core/         # ✅ Production
│       │   │   ├── SKILL.md
│       │   │   ├── scripts/
│       │   │   └── references/
│       │   ├── epublisher-reverb-css/   # 🚧 Placeholder
│       │   ├── epublisher-pdf-page-layout/
│       │   └── [5 more skills...]
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

### Core Skill

- **[epublisher-core/SKILL.md](plugins/epublisher-automation/skills/epublisher-core/SKILL.md)** - Skill definition
- **[FILE_RESOLVER_GUIDE.md](plugins/epublisher-automation/shared/references/FILE_RESOLVER_GUIDE.md)** - Override hierarchy guide

### Development

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for implementing placeholder skills
- **[PROJECT_PLAN.md](archive/PROJECT_PLAN.md)** - Original v1.0.0 development plan (archived)

## Architecture

### v2.0.0 Multi-Skill Design

The v2.0.0 architecture splits functionality into focused skills:

- **Single Responsibility:** Each skill handles one domain
- **Progressive Disclosure:** Skills load only relevant context
- **Skill Composition:** Multiple skills work together automatically
- **Model-Driven:** Claude chooses appropriate skills based on task

**Benefits:**
- Reduced context window usage (30-70% improvement)
- Faster activation times
- More focused assistance
- Easier to extend and maintain

### v1.0.0 Legacy (Deprecated)

The original monolithic skill is preserved as `SKILL.md.v1.deprecated` for reference.

## Version Compatibility

- **Skill Version:** 2.0.0
- **ePublisher:** 2024.1+ (primary), 2020.2+ (legacy support)
- **AutoMap:** 2024.1+
- **Platform:** Windows only
- **Claude Code:** Latest version recommended

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- How to implement placeholder skills
- Development guidelines
- Testing requirements
- Pull request process

Priority areas:
- Implementing placeholder skills
- Enhancing epublisher-core
- Adding shared utilities
- Improving documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 2.0.0 (2025-01-29)

**Marketplace Plugin Architecture Release**

- ✅ Marketplace plugin structure following Anthropic patterns
- ✅ `epublisher-automation` plugin with 7 skills
- ✅ epublisher-core skill (production ready)
- ✅ 6 placeholder skills for future implementation
- ✅ Foundation for future WebWorks product plugins
- ✅ Improved context efficiency (30-70% reduction)
- ✅ Comprehensive documentation structure

---

**Status:** v2.0.0 - Marketplace architecture with epublisher-automation plugin

**Generated with Claude Code**
