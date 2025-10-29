# Contributing to ePublisher Skills

Thank you for your interest in contributing to the ePublisher Claude Code Skills project!

## Project Status

**Current Version:** 2.0.0
**Architecture:** Multi-skill modular system

- **Production:** 1 skill (epublisher-core)
- **Planned:** 6 placeholder skills

## How to Contribute

### 1. Implementing Placeholder Skills

The following skills are defined but not yet implemented:

- epublisher-reverb-css
- epublisher-pdf-page-layout
- epublisher-reverb-toolbar
- epublisher-reverb-header
- epublisher-reverb-footer
- epublisher-reverb-page

#### Implementation Steps

1. **Research the domain**
   - Study ePublisher documentation for the skill area
   - Review existing customization files
   - Understand the file resolver pattern for that format

2. **Define skill scope**
   - What specific tasks should this skill handle?
   - What helper scripts are needed?
   - What reference documentation is required?

3. **Create skill content**
   - Expand the placeholder SKILL.md with detailed instructions
   - Add helper scripts to the skill's `scripts/` directory
   - Include reference documentation in `references/`
   - Add template examples if applicable

4. **Test thoroughly**
   - Validate with real ePublisher projects
   - Test file resolution and override hierarchy
   - Verify integration with epublisher-core

5. **Update documentation**
   - Update skill status in SKILL_CATALOG.md
   - Add usage examples to GETTING_STARTED.md
   - Document any new patterns or conventions

#### Skill Structure

Each skill should follow this structure:

```
skills/your-skill-name/
├── SKILL.md              # Main skill definition
├── scripts/              # Helper scripts (optional)
│   └── helper.sh
├── references/           # Reference documentation (optional)
│   └── GUIDE.md
└── templates/            # Template files (optional)
    └── example.scss
```

### 2. Enhancing epublisher-core

Contributions to improve the core skill are welcome:

- Additional AutoMap CLI features
- Enhanced error handling
- New helper scripts
- Documentation improvements

### 3. Shared Utilities

Contributions to shared utilities benefit all skills:

- Enhanced copy-customization.py features
- Additional validation scripts
- File resolver utilities
- Testing frameworks

## Development Guidelines

### SKILL.md Format

Follow this structure for SKILL.md files:

```markdown
---
name: skill-kebab-case-name
description: Brief description (max 1024 chars)
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
metadata:
  version: "2.0.0"
  status: "production|beta|placeholder"
  dependencies: ["epublisher-core"]
---

# Skill Title

## Overview
Brief description of the skill's purpose

## Key Concepts
Important concepts users need to understand

## Common Tasks
Examples of tasks this skill handles

## Helper Scripts
Description of included scripts

## Reference Documentation
Links to additional resources
```

### Coding Standards

- **Shell scripts:** Use bash, include error handling, add comments
- **Python scripts:** Follow PEP 8, use type hints, include docstrings
- **Documentation:** Use clear, concise language with examples

### Testing

Before submitting:

1. Test with real ePublisher projects (multiple versions if possible)
2. Verify file paths work on Windows
3. Validate helper scripts execute correctly
4. Check skill activation works as expected

## Submitting Contributions

### Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Create a Pull Request

### Pull Request Guidelines

- **Title:** Clear, descriptive summary
- **Description:** Explain what, why, and how
- **Testing:** Describe testing performed
- **Documentation:** Note any doc updates needed

Example PR description:

```
## Summary
Implements epublisher-reverb-css skill for Reverb 2.0 CSS customization

## Changes
- Complete SKILL.md with CSS customization instructions
- Add css-helper.sh script for SCSS validation
- Include Reverb.scss reference documentation
- Add example customization templates

## Testing
- Tested with Reverb 2.0 projects (base formats 18.0.2 and 18.0.3)
- Validated CSS override hierarchy
- Verified integration with epublisher-core

## Documentation
- Updated SKILL_CATALOG.md status
- Added CSS customization examples to GETTING_STARTED.md
```

## Versioning

This project follows Semantic Versioning:

- **Major (X.0.0):** Breaking changes, major architecture changes
- **Minor (x.X.0):** New skills, new features, backward compatible
- **Patch (x.x.X):** Bug fixes, documentation, minor improvements

## Questions?

- Review existing skills for patterns and conventions
- Check SKILL_CATALOG.md for skill status and scope
- Open an issue for clarification

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

Thank you for helping make ePublisher development more accessible and efficient!
