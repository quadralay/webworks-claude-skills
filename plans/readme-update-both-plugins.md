# docs: Update README to include both plugins

## Overview

The main repository README only mentions the `epublisher-automation` plugin. The `markdown-plus-plus` plugin was added in PR #2 but the README was not updated. This plan updates the README to document both plugins with their skills.

**Key Distinction:** The `markdown-plus-plus` plugin is standalone and does NOT require WebWorks ePublisher or AutoMap. It works with any Markdown++ documents.

## Problem Statement

- README only lists epublisher-automation plugin and its 3 skills
- markdown-plus-plus plugin is not mentioned anywhere
- Repository structure diagram is incomplete
- Documentation links don't include markdown-plus-plus
- No clarity that plugins have different requirements

## Proposed Solution

Update README.md to:
1. Document both plugins in the "Available Skills" section (renamed to "Available Plugins")
2. Update Quick Start with installation options for each plugin
3. Clarify that markdown-plus-plus has no ePublisher requirement
4. Update repository structure to show both plugins
5. Add markdown-plus-plus documentation link

## Acceptance Criteria

- [ ] "Available Skills" section renamed to "Available Plugins" with subsections
- [ ] Both plugins listed with their skills and descriptions
- [ ] Quick Start shows installation commands for each plugin separately
- [ ] Clear note that markdown-plus-plus works without ePublisher
- [ ] Repository structure shows both plugin directories
- [ ] Documentation section includes markdown-plus-plus skill link
- [ ] Requirements section clarifies which requirements apply to which plugin

## MVP Implementation

### README.md

Update the following sections:

#### 1. Update tagline (line 8)

```markdown
AI-powered automation for WebWorks ePublisher and Markdown++ document authoring.
```

#### 2. Update "What is This?" section (lines 12-14)

```markdown
## 🎯 What is This?

WebWorks Claude Skills is a collection of Claude Code skills for documentation workflows:

- **ePublisher Automation** - AI assistance for WebWorks ePublisher publishing, testing, and theming
- **Markdown++** - Extended Markdown syntax with variables, conditions, styles, and more
```

#### 3. Replace "Quick Start" section (lines 16-27)

```markdown
## ✨ Quick Start

**For ePublisher workflows** (Claude Code only):
```
/plugin marketplace add quadralay/webworks-claude-skills
/plugin install epublisher-automation@webworks-claude-skills
```

**For Markdown++ documents** (Claude Code or Claude Desktop):
```
/plugin marketplace add quadralay/webworks-claude-skills
/plugin install markdown-plus-plus@webworks-claude-skills
```

Skills activate automatically based on your project context.
```

#### 4. Replace "Available Skills" section (lines 29-33)

```markdown
## 🚀 Available Plugins

### epublisher-automation

Complete automation suite for WebWorks ePublisher workflows.

| Skill | Description |
|-------|-------------|
| 📚 **epublisher** | Core ePublisher knowledge, project structure, file resolver hierarchy |
| 🔨 **automap** | Publishing automation with AutoMap CLI |
| 🧪 **reverb** | Reverb 2.0 testing, CSH analysis, SCSS theming |

**Requires:** Windows, ePublisher 2024.1+, AutoMap (recommended), Claude Code

> **Note:** Claude Desktop is not yet supported for ePublisher automation.

### markdown-plus-plus

Read and write Markdown++ documents with extended syntax.

| Skill | Description |
|-------|-------------|
| 📝 **markdown-plus-plus** | Variables, conditions, custom styles, file includes, aliases, markers, multiline tables |

**Requires:** Any platform, Claude Code or Claude Desktop

> **Note:** Markdown++ is an extended Markdown format. While commonly used with ePublisher, the skill works independently for any Markdown++ document authoring.
```

#### 5. Add Markdown++ example workflow after "Documentation Designer" (after line 61)

```markdown
### Markdown++ Author

```
You: "Add aliases to all headings in this document"
Claude: Generates unique aliases for each heading, preserving existing ones

You: "Validate the Markdown++ syntax"
Claude: Checks for unclosed conditions, invalid variables, duplicate aliases

You: "Create a multiline table for these features"
Claude: Generates properly formatted multiline table with continuation rows
```
```

#### 6. Update "Requirements" section (lines 86-95)

```markdown
## 🔧 Requirements

### epublisher-automation plugin

- **Windows** (ePublisher is Windows-only)
- **[Git for Windows](https://git-scm.com/download/win)** (provides Git Bash for automation scripts)
- **[WebWorks ePublisher 2024.1+](https://webworks.com/products/epublisher/download#download-links)** (Express required; Designer optional)
- **[WebWorks AutoMap](https://webworks.com/products/epublisher/download#download-links)** (highly recommended for full automation)
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** installed and configured

> **Note:** Legacy ePublisher 2020.2+ is supported but 2024.1+ is recommended. WSL is not supported.

### markdown-plus-plus plugin

- **Any platform** (Windows, macOS, Linux)
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** or **[Claude Desktop](https://claude.ai/download)**
- **Python 3.10+** (optional, for validation scripts)
```

#### 7. Update "Repository Structure" section (lines 97-112)

```markdown
## 📂 Repository Structure

```
webworks-claude-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace manifest
├── plugins/
│   ├── epublisher-automation/   # ePublisher workflow automation
│   │   └── skills/
│   │       ├── epublisher/      # Core knowledge
│   │       ├── automap/         # Publishing automation
│   │       └── reverb/          # Output testing
│   └── markdown-plus-plus/      # Markdown++ document authoring
│       └── skills/
│           └── markdown-plus-plus/  # Extended Markdown syntax
├── plans/                       # Development plans
├── CONTRIBUTING.md
└── README.md
```
```

#### 8. Update "Documentation" section (lines 114-124)

```markdown
## 📚 Documentation

### epublisher-automation Skills
- **[epublisher/SKILL.md](plugins/epublisher-automation/skills/epublisher/SKILL.md)** - Core ePublisher knowledge
- **[automap/SKILL.md](plugins/epublisher-automation/skills/automap/SKILL.md)** - Publishing automation
- **[reverb/SKILL.md](plugins/epublisher-automation/skills/reverb/SKILL.md)** - Reverb 2.0 testing

### markdown-plus-plus Skills
- **[markdown-plus-plus/SKILL.md](plugins/markdown-plus-plus/skills/markdown-plus-plus/SKILL.md)** - Extended Markdown syntax
- **[Syntax Reference](plugins/markdown-plus-plus/skills/markdown-plus-plus/references/syntax-reference.md)** - Complete syntax documentation
- **[Examples](plugins/markdown-plus-plus/skills/markdown-plus-plus/references/examples.md)** - Real-world document examples

### Development
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **plans/** - Development plans (historical)
```

#### 9. Update footer (line 141)

```markdown
🛠️ Built for [WebWorks ePublisher](https://www.webworks.com) & Markdown++ | 🤖 Powered by [Claude Code](https://claude.ai/code)
```

## Dependencies

- README.md exists at repository root
- Both plugins are already in marketplace.json
- All skill SKILL.md files exist

## References

- Current README: `README.md`
- Marketplace config: `.claude-plugin/marketplace.json`
- markdown-plus-plus SKILL.md: `plugins/markdown-plus-plus/skills/markdown-plus-plus/SKILL.md`
- epublisher-automation skills: `plugins/epublisher-automation/skills/*/SKILL.md`
