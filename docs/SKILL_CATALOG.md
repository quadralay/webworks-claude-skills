# WebWorks Agent Skills Catalog

This repository contains specialized Claude Code skills for WebWorks ePublisher AutoMap development, testing, and quality assurance workflows.

## Overview

The WebWorks Agent Skills provide modular, focused AI assistance for different aspects of ePublisher project development. Skills are organized into plugins by functional area and designed to work together.

## Plugin Organization

All ePublisher skills are currently organized in the `epublisher-automation` plugin located at `plugins/epublisher-automation/`.

## Available Skills

### epublisher-core
**Status:** ✅ Production Ready
**Location:** `plugins/epublisher-automation/skills/epublisher-core/`

Core ePublisher AutoMap functionality including:
- Installation detection and AutoMap CLI integration
- Build automation and output generation
- Project file parsing (targets, formats, sources)
- Source document management
- Four-level file resolver pattern understanding

**Use when:** Building projects, running AutoMap, parsing project files, managing sources

### epublisher-reverb-analyzer
**Status:** ✅ Production Ready
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-analyzer/`

Automated testing and analysis of WebWorks Reverb 2.0 output including:
- Headless browser testing with Puppeteer
- JavaScript runtime validation
- Console error monitoring
- Context Sensitive Help (CSH) link analysis
- Component inspection (toolbar, header, footer, TOC, content)
- FormatSettings validation

**Use when:** Testing Reverb output, validating component configuration, catching issues before deployment

**Format Support:** WebWorks Reverb 2.0 only (does not support legacy Reverb 1.x)

## Skill Dependencies

- **epublisher-reverb-analyzer** depends on **epublisher-core** for:
  - Project file parsing
  - File resolver pattern understanding
  - Installation path detection

## Version History

- **v1.1.0** - Added Reverb Output Analyzer skill
- **v1.0.0** - Initial release with epublisher-core

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on contributing to this project.
