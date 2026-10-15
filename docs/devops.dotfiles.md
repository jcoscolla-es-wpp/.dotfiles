# DevOps & CI/CD

Three GitHub Actions workflows on free tier.
All configs validated automatically on push/PR.

## Workflows

| Workflow | Runner | Trigger | Duration |
|----------|--------|---------|----------|
| `validate.yml` | Ubuntu | push develop, PR to main/develop | ~2 min |
| `validate-macos.yml` | macOS | push develop, PR to main | ~6 min |
| `security.yml` | Ubuntu | push main/develop, weekly scan | ~4 min |

## What Gets Validated

**validate.yml (Ubuntu):**

- ShellCheck on `scripts/`
- ZSH syntax: `zsh -n` on zshrc + all `zsh.d/` modules
- Tmux syntax: `tmux source-file tmux.conf`
- Markdown linting

**validate-macos.yml (macOS):**

- Install tools: brew + mise
- Symlink configs
- ZSH startup time (threshold: 500ms, typically 47ms)
- Tmux config validation
- Neovim Lua syntax
- Kitty config validation
- mise doctor

**security.yml (Ubuntu):**

- Gitleaks: scan git history for secrets
- Trivy: detect security misconfigs

## Branch Rules

Free-tier rulesets protect branches:

| Branch | Protection |
|--------|-----------|
| `main` | No deletion, no force-push, PR + all checks required |
| `develop` | No deletion, no force-push |

## Git Workflow

```bash
# Start feature
git checkout -b feat/name develop

# Commit (conventional format)
git commit -m "feat(scope): description"

# Push + open PR
git push -u origin feat/name
gh pr create --base develop

# Merge (squash)
gh pr merge <#> --squash --delete-branch
```

## Troubleshooting Locally

If workflows fail, debug locally:

```bash
bash scripts/validate-configs.sh    # All checks
make verify                         # System prereqs
zsh -n zshrc                        # ZSH syntax
for f in zsh.d/*.zsh; do zsh -n "$f"; done  # Modules
tmux source-file ~/.tmux.conf       # Tmux
```

See [github.dotfiles.md](github.dotfiles.md) for commit convention details.
