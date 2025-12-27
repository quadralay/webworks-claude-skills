# Contributing to WebWorks Claude Skills

## How to Contribute

- Enhance existing skills (epublisher, automap, reverb)
- Add new skills for other formats
- Add new helper scripts
- Report bugs and suggest features

## Skill Structure

```
skills/skill-name/
├── SKILL.md          # Skill definition (for Claude)
├── scripts/          # Helper scripts
└── references/       # Reference documentation
```

## SKILL.md Authoring

Avoid these character sequences in markdown tables - they cause bash parsing errors during skill loading:

- `` `!` `` (backtick-exclamation-backtick)
- `` `$` `` (backtick-dollar-backtick)

Use bullet lists instead of tables for syntax documentation with special characters.

See [docs/solutions/bash-syntax-errors-in-skill-tables.md](docs/solutions/bash-syntax-errors-in-skill-tables.md) for details.

## Development Guidelines

- **Python scripts:** Use for parsing files and complex behavior
- **Shell scripts:** Use bash for program wrapper scripts and include error handling
- **Documentation:** Clear language with examples, follow pattern in other skills
- **Testing:** Validate with real ePublisher projects

## Pull Requests

1. Fork and create a feature branch
2. Test thoroughly
3. Submit PR with clear description

## License

Contributions are licensed under the project's MIT License.
