# Plugin Fixes Execution Prompt

Use this prompt to execute the plugin fixes plan in a fresh context.

---

## Prompt

Execute the plugin fixes plan at `plans/plugin-fixes-plan.md` for the `epublisher-automation` plugin.

### Instructions

1. **Read the plan first:** Start by reading `plans/plugin-fixes-plan.md` to understand all tasks
2. **Execute phases in order:** Complete each phase before moving to the next
3. **Update progress:** Mark each phase complete in the plan's Progress table as you finish
4. **Commit after each phase:** Create a commit after completing each phase with a descriptive message

### Phase Summary

| Phase | Priority | Description |
|-------|----------|-------------|
| 1 | Critical | Create `plugin.json` at `plugins/epublisher-automation/plugin.json` |
| 2 | Medium | Fix Node version check in `setup-dependencies.sh` (18+ not 14+) |
| 3 | Medium | Add `setup-dependencies.sh` to reverb SKILL.md scripts section |
| 4 | Medium | Add `<related_skills>` section to all three SKILL.md files |
| 5 | Low | Add `<troubleshooting>` section to all three SKILL.md files |

### Files to Modify

```
plugins/epublisher-automation/
├── plugin.json                          # CREATE (Phase 1)
├── skills/
│   ├── epublisher/
│   │   └── SKILL.md                     # EDIT (Phase 4, 5)
│   ├── automap/
│   │   └── SKILL.md                     # EDIT (Phase 4, 5)
│   └── reverb/
│       ├── SKILL.md                     # EDIT (Phase 3, 4, 5)
│       └── scripts/
│           └── setup-dependencies.sh    # EDIT (Phase 2)
```

### Commit Messages

Use these commit message formats:
- Phase 1: `feat: Add plugin.json for plugin registration`
- Phase 2: `fix: Update Node version check to match package.json (18+)`
- Phase 3: `docs: Document setup-dependencies.sh in reverb SKILL.md`
- Phase 4: `docs: Add cross-skill relationship guidance`
- Phase 5: `docs: Add troubleshooting sections to all skills`

### Success Criteria

After execution:
- [ ] `plugin.json` exists and has valid JSON structure
- [ ] `setup-dependencies.sh` checks for Node 18+
- [ ] All scripts mentioned in reverb skill are documented
- [ ] All three skills document their relationship to other skills
- [ ] All three skills have troubleshooting guidance
- [ ] All phases marked complete in plan Progress table

Start by reading the plan file, then execute Phase 1.
