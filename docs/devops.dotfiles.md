# DevOps & CI/CD

Three GitHub Actions workflows on free tier.
Workflows run configured syntax, smoke, lint, and security checks on push/PR.
They do not establish that every interactive feature works.

## Workflows

| Workflow | Runner | Trigger |
|----------|--------|---------|
| `validate.yml` | Ubuntu | push main/develop, PR to main/develop |
| `validate-macos.yml` | macOS | push develop, PR to main |
| `security.yml` | Ubuntu | push main/develop, weekly scan |

## What Gets Validated

**validate.yml (Ubuntu):**

- ShellCheck on `scripts/`
- ZSH syntax: `zsh -n` on zshrc + all `zsh.d/` modules
- Tmux syntax: `tmux source-file tmux.conf`
- `make test`: isolated validator and shell/installer regressions; installed-plugin PTY check is conditional
- Markdown linting

**validate-macos.yml (macOS):**

- Install tools with Homebrew, including mise, fzf, zoxide, and direnv
- Install shell plugins with `make zsh`; link remaining configs with the shared link helper
- `make test`: isolated validator, regressions, and installed-plugin PTY check when dependencies are present
- Seven-sample warm startup-and-exit medians: non-TTY and PTY (including `script` overhead)
- 500ms budget for each median, distinct from the local 110ms target; exceeding it fails the job
- Tmux parse-only validation on a disposable private socket
- Neovim headless startup smoke check
- Kitty headless configuration parser
- mise doctor (diagnostic; failures are not currently blocking)

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

Work on `develop`; open a PR from `develop` to `main` and squash merge.
Use scoped Conventional Commits and the required Roy Batty co-author trailer.
Do not create feature branches or delete either long-lived branch.
Before merging, verify that GitHub's delete-branch-on-merge setting is disabled.
Follow [AGENTS.md](../AGENTS.md) for the repository's Git policy.

## Troubleshooting Locally

If workflows fail, debug locally:

```zsh
make validate          # Syntax/static checks without touching live tmux or clipboard
make test              # Regression tests with disposable homes and a private tmux server
make verify            # Report system prerequisites; install nothing
zsh -dfn zshrc          # Syntax only, without startup files
make benchmark         # macOS warm startup-and-exit medians
```

The validator parses tmux with `source-file -n` on a disposable private socket,
without executing plugins or changing live sessions.
Clipboard checks inspect bindings and command availability; no clipboard data is read or written.
Regression tests cover native commands, history, completion fallback, prompt failure/cache handling,
safe links, cleanup, and effective tmux bindings.
The installed-plugin PTY check verifies completion initialization, fzf key bindings,
zoxide completion, autosuggestions, and highlighting when dependencies are present.
Missing dependencies produce a skip, not evidence that plugin interaction passed.

Distinguish non-TTY startup-and-exit measurements from PTY measurements.
Neither proves time to the first prompt or completion of deferred plugin loading.

See [github.dotfiles.md](github.dotfiles.md) for commit convention details.
