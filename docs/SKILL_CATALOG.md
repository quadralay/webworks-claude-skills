# WebWorks Agent Skills Catalog

This repository contains multiple specialized Claude Code skills for WebWorks ePublisher AutoMap development and customization workflows.

## Overview

The WebWorks Agent Skills provide modular, focused AI assistance for different aspects of ePublisher project development. Skills are organized into plugins by functional area and designed to work together seamlessly.

## Plugin Organization

All ePublisher skills are currently organized in the `epublisher-automation` plugin located at `plugins/epublisher-automation/`.

## Production Skills

### epublisher-core
**Status:** ✅ Production Ready
**Location:** `plugins/epublisher-automation/skills/epublisher-core/`

Core ePublisher AutoMap functionality including:
- Installation detection and AutoMap CLI integration
- Build automation and output generation
- Project file parsing (targets, formats, sources)
- Source document management
- File resolver pattern understanding

**Use when:** Building projects, running AutoMap, parsing project files, managing sources

## Placeholder Skills (Planned)

The following skills are planned for future implementation. They currently provide minimal functionality and serve as placeholders for the v2.0.0 architecture.

### epublisher-reverb-css
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-css/`

General Reverb 2.0 CSS and SCSS customization.

**Planned features:** Color schemes, typography, spacing, SCSS variables

### epublisher-pdf-page-layout
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-pdf-page-layout/`

PDF output page layout customization using XSL-FO.

**Planned features:** Page dimensions, margins, headers/footers, page sequences

### epublisher-reverb-toolbar
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-toolbar/`

Reverb 2.0 toolbar customization (Connect.asp).

**Planned features:** Button configuration, toolbar layout, event handling

### epublisher-reverb-header
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-header/`

Reverb 2.0 page header customization (Header.asp).

**Planned features:** Header content, branding, layout, styling

### epublisher-reverb-footer
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-footer/`

Reverb 2.0 page footer customization (Footer.asp).

**Planned features:** Footer content, copyright notices, layout, styling

### epublisher-reverb-page
**Status:** 🚧 Placeholder
**Location:** `plugins/epublisher-automation/skills/epublisher-reverb-page/`

Reverb 2.0 overall page template customization (Page.asp).

**Planned features:** Page structure, content areas, navigation, responsive design

## Skill Dependencies

All customization skills depend on `epublisher-core` for:
- Project detection and validation
- File resolver pattern understanding
- Installation path detection
- Base Format Version detection

## Version History

- **v2.0.0** - Multi-skill architecture with epublisher-core production + 6 placeholders
- **v1.0.0** - Monolithic epublisher-automap skill (deprecated)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on implementing placeholder skills.
