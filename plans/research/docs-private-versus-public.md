# Managing Private Internal Documentation Alongside Public Open Source Repositories

**Research Date:** January 2026
**Focus:** Practical, lightweight solutions for small teams

---

## Table of Contents

1. [Repository Structure Patterns](#repository-structure-patterns)
2. [Naming Conventions](#naming-conventions)
3. [Internal Documentation Repository Best Practices](#internal-documentation-repository-best-practices)
4. [GitHub Organization Features](#github-organization-features)
5. [Cross-Referencing Strategies](#cross-referencing-strategies)
6. [Common Patterns](#common-patterns)
7. [Implementation Checklist](#implementation-checklist)

---

## Repository Structure Patterns

### Monorepo vs Polyrepo for Mixed Public/Private Content

**Key Finding:** If your organization needs both closed-source and open-source code, a monorepo is not viable. A **polyrepo approach** is recommended for small teams with private docs and public code.

#### Polyrepo Benefits for Your Scenario
- **Fine-grained access control:** Each repository can have separate permission levels
- **Cleaner separation:** Private docs stay isolated from public code
- **Simpler permissions:** Easier to manage who can see what
- **Team autonomy:** Each repo can have independent governance
- **Lightweight:** Faster clones, easier to understand individual projects

#### Small Team Considerations
- Small organizations benefit from monorepo issue tracking for coordination, but the access control challenges make it unsuitable for mixed public/private scenarios
- Polyrepos are lightweight and easier to manage for smaller codebases
- Start simple and scale as needed—GitHub allows you to reorganize later

#### Hybrid Approach Option
Some organizations maintain:
- **Public repo:** Production-ready open source code
- **Private org/internal repo:** Strategy docs, plans, internal guides
- **Public secondary repos:** Feature demos, examples, tutorials

**Source:** [Monorepo vs Polyrepo comparisons (Earthly Blog)](https://earthly.dev/blog/monorepo-vs-polyrepo/), [GitHub monorepo-vs-polyrepo discussion](https://github.com/joelparkerhenderson/monorepo-vs-polyrepo)

---

## Naming Conventions

### Repository Naming Pattern

**Recommended structure:** `[PREFIX]-[COMPONENT]-[TYPE]`

- **PREFIX:** Project, product, or owning team (lowercase, hyphenated)
- **COMPONENT:** What it does (lowercase, hyphenated)
- **TYPE:** Optional—distinguishes docs from code

#### Examples
```
docs-internal          # Internal documentation repository
docs-public            # Public documentation site
skills-core            # Core skills library
skills-examples        # Example skills
workflow-planning      # Internal workflow/planning repo
guidelines-style       # Style guides and conventions
```

### Rules to Follow

- Use **lowercase letters only**
- Use **hyphens for spaces** (not underscores or camelCase)
- **Avoid versioning in the name:** Use git tags, branches, or release management instead
- **Avoid vague names:** Not "my-repo", "project-alpha", "test", "temp"
- **Don't include developer names:** "john-doe-feature" is not appropriate
- **Avoid redundancy:** Don't repeat information clear from context
- **Common acronyms are acceptable:** "api", "ui", "cli" are clear; obscure ones need documentation

### Benefits
- **Clarity:** Team members quickly identify purpose and functionality
- **Organization:** Repositories naturally group by prefix
- **Discoverability:** Easier to search and find related repos
- **Efficiency:** Less time figuring out project structures

**Source:** [Repository Naming Conventions (Medium)](https://medium.com/@nur26691/repository-naming-conventions-1065467de776), [OEP Naming Conventions](https://oep.readthedocs.io/en/latest/oep-0003.html)

---

## Internal Documentation Repository Best Practices

### Repository Setup for Small Teams

#### Core Files to Include
```
docs-internal/
├── README.md              # How to use this repo
├── CONTRIBUTING.md        # Contribution guidelines
├── STRUCTURE.md           # How docs are organized
│
├── planning/              # Project plans and PRDs
│   ├── 2025/
│   └── archive/
│
├── decisions/             # Architecture Decision Records (ADRs)
│   ├── adr-001-*.md
│   └── adr-002-*.md
│
├── guides/                # Internal how-to guides
│   ├── onboarding.md
│   ├── workflow.md
│   └── coding-standards.md
│
├── processes/             # Team workflows
│   ├── code-review.md
│   ├── release.md
│   └── security.md
│
├── references/            # Checklists, templates, lookups
│   ├── checklists/
│   ├── templates/
│   └── glossary.md
│
└── archive/               # Old docs and decisions
```

### Documentation Structure Best Practices

#### Modular Approach
- **Don't create monolithic documents:** Break into smaller, linkable modules
- **One topic per file:** Easier to find, update, and maintain
- **Clear hierarchy:** Use consistent heading levels (avoid skipping levels)
- **Link aggressively:** Cross-reference related documentation

#### Documentation Strategy
- **Keep docs in the same repo where code lives:** Avoids duplication and staleness
- **If docs live elsewhere:** Create obvious links in README.md pointing to them
- **Change docs in the same commit as code:** This is crucial for keeping documentation current
- **Don't duplicate third-party tool docs:** It goes stale and becomes a maintenance nightmare

#### Writing Guidelines
- **Document the "why" not just the "how":** Context that code cannot provide is most valuable
- **Include decision rationale:** Explain architectural choices and constraints
- **Update during code review:** Reviewers should insist on documentation updates alongside code changes
- **Consistency matters:** Adopt a style guide (e.g., Google Documentation Style Guide) and follow it

### Access Control for Docs Repo

For a small team, initial setup can be simple:
- **All developers as contributors:** Most small teams start with everyone having write access
- **README clearly states:** "Who can modify what" if you have restrictions
- **As you grow:** Implement more granular permissions through GitHub Teams

**Source:** [Code Documentation Best Practices (dualite.dev)](https://dualite.dev/blog/code-documentation-best-practices), [Google Style Guide](https://google.github.io/styleguide/docguide/best_practices.html)

---

## GitHub Organization Features

### Visibility Settings Explained

GitHub provides **three visibility options** for organization repositories:

#### 1. **Public**
- Visible to everyone on the internet
- Ideal for open-source projects
- Anyone can fork without explicit permission
- Great for community engagement

#### 2. **Internal** (Enterprise Cloud only)
- Visible to all members of your enterprise account
- **Not visible** to people outside your organization
- All enterprise members have read access by default
- Recommended as the default for company projects without siloed sensitive information
- Promotes "innersource" practices within the enterprise

#### 3. **Private**
- Only visible to you and people you explicitly grant access to
- **Most restrictive** option—use sparingly
- Be sure to invite collaborators or it becomes a collaboration killer
- Only accessible to specified individuals or teams

**Recommendation for your scenario:**
- **Public repos:** Open-source code, published skills
- **Internal repos:** (if enterprise) Shared team knowledge, guidelines
- **Private repos:** Sensitive strategy docs, security-critical information, customer-specific content

### Role-Based Access Control (RBAC)

#### Organization-Level Roles

| Role | Permissions |
|------|------------|
| **Owner** | Full administrative access (2+ recommended) |
| **Security Manager** | View security alerts, manage security settings, read all repos |
| **Member** | Basic collaboration within organization |
| **Outside Collaborator** | Access to specific repos only (consultants, temp employees) |

#### Repository-Level Roles

| Role | Use Case |
|------|----------|
| **Read** | Read-only access to repo content |
| **Triage** | Can manage issues and PRs, but not deploy |
| **Write** | Can commit, merge PRs, manage releases |
| **Maintain** | Broad access except dangerous/destructive actions |
| **Admin** | Full control including settings and deletion |

### Team Structure for Small Teams

#### Simple Two-Tier Setup (Recommended for Small Teams)
```
Organization
├── Team: @core-maintainers
│   ├── Members: All core team members
│   └── Permissions: Write/Maintain on public repos, Admin on private docs
│
└── Team: @contributors
    ├── Members: Community contributors, new team members
    └── Permissions: Triage/Write on public repos only
```

#### Benefits of Team-Based Access
- Assign permissions to teams, not individuals
- Easier to onboard/offboard people (just add/remove from team)
- Cleaner audit trail
- Scales as you grow

### Key Organization Practices

- **Minimum 2 owners:** Prevents single point of failure
- **Use nested teams:** As you grow, reflect organizational structure
- **Default permissions:** Clearly document your org's philosophy (e.g., "open by default, restrict by exception")
- **Outside collaborators:** Use for consultants, vendors, temporary partners
- **Audit regularly:** Review who has access to what, remove inactive members

**Source:** [GitHub Roles Documentation](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/roles-in-an-organization), [GitHub Access Control Guide (ConductorOne)](https://www.conductorone.com/guides/everything_you_wanted_to_know_about_github_access_control/)

---

## Cross-Referencing Strategies

### What Works Between Public and Private Repos

#### Safe Cross-Repository References
✅ **You CAN:**
- Reference private issues from private repos: `owner/private-repo#123`
- Link public repos from private repos: `owner/public-repo#456`
- Use autolinked references: `#123` (within same repo)

❌ **You CANNOT:**
- Auto-close issues in a different repository (closing keywords like "Fixes" don't work across repos)
- Have backlinks visible to people without access (if private repo links to public, the backlink won't show in public)

### Visibility Rules for Cross-References

**Critical:** Cross-links are only visible to people who have access to the source repository.

- If your **private repo links to public repo:** Only your private repo team sees the link in the public issue. The public repo doesn't show the backlink.
- If your **public repo links to private repo:** Anyone can see the link, but only org members can follow it (404 for outsiders).

### Strategies for Linking Private Plans to Public Issues

#### Strategy 1: One-Way References (Recommended)
- Public issue is the single source of truth
- Private planning doc references public issue with full URL
- Plan is internal; no need to hide the link

**Example private doc:**
```markdown
## Implementation Plan for Feature X

Related to: https://github.com/org/public-repo/issues/123

### Internal Considerations
- [Private strategy points that won't appear in public issue]
- [Internal timeline/dependencies]
```

#### Strategy 2: Generic GitHub Issue Linking
- Use cross-repository references in both directions (understanding visibility rules)
- Prefix private issues with `INTERNAL:` to indicate they won't be visible externally

**Example in public issue comments:**
```markdown
Discussion also in internal planning: org/private-docs#42

Note: Some implementation details in private repo are not visible here.
```

#### Strategy 3: Avoid Backlinks Using Redirects (Advanced)
Some teams use redirect domains to link without creating backlinks:
- Link using `https://togithub.com/` instead of `https://github.com/`
- **Caveat:** This is not an official GitHub feature; external domains can change
- Not recommended unless you have strong reason to avoid backlinks

### Best Practices for Cross-Repository Workflows

1. **Clear documentation:** Add notes to public issues indicating where private planning exists
2. **One-way references:** Private docs reference public issues, not vice versa
3. **No hidden information:** Don't put secrets or sensitive info in links; assume public links may be visible to anyone
4. **Explicit mapping:** Maintain a mapping document in private repo showing which public issues have private plans
5. **Use full URLs:** `https://github.com/owner/repo/issues/123` is clearer than shortcuts

**Source:** [GitHub Autolinked References](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls), [GitHub Issue Discussions](https://github.com/orgs/community/discussions/)

---

## Common Patterns

### Pattern 1: Lightweight Documentation Approach (Best for Small Teams)

**Structure:**
```
public-repo/
├── README.md
├── CONTRIBUTING.md
├── docs/                  # Public documentation
│   ├── getting-started.md
│   └── api-reference.md
└── .github/
    ├── ISSUE_TEMPLATE/
    └── PULL_REQUEST_TEMPLATE/

private-docs-repo/         # Separate repo
├── README.md
├── planning/              # Project plans
├── decisions/             # Architecture decisions
├── guides/                # Internal how-tos
└── processes/             # Team workflows
```

**Benefits:**
- Clear separation of public/private
- Easy to audit what's exposed
- Lightweight repository structure
- Scales with team growth

### Pattern 2: Strategy Docs in Private Org, Code in Public Org

For more structured organizations:
- **Public GitHub organization:** Contains all open-source repositories
- **Private GitHub organization:** Contains internal docs, plans, and strategies
- Same team members have access to both
- Keeps concerns clearly separated

### Pattern 3: Issues-Only Private Repository

Some teams create a **private "issues-only" repo** for:
- Planning documents (as issues)
- Decisions/ADRs (as issues)
- Team discussions
- Cross-project tracking

```
private-issues/
├── README: Explains this is a planning repo
├── Issues: One issue per project/plan
└── Discussions: For team conversations
```

**Advantages:**
- Everything in GitHub (not scattered across docs)
- Built-in discussions and commenting
- Can be referenced from private docs-repo
- GitHub's native tools work well

### Pattern 4: Design Docs in Private Repo

Common approach used by many organizations:
- **Design docs:** Live in private repo, written before implementation
- **Decision records (ADRs):** Archive of design docs as code
- **Public repo:** Contains implementation and user-facing docs only
- **Cross-reference:** Include link to ADR in code comments for context

**Example structure:**
```
design-docs/
├── ACTIVE_DESIGNS.md      # Current projects
│   └── Links to issues
├── adr/                   # Architecture Decision Records
│   ├── 0001-*.md
│   └── 0002-*.md
└── archive/               # Implemented designs
```

---

## Implementation Checklist

### Week 1: Foundation Setup

#### Repository Structure
- [ ] Create private docs repository with standard naming (e.g., `docs-internal`)
- [ ] Create initial folder structure (planning/, decisions/, guides/, processes/, references/)
- [ ] Add `README.md` explaining repo purpose and access
- [ ] Add `CONTRIBUTING.md` with contribution guidelines
- [ ] Create `STRUCTURE.md` describing how to navigate docs

#### Documentation
- [ ] Document your organization's philosophy on public vs private
- [ ] Create onboarding guide for new team members
- [ ] Write up current team processes and workflows
- [ ] List common internal references (tools, services, contacts)

#### GitHub Organization
- [ ] Set default repository visibility (consider internal if enterprise)
- [ ] Create core teams (@core-maintainers, @contributors, etc.)
- [ ] Document team roles and permissions
- [ ] Set up CODEOWNERS file in key repos

### Week 2-3: Refinement

#### Naming Conventions
- [ ] Audit existing repositories against naming standard
- [ ] Plan renaming of non-compliant repos (or note them)
- [ ] Document naming conventions in organization README
- [ ] Create issue templates with naming reminders

#### Cross-Referencing
- [ ] Create mapping document: public issues → private plans
- [ ] Update public repos' README.md with link to docs-internal
- [ ] Add process docs explaining how to link private plans to public issues
- [ ] Test cross-repo linking and document limitations

#### Access Control
- [ ] Review and document access levels for each repository type
- [ ] Implement team-based access (not individual)
- [ ] Set branch protection rules (if using)
- [ ] Create security guide for managing access

### Week 4: Ongoing

#### Maintenance
- [ ] Monthly access review (who should still have access?)
- [ ] Quarterly docs audit (what's stale?)
- [ ] Annual structure review (does org structure still match repos?)

#### Team Practices
- [ ] Establish doc update schedule (review during code review)
- [ ] Create simple issue template linking private/public work
- [ ] Run quarterly "docs health check"
- [ ] Archive old planning documents

---

## Key Takeaways for Small Teams

### 1. **Polyrepo, Not Monorepo**
If you need both public and private content, separate repositories are your friend. It simplifies access control and keeps concerns isolated.

### 2. **Simple Naming Saves Time**
Consistent, lowercase, hyphenated names make finding repositories trivial as you grow.

### 3. **Private Docs Repo is Essential**
One clearly-named private repository (`docs-internal`, `private-docs`, etc.) becomes your team's knowledge base. Organize it with clear folders and link aggressively.

### 4. **GitHub's Internal Visibility (if available)**
If your organization uses GitHub Enterprise Cloud, `internal` visibility is ideal for team documentation—visible to all members, hidden from the world.

### 5. **Teams > Individuals for Permissions**
Always assign access to teams, not people. It scales cleanly and makes onboarding/offboarding trivial.

### 6. **One-Way Cross-References Work Best**
Private docs reference public issues (understood by team), but not the other way around. This keeps public repos clean.

### 7. **Docs Live with Code**
Change documentation in the same commit as code. Use code review to enforce this discipline.

### 8. **ADRs (Architecture Decision Records) Are Worth It**
Even for small teams, writing down the "why" behind major decisions in a private `decisions/` folder pays dividends as team grows or new members join.

---

## Sources

All recommendations in this research document are based on official GitHub documentation and industry best practices:

- [GitHub Documentation: About Repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/about-repositories)
- [GitHub Documentation: Best Practices for Repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories)
- [GitHub Documentation: Roles in an Organization](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/roles-in-an-organization)
- [GitHub Documentation: Managing Teams and People](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-teams-and-people-with-access-to-your-repository)
- [GitHub Access Control Guide (ConductorOne)](https://www.conductorone.com/guides/everything_you_wanted_to_know_about_github_access_control/)
- [Repository Naming Conventions (Medium)](https://medium.com/@nur26691/repository-naming-conventions-1065467de776)
- [Code Documentation Best Practices (2025)](https://dualite.dev/blog/code-documentation-best-practices)
- [Google Documentation Style Guide](https://google.github.io/styleguide/docguide/best_practices.html)
- [GitHub Best Practices (Webstandards.ca.gov)](https://webstandards.ca.gov/2023/04/19/github-best-practices/)
- [Monorepo vs Polyrepo (Earthly Blog)](https://earthly.dev/blog/monorepo-vs-polyrepo/)
- [GitHub Monorepo vs Polyrepo Discussion](https://github.com/joelparkerhenderson/monorepo-vs-polyrepo)
- [OEP Naming Conventions](https://oep.readthedocs.io/en/latest/oep-0003.html)
