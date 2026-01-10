# Private Plans Management for Quadralay

## Overview

Create a private repository for managing internal plans, marketing campaigns, and strategy documents that need to be shared within the Quadralay team but not publicly.

## Problem Statement

- `webworks-claude-skills` is now public
- Marketing plans and internal strategies shouldn't be public
- Need a way to share private plans across Quadralay repos
- Current `plans/` folder would expose internal information

## Proposed Solution

Create a single private repo `quadralay/internal-docs` to centralize all private planning across Quadralay projects.

### Repository Structure

```
quadralay/internal-docs/
├── README.md                    # Repo purpose and navigation
├── webworks-claude-skills/      # Plans for this repo
│   ├── marketing/
│   │   └── plugin-launch-campaign.md
│   └── roadmap/
├── webworks-website/            # Plans for website
│   └── marketing/
├── epublisher-docs/             # Plans for docs
├── decisions/                   # Cross-project ADRs
└── templates/                   # Plan templates
    ├── marketing-campaign.md
    └── feature-plan.md
```

### Workflow

1. **Public repo (`webworks-claude-skills`):**
   - Code, public documentation, SKILL.md files
   - GitHub Issues for public feature requests/bugs
   - `plans/` folder removed or gitignored

2. **Private repo (`quadralay/internal-docs`):**
   - Marketing campaigns
   - Internal strategies
   - Roadmaps with timing
   - Competitive analysis
   - Pricing discussions

3. **Cross-referencing:**
   - Private plans can reference public issues: `See quadralay/webworks-claude-skills#25`
   - Public issues should NOT reference private plans (not visible to public)

---

## Implementation Steps

### Phase 1: Create Private Repo

```bash
# Create the private internal-docs repo
gh repo create quadralay/internal-docs --private --description "Internal planning and strategy documents for Quadralay projects"

# Clone it
git clone git@github.com:quadralay/internal-docs.git
```

### Phase 2: Set Up Structure

Create initial structure:

```bash
cd internal-docs

# Create directories
mkdir -p webworks-claude-skills/marketing
mkdir -p webworks-website/marketing
mkdir -p decisions
mkdir -p templates

# Create README
cat > README.md << 'EOF'
# Quadralay Internal Docs

Private planning and strategy documents for Quadralay projects.

## Structure

- `webworks-claude-skills/` - Plans for the Claude Code plugin
- `webworks-website/` - Website marketing and strategy
- `decisions/` - Cross-project architecture decisions
- `templates/` - Reusable plan templates

## Usage

Each project has its own folder. Use subfolders for:
- `marketing/` - Marketing campaigns
- `roadmap/` - Product roadmaps
- `strategy/` - Strategic documents
EOF
```

### Phase 3: Migrate Existing Plans

```bash
# Move marketing plan from public repo
mv ../webworks-claude-skills/plans/marketing-campaign-plugin-launch.md \
   webworks-claude-skills/marketing/plugin-launch-campaign.md

# Commit
git add -A && git commit -m "Initial structure with marketing plan"
git push
```

### Phase 4: Clean Up Public Repo

```bash
cd ../webworks-claude-skills

# Add plans/ to .gitignore (keep for local drafts)
echo "plans/*.md" >> .gitignore
echo "!plans/.gitkeep" >> .gitignore

# Or remove plans/ entirely
rm -rf plans/

git add -A && git commit -m "Remove private plans from public repo"
git push
```

---

## Acceptance Criteria

- [ ] `quadralay/internal-docs` repo created (private)
- [ ] Initial folder structure created
- [ ] Marketing plan moved to private repo
- [ ] Public repo `plans/` folder cleaned up
- [ ] README in private repo explains structure
- [ ] Team members have access to private repo

---

## Alternative Considered

| Option | Pros | Cons |
|--------|------|------|
| **Single internal-docs repo** (chosen) | Centralized, easy to find, one place for all plans | Need to organize by project |
| **Per-project private repo** (e.g., `webworks-claude-skills-internal`) | Direct association with project | More repos to manage |
| **GitHub Wiki (private)** | Built-in to each repo | Follows repo visibility, harder to search |
| **External tool (Notion, Confluence)** | Rich editing, easy sharing | Outside Git workflow |

**Decision:** Single `internal-docs` repo is simplest for a small team and scales well.

---

## References

- [GitHub Private Repos](https://docs.github.com/en/repositories/creating-and-managing-repositories/about-repositories)
- [Polyrepo vs Monorepo](https://earthly.dev/blog/monorepo-vs-polyrepo/)
