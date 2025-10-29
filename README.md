# ePublisher Claude Code Skills

AI-powered automation for WebWorks ePublisher documentation generation and format customization.

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

### Install as Claude Code Skills

1. **Clone or download this repository:**
   ```bash
   git clone https://github.com/quadralay/epublisher-claude-code-skills.git
   cd epublisher-claude-code-skills
   ```

2. **Copy to Claude Code skills directory:**
   ```bash
   # Windows
   mkdir -p "$APPDATA/Claude/skills"
   cp -r . "$APPDATA/Claude/skills/epublisher"
   ```

3. **Verify installation:**
   - Open Claude Code
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
epublisher-claude-code-skills/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/
│   ├── epublisher-core/         # ✅ Production: Build & project management
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── references/
│   ├── epublisher-reverb-css/   # 🚧 Placeholder
│   │   └── SKILL.md
│   ├── epublisher-pdf-page-layout/  # 🚧 Placeholder
│   │   └── SKILL.md
│   └── [other placeholder skills...]
├── shared/
│   ├── scripts/                 # Shared utilities
│   │   └── copy-customization.py
│   └── references/              # Shared documentation
│       └── FILE_RESOLVER_GUIDE.md
├── docs/
│   ├── SKILL_CATALOG.md         # Complete skill descriptions
│   └── GETTING_STARTED.md       # Usage guide
├── CONTRIBUTING.md              # Contribution guidelines
├── SKILL.md.v1.deprecated       # Legacy monolithic skill
└── README.md                    # This file
```

## Documentation

### Getting Started

- **[GETTING_STARTED.md](docs/GETTING_STARTED.md)** - Installation and basic usage
- **[SKILL_CATALOG.md](docs/SKILL_CATALOG.md)** - Complete skill reference

### Core Skill (epublisher-core)

- **[skills/epublisher-core/SKILL.md](skills/epublisher-core/SKILL.md)** - Skill definition (after Phase 2)
- **[FILE_RESOLVER_GUIDE.md](shared/references/FILE_RESOLVER_GUIDE.md)** - Override hierarchy guide

### Development

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for implementing placeholder skills
- **[PROJECT_PLAN.md](PROJECT_PLAN.md)** - Original v1.0.0 development plan

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

**Multi-Skill Architecture Release**

- ✅ Modular multi-skill architecture
- ✅ epublisher-core skill (production ready)
- ✅ 6 placeholder skills for future implementation
- ✅ Improved context efficiency (30-70% reduction)
- ✅ Comprehensive documentation structure
- ✅ Contribution guidelines for extending skills

### Version 1.0.0 (2025-01-27)

**Initial Monolithic Release** (now deprecated)

- Core AutoMap CLI integration
- Registry-based installation detection
- Project file parsing
- File resolver hierarchy support
- Customization copying with validation
- Comprehensive documentation

---

**Status:** v2.0.0 - Multi-skill architecture with 1 production skill + 6 placeholders

**Generated with Claude Code**
