# Branch Protection Setup Plan

**Status:** Pending - waiting for repo to go public
**Blocker:** GitHub free org plan requires public repos for branch protection

## Goal

Protect the `main` branch so:
- All changes require a pull request (no direct pushes)
- Only quadralay org admins can bypass/merge
- Public contributors can fork and submit PRs

## API Command

Run this after making the repo public:

```bash
gh api repos/quadralay/webworks-claude-skills/rulesets --method POST --input - << 'EOF'
{
  "name": "Protect main branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "non_fast_forward"
    }
  ],
  "bypass_actors": [
    {
      "actor_id": 1,
      "actor_type": "OrganizationAdmin",
      "bypass_mode": "always"
    }
  ]
}
EOF
```

## Verification

After creating the ruleset:

```bash
# List rulesets
gh ruleset list --repo quadralay/webworks-claude-skills

# Check what rules apply to main
gh ruleset check main --repo quadralay/webworks-claude-skills
```

## Reference

- [GitHub Rulesets Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Rulesets API](https://docs.github.com/en/rest/repos/rules)
