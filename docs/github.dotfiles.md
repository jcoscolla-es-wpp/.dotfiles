# GitHub Repository Configuration

Squash-merge only. Conventional Commits enforced. Free-tier branch rules.

## Branching Strategy

Three branch types:

- `main` — Stable configs (protected)
- `develop` — Integration branch (testing)
- `feat/*`, `fix/*`, `docs/*` — Your work

### Workflow

```bash
# Create feature branch from develop
git checkout -b feat/name develop

# Commit (conventional format)
git commit -m "feat(scope): description"

# Push and open PR to develop
git push -u origin feat/name
gh pr create --base develop

# After CI passes, squash-merge to develop
gh pr merge <#> --squash --delete-branch

# When ready, open PR to main
gh pr create --base main

# Squash-merge to main
gh pr merge <#> --squash
```

## Commit Convention

All commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(scope): description
```

| Type | Use for |
|------|---------|
| `feat` | New tool, plugin, config |
| `fix` | Bug fix, broken binding |
| `docs` | Documentation only |
| `refactor` | Restructuring, no functional change |
| `chore` | Dependencies, CI, cleanup |
| `test` | Validation script changes |

## Validation Before PR

Always run locally first:

```bash
bash scripts/validate-configs.sh    # Full validation
make verify                         # System check
```

See [devops.dotfiles.md](devops.dotfiles.md) for what workflows validate.

## Branch Protection

`main` requires:
- No deletion
- No force-push
- PR with all status checks passing
- PR reviews (optional, not enabled on free tier)

## Security Features

Free-tier GitHub protections:
- Secret scanning (blocks commits with secrets)
- Dependabot alerts
- GitHub Actions security scanning

All workflows pinned to commit SHA (prevents supply chain attacks).
