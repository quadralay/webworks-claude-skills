# WebWorks Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-purple)](https://claude.ai/code)

AI-powered automation for WebWorks ePublisher and Markdown++ document authoring.

![Claude Code publishing an ePublisher project](images/readme-main.png)

## 🎯 What is This?

WebWorks Claude Skills is a collection of Claude Code skills for documentation workflows:

- **ePublisher Automation** - AI assistance for WebWorks ePublisher publishing, testing, and theming
- **Markdown++** - Extended Markdown syntax with variables, conditions, styles, and more

## ✨ Quick Start

```
/plugin marketplace add quadralay/webworks-claude-skills
```

Then install the plugin you need:
- **ePublisher workflows:** `/plugin install epublisher-automation@webworks-claude-skills`
- **Markdown++ documents:** `/plugin install markdown-plus-plus@webworks-claude-skills`

Skills activate automatically based on your project context.

## 🚀 Available Plugins

| Plugin | Claude Code | Claude Desktop | Platform |
|--------|-------------|----------------|----------|
| epublisher-automation | ✅ | ❌ | Windows only |
| markdown-plus-plus | ✅ | ✅ | Any platform |

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

## 🎮 Example Workflows

### Technical Writer

```
You: "Publish the project with all targets"
Claude: Detects AutoMap, constructs command, publishes output, reports results

You: "What targets are configured?"
Claude: Parses project file, lists all targets with their output formats

You: "Test the Reverb output for JavaScript errors"
Claude: Launches browser, checks console, reports any issues
```

### Documentation Designer

```
You: "Extract the color variables from this Reverb theme"
Claude: Parses SCSS, lists all color variables with current values

You: "Generate overrides to change the primary color to #2563eb"
Claude: Creates SCSS override file with proper variable mappings

You: "Check if the CSH links are working"
Claude: Analyzes all context-sensitive help links, reports broken ones
```

### Markdown++ Author

```
You: "Add aliases to all headings in this document"
Claude: Generates unique aliases for each heading, preserving existing ones

You: "Validate the Markdown++ syntax"
Claude: Checks for unclosed conditions, invalid variables, duplicate aliases

You: "Create a multiline table for these features"
Claude: Generates properly formatted multiline table with continuation rows
```

## 💡 Why WebWorks Claude Skills?

### Traditional Approach
```
1. Open command prompt
2. Navigate to AutoMap directory
3. Remember correct syntax and parameters
4. Manually check output for errors
5. Open browser DevTools to debug issues
```

### With WebWorks Claude Skills
```
You: "Publish the project and check for errors"
Claude: Handles everything, reports results
```

**WebWorks Claude Skills provides:**
- ✅ Natural language control of ePublisher workflows
- ✅ Automatic tool detection and configuration
- ✅ Intelligent error detection and reporting
- ✅ Theme customization without manual SCSS editing

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

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Priority areas:**
- Enhancing existing skills
- Adding new design skills for Reverb
- Adding design skills for other output formats
- Adding content generation skills

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Automate your documentation workflow with the power of AI.**

🛠️ Built for [WebWorks ePublisher](https://www.webworks.com) & Markdown++ | 🤖 Powered by [Claude Code](https://claude.ai/code)
