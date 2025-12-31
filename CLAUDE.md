# CLAUDE.md

## Planning Workflow

Use `/workflows:plan` to create implementation plans:

1. `/workflows:plan <description>` creates `plans/<name>.md`
2. Review and refine the plan locally
3. Create GitHub issue from plan (select "Create GitHub Issue" option)
4. Delete local plan file after issue creation
5. Use `/workflows:work` with the issue URL for implementation

**Single source of truth:** Once a plan becomes a GitHub issue, the issue is authoritative. Local plan files are temporary working documents.
