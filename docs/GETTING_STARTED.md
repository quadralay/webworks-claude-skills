# Getting Started with ePublisher Skills

This guide helps you start using the ePublisher Claude Code skills for AI-assisted ePublisher development.

## Installation

1. **Clone or download this repository** to your local machine
2. **Navigate to your ePublisher project directory** in Claude Code
3. **Skills activate automatically** when Claude detects relevant tasks

## Available Skills

### Production Ready

- **epublisher-core** - Build automation, project management, AutoMap CLI integration

### Planned (Placeholders)

- epublisher-reverb-css
- epublisher-pdf-page-layout
- epublisher-reverb-toolbar
- epublisher-reverb-header
- epublisher-reverb-footer
- epublisher-reverb-page

## Quick Start

### Building an ePublisher Project

```
Build the project with all targets
```

Claude will automatically use `epublisher-core` to:
1. Detect your AutoMap installation
2. Parse your project file
3. Execute the build
4. Report results

### Managing Source Files

```
List all source documents in the project
```

```
Add a new source file: docs/new-chapter.fm
```

### Customizing Formats

```
Copy the Reverb header template to my project for customization
```

(Note: Customization skills are placeholders in v2.0.0)

## Skill Activation

Claude Code skills activate automatically based on:
- Your request content
- The current project context
- Detected file types and structure

You don't need to explicitly invoke skills - just describe what you want to accomplish.

## Project Structure Requirements

For skills to work effectively, ensure your project follows ePublisher conventions:

```
your-project/
├── YourProject.wep or .wrp    # Project file
├── Source/                     # Source documents
│   └── docs/
├── Format/                     # Format customizations
│   └── Reverb2/
└── Output/                     # Generated output
```

## Getting Help

- **Skill catalog:** See [SKILL_CATALOG.md](SKILL_CATALOG.md) for detailed skill descriptions
- **Contributing:** See [CONTRIBUTING.md](../CONTRIBUTING.md) to implement placeholder skills
- **Issues:** Report problems or request features in the repository issues

## Version Information

Current version: **2.0.0**
- Multi-skill modular architecture
- epublisher-core production ready
- 6 placeholder skills for future implementation

Previous version: 1.0.0 (monolithic, deprecated)

## Next Steps

1. Try building your ePublisher project
2. Explore source management commands
3. Review the skill catalog to understand planned features
4. Consider contributing to implement placeholder skills
