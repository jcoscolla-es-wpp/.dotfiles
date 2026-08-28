# Makefile Reference

One-command install orchestration.
All targets are idempotent — safe to re-run anytime.

## Installation Chain

`make all` orchestrates everything:

```text
check-xcode → brew → mise → profile → tools → kitty
```

Where:

- `profile` = zsh + neovim + tmux + git
- `tools` = CLI utilities + runtimes (Node.js, Go, Ruby, Terraform, Kubernetes)

## Quick Start

```bash
make verify     # Check system prerequisites
make all        # Full install
make profile    # Symlink configs only (faster)
make update     # brew upgrade + mise upgrade
make clean      # Remove all symlinks
```

## Profile Targets (symlinks)

| Target | Links | Notes |
|--------|-------|-------|
| `make zsh` | `~/.zshrc`, `~/.zsh.d/` | Backs up existing non-symlinks |
| `make neovim` | `~/.config/nvim/` | Auto-installs nvim if missing |
| `make tmux` | `~/.tmux.conf` | Installs TPM plugins |
| `make git` | `~/.gitignore_global` | Sets `core.excludesfile` |

## Packages & Runtimes

### CLI Tools (`make tools`)

bat, lsd, fd, ripgrep, fzf, htop, tree, tldr, zoxide, direnv, wget, curl, jq, yq, gh, git-lfs

### Runtimes (via mise)

| Tool | Command | Notes |
|------|---------|-------|
| Node.js LTS | `make nodejs` | Latest even (20, 22, 24…) |
| Go | `make golang` | Latest stable |
| Ruby | `make ruby` | Latest stable |
| Terraform | `make terraform` | Latest stable |

### Kubernetes & Cloud

| Tool | Command |
|------|---------|
| kubectl, helm, kind, kubectx | `make kubernetes` |
| Docker | `make docker` |
| AWS CLI | `make aws` |
| Google Cloud SDK | `make gcloud` |
| Azure CLI | `make azure` |

## Backup Behavior

Existing non-symlink configs are backed up before overwriting:

```text
~/.zshrc        → ~/.zshrc.backup
~/.zsh.d/       → ~/.zsh.d.backup/
~/.config/nvim/ → ~/.config/nvim.backup/
~/.tmux.conf    → ~/.tmux.conf.backup
```

## System Variables

| Variable | Value |
|----------|-------|
| `DOTFILES` | `$(HOME)/.dotfiles` |
| `CONFIG_DIR` | `$(HOME)/.config` |
| `KITTY_CONFIG` | `$(HOME)/.config/kitty` |

See [REFERENCE.md](REFERENCE.md) for all Makefile targets.
