# CLAUDE.md

## Workflow Commands

This project uses workflow commands from [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin).

### Plan

Use `/workflows:plan` to create implementation plans:

1. `/workflows:plan <description>` creates `plans/<name>.md`
2. Review and refine the plan locally
3. Create GitHub issue from plan (select "Create GitHub Issue" option)
4. Delete local plan file after issue creation

**Single source of truth:** Once a plan becomes a GitHub issue, the issue is authoritative. Local plan files are temporary working documents.

### Work

Use `/workflows:work` to implement from an issue:

1. `/workflows:work <issue number or URL>`
2. Creates feature branch from main
3. Implements changes following the plan
4. Commits and creates PR linking to issue

### Review

Use `/workflows:review` for code review:

1. `/workflows:review` (on PR branch) or `/workflows:review <PR number>`
2. Runs parallel review agents (simplicity, patterns, security, etc.)
3. Synthesizes findings by severity (P1/P2/P3)
4. Offers to simplify or fix issues before merge
