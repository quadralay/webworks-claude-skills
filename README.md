# WebWorks Claude Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-purple)](https://claude.ai/code)

AI-powered skills for WebWorks ePublisher and Markdown++ authoring.

![Claude Code publishing an ePublisher project](images/readme-main.png)

## Install

In Claude Code, use `/plugin` to add the marketplace and install:

1. Add marketplace: `https://github.com/quadralay/webworks-claude-skills`
2. Install the `webworks-claude-skills` plugin

All skills activate automatically based on your project context.

## Skills

| Skill | What It Does |
|-------|--------------|
| **markdown-plus-plus** | Authoritative reference for Markdown++ syntax (variables, conditions, styles, aliases, includes) |
| **epublisher** | ePublisher project knowledge, file resolver hierarchy, customization patterns |
| **automap** | Automated publishing with AutoMap CLI |
| **reverb** | Reverb 2.0 output testing, CSH analysis, SCSS theming |

## Example Workflows

**Publishing:**
```
You: "Publish the project with all targets"
Claude: Detects AutoMap, runs publish, reports results
```

**Testing:**
```
You: "Test the Reverb output for JavaScript errors"
Claude: Launches browser, checks console, reports issues
```

**Markdown++ authoring:**
```
You: "Fix the Markdown++ syntax in this file"
Claude: Validates syntax, corrects errors using authoritative reference
```

**Theming:**
```
You: "Change the primary color to #2563eb"
Claude: Generates SCSS override file with proper variable mappings
```

## Requirements

| Skill | Platform | Requirements |
|-------|----------|--------------|
| markdown-plus-plus | Any | Claude Code or Claude Desktop |
| epublisher | Windows | ePublisher 2024.1+ |
| automap | Windows | ePublisher + AutoMap |
| reverb | Windows | ePublisher + browser |

## Migration from v1.x

If you previously installed the separate plugins, use `/plugin` to:

1. Uninstall `epublisher-automation` and `markdown-plus-plus`
2. Install the new `webworks-claude-skills` plugin

### Invocation changes

| Old (v1.x) | New (v2.x) |
|------------|------------|
| `epublisher-automation:automap` | `webworks-claude-skills:automap` |
| `epublisher-automation:epublisher` | `webworks-claude-skills:epublisher` |
| `epublisher-automation:reverb` | `webworks-claude-skills:reverb` |
| `markdown-plus-plus:markdown-plus-plus` | `webworks-claude-skills:markdown-plus-plus` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE).

---

🛠️ Built for [WebWorks ePublisher](https://www.webworks.com) | 🤖 Powered by [Claude Code](https://claude.ai/code)
