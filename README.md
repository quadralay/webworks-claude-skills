# WebWorks Agent Skills

AI-powered automation for WebWorks documentation tools including support for ePublisher project manipulation and AutoMap CLI automation.

## Overview

This repository provides a collection of specialized Claude Code skills for WebWorks ePublisher design, automation, and analysis. The modular architecture allows Claude to provide focused, context-aware assistance for different aspects of ePublisher projects.

**Current Version:** 1.0.0

### Available Skills

- **epublisher** - Core ePublisher knowledge, project structure, file resolver hierarchy
- **automap** - Build automation with AutoMap CLI
- **reverb** - Reverb 2.0 testing, CSH analysis, SCSS theming

## Features

### 📚 Core Knowledge (epublisher)

- Understand ePublisher's four-level file resolver hierarchy
- Parse project files (`.wep`, `.wrp`) to extract targets and formats
- Detect Base Format Version for correct customization sources
- List and manage source documents

### 🚀 Build Automation (automap)

- Automatic AutoMap installation detection
- Smart command construction with proper parameter handling
- Build progress monitoring and error reporting
- Support for clean builds, targeted generation, and custom deployments

### 🧪 Output Testing & Validation (reverb)

- Automated browser testing of Reverb 2.0 output with Puppeteer
- JavaScript runtime validation and error detection
- Console monitoring for errors and warnings
- Context Sensitive Help (CSH) link analysis
- Component inspection (toolbar, header, footer, TOC, content area)
- SCSS theme variable extraction and color override generation

## Installation

### Prerequisites

- **Windows operating system** (ePublisher is Windows-only)
- **WebWorks ePublisher 2024.1+** (Express or Designer required; AutoMap optional for automated publishing)
- **Claude Code** installed and configured

### Install from Claude Code

```
/plugin marketplace add quadralay/webworks-agent-skills
/plugin install epublisher-automation@webworks-agent-skills
```

That's it! Skills activate automatically when working with ePublisher projects.

**Note:** Claude Desktop is not yet supported.

## Quick Start

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
│   └── epublisher-automation/   # ePublisher automation plugin
│       └── skills/
│           ├── epublisher/      # Core knowledge
│           │   ├── SKILL.md
│           │   ├── scripts/
│           │   └── references/
│           ├── automap/         # Build automation
│           │   ├── SKILL.md
│           │   ├── scripts/
│           │   └── references/
│           └── reverb/          # Reverb 2.0 testing and design
│               ├── SKILL.md
│               ├── package.json
│               └── scripts/
├── plans/                       # Development plans
├── archive/                     # Historical files
├── CONTRIBUTING.md
└── README.md
```

## Documentation

### Skills

- **[epublisher/SKILL.md](plugins/epublisher-automation/skills/epublisher/SKILL.md)** - Core ePublisher knowledge
- **[automap/SKILL.md](plugins/epublisher-automation/skills/automap/SKILL.md)** - Build automation
- **[reverb/SKILL.md](plugins/epublisher-automation/skills/reverb/SKILL.md)** - Reverb 2.0 testing

### Development

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[plans/](plans/)** - Development plans (historical)

## Version Compatibility

- **Skill Version:** 1.0.0
- **ePublisher:** 2024.1+ (primary), 2020.2+ (legacy support)
- **AutoMap:** 2024.1+ (primary), 2020.2+ (legacy support)
- **Reverb Format:** WebWorks Reverb 2.0 only (reverb skill)
- **Platform:** Windows only
- **Claude Code:** Latest version recommended

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development guidelines
- Testing requirements
- Pull request process

Priority areas:
- Enhancing existing skills
- Adding new design skills for reverb
- Adding design skills for other output formats
- Adding content generation skills

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.0.0 (2025-12-03)

**Initial Release**

- 3 layered skills: `epublisher`, `automap`, `reverb`
- Core ePublisher knowledge and file resolver hierarchy
- AutoMap CLI build automation
- Reverb 2.0 browser testing with Puppeteer
- CSH link analysis
- SCSS theme extraction and color override generation

---

**Status:** Production - 3 skills for ePublisher automation, design, and testing

**Generated with Claude Code**
