# Fix Plugin Structure for Skill Registration

## Problem Statement

The webworks-claude-skills plugin's skills (automap, epublisher, markdown-plus-plus, reverb2) are not being registered with Claude Code's Skill tool. When attempting to invoke `webworks-claude-skills:automap`, Claude Code returns:

```
Unknown skill: webworks-claude-skills:automap
```

## Root Cause Analysis

After examining the installed plugin cache and comparing to working plugins (compound-engineering), the issue is the location of `plugin.json`:

### Current Structure (Not Working)

```
plugins/webworks-claude-skills/
├── plugin.json              ← Wrong location
└── skills/
    ├── automap/
    │   └── SKILL.md
    ├── epublisher/
    │   └── SKILL.md
    ├── markdown-plus-plus/
    │   └── SKILL.md
    └── reverb2/
        └── SKILL.md
```

### Required Structure (Working - like compound-engineering)

```
plugins/webworks-claude-skills/
├── .claude-plugin/
│   └── plugin.json          ← Correct location
└── skills/
    ├── automap/
    │   └── SKILL.md
    ├── epublisher/
    │   └── SKILL.md
    ├── markdown-plus-plus/
    │   └── SKILL.md
    └── reverb2/
        └── SKILL.md
```

## Evidence

1. **compound-engineering** (skills work):
   - Path: `~/.claude/plugins/cache/every-marketplace/compound-engineering/2.22.0/.claude-plugin/plugin.json`
   - Skills available in Skill tool: `compound-engineering:changelog`, `compound-engineering:frontend-design`, etc.
   - **No explicit `skills` array** - relies on auto-discovery

2. **webworks-claude-skills** (skills don't work):
   - Path: `~/.claude/plugins/cache/webworks-claude-skills/webworks-claude-skills/2.0.8/plugin.json`
   - Skills NOT available in Skill tool

## Research Findings

### Skills Are Auto-Discovered

According to official Claude Code documentation (2025-2026):
- Skills are **automatically discovered** from the `skills/` directory
- The `skills` array in plugin.json is **not part of the official schema**
- Claude Code scans `skills/` for subdirectories containing `SKILL.md` files
- Skill metadata (name, description from YAML frontmatter) is loaded immediately
- Standard plugin.json fields: `name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`, `commands`, `agents`, `hooks`, `mcpServers` - but **not** `skills`

### Path Resolution

Claude Code resolves skill paths relative to the **plugin root directory** (where `skills/` lives), not relative to `plugin.json`. This means the existing skill directory structure will work after moving `plugin.json`.

## Implementation Plan

### Step 1: Create Feature Branch

Per project conventions (CLAUDE.md), use PR workflow:

```bash
git checkout -b fix/plugin-structure-for-skill-registration
```

### Step 2: Create .claude-plugin Directory

```bash
mkdir -p plugins/webworks-claude-skills/.claude-plugin
```

### Step 3: Move plugin.json

```bash
git mv plugins/webworks-claude-skills/plugin.json plugins/webworks-claude-skills/.claude-plugin/
```

### Step 4: Simplify plugin.json

Remove the explicit `skills` array since skills are auto-discovered. Update the plugin.json to match the official schema:

```json
{
  "name": "webworks-claude-skills",
  "version": "2.1.0",
  "description": "Claude Code skills for WebWorks ePublisher platform - documentation publishing, content management, and automated builds",
  "author": {
    "name": "Quadralay Corporation",
    "email": "support@webworks.com"
  },
  "homepage": "https://github.com/AvidDollars/webworks-claude-skills",
  "repository": "https://github.com/AvidDollars/webworks-claude-skills",
  "license": "MIT",
  "keywords": [
    "webworks",
    "epublisher",
    "documentation",
    "publishing",
    "markdown",
    "reverb",
    "automap"
  ]
}
```

### Step 5: Update marketplace.json

Update version in `.claude-plugin/marketplace.json`:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "webworks-claude-skills",
  "version": "2.1.0",
  ...
}
```

### Step 6: Test Locally

Before committing:

1. Clear the plugin cache:
   ```bash
   rm -rf ~/.claude/plugins/cache/webworks-claude-skills
   ```

2. Reinstall the plugin from local source

3. Start a new Claude Code session

4. Verify **ALL FOUR** skills appear and work:
   - `webworks-claude-skills:automap`
   - `webworks-claude-skills:epublisher`
   - `webworks-claude-skills:markdown-plus-plus`
   - `webworks-claude-skills:reverb2`

### Step 7: Commit and Create PR

```bash
git add -A
git commit -m "fix: move plugin.json to .claude-plugin/ for skill registration

Move plugin.json to .claude-plugin/ directory to match Claude Code's
expected plugin structure. This enables skills to be auto-discovered and
invokable via the Skill tool (e.g., webworks-claude-skills:automap).

Changes:
- Move plugin.json to plugins/webworks-claude-skills/.claude-plugin/
- Remove explicit skills array (skills are auto-discovered)
- Bump version to 2.1.0

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

git push -u origin fix/plugin-structure-for-skill-registration
gh pr create --base main --title "fix: move plugin.json to .claude-plugin/ for skill registration"
```

### Step 8: After PR Merge - Tag Release

```bash
git checkout main
git pull
git tag v2.1.0
git push origin v2.1.0
```

## Acceptance Criteria

- [ ] `plugin.json` exists at `plugins/webworks-claude-skills/.claude-plugin/plugin.json`
- [ ] Old `plugins/webworks-claude-skills/plugin.json` is removed (not duplicated)
- [ ] Explicit `skills` array removed from plugin.json (rely on auto-discovery)
- [ ] All four skills appear in Claude Code's skill list:
  - [ ] `webworks-claude-skills:automap`
  - [ ] `webworks-claude-skills:epublisher`
  - [ ] `webworks-claude-skills:markdown-plus-plus`
  - [ ] `webworks-claude-skills:reverb2`
- [ ] Each skill can be invoked via `Skill` tool
- [ ] Version is 2.1.0 in both `marketplace.json` and `plugin.json`
- [ ] Git tag v2.1.0 exists after merge
- [ ] Fresh installation works on a clean Claude Code environment

## User Upgrade Instructions

Existing users need to clear their plugin cache after updating:

```bash
# Clear webworks-claude-skills cache
rm -rf ~/.claude/plugins/cache/webworks-claude-skills

# Restart Claude Code - plugin will be re-fetched
```

Include this in release notes.

## Rollback Plan

If v2.1.0 causes issues:

1. Revert the commit on main
2. Delete the v2.1.0 tag: `git tag -d v2.1.0 && git push origin :refs/tags/v2.1.0`
3. Users can manually clear cache to get the reverted version

## Files to Modify

1. **MOVE:** `plugins/webworks-claude-skills/plugin.json` → `plugins/webworks-claude-skills/.claude-plugin/plugin.json`
2. **UPDATE:** `plugins/webworks-claude-skills/.claude-plugin/plugin.json` - simplify and bump to 2.1.0
3. **UPDATE:** `.claude-plugin/marketplace.json` - bump version to 2.1.0

## Related Context

- This issue was discovered during the epublisher-docs migration work
- The auto-fix-cycle skill was updated to use `Invoke skill: webworks-claude-skills:automap` but failed because the skill wasn't registered
- Workaround was using direct bash script path, which is less portable

## References

- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
- compound-engineering plugin structure (working reference)
