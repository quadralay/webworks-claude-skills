# Contributing to WebWorks Claude Skills

## How to Contribute

- Enhance existing skills
- Add new skills for other formats or workflows
- Improve helper scripts
- Report bugs and suggest features

## Repository Structure

```
plugins/webworks-claude-skills/
├── plugin.json
└── skills/
    └── skill-name/
        ├── SKILL.md           # Skill definition
        ├── scripts/           # Helper scripts (optional)
        │   └── lib/           # Shared Python modules
        └── references/        # Reference documentation
```

## SKILL.md Authoring

Avoid these character sequences in markdown tables - they cause bash parsing errors during skill loading:

- `` `!` `` (backtick-exclamation-backtick)
- `` `$` `` (backtick-dollar-backtick)

Use bullet lists instead of tables for syntax documentation with special characters.

See [docs/solutions/bash-syntax-errors-in-skill-tables.md](docs/solutions/bash-syntax-errors-in-skill-tables.md) for details.

## Development Guidelines

- **Python scripts:** Parsing, validation, complex logic
- **Shell scripts:** Program wrappers with error handling
- **Documentation:** Clear language with examples
- **Testing:** Validate with real ePublisher projects

## Pull Requests

1. Fork and create a feature branch
2. Test thoroughly
3. Submit PR with clear description

## License

Contributions are licensed under the project's MIT License.
