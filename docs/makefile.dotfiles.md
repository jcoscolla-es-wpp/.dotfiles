# Makefile Reference

One-command install orchestration.
Config linking preserves existing configs and refuses to overwrite backups.
Installation targets can download software and change global tool settings; run only what you need.

## Installation Chain

`make all` orchestrates everything:

```text
check-xcode → brew → mise → profile → tools → kitty
```

Where:

- `profile` = zsh + neovim + tmux + git
- `tools` = CLI utilities + Node.js, Go, Terraform, and Kubernetes tools
- `zsh` installs Zinit and the declared plugins before linking shell configs

## Quick Start

```zsh
make verify     # Report system prerequisites; install nothing
make all        # Full install
make profile    # Install profile configs and missing shell plugins/TPM
make update     # Upgrade mise itself and its managed tools
make clean      # Remove only this repository's config links
make validate   # Isolated tmux parsing, zsh syntax, static clipboard bindings
make test       # Validator plus regression tests in disposable homes
make benchmark  # macOS startup-and-exit medians, non-TTY and PTY
```

## Profile Targets (symlinks)

| Target | Links | Notes |
|--------|-------|-------|
| `make zsh` | `~/.zshrc`, `~/.zsh.d/` | Installs Zinit and declared plugins, then links configs |
| `make neovim` | `~/.config/nvim/` | Auto-installs nvim if missing |
| `make tmux` | `~/.tmux.conf` | Installs TPM; use `C-a I` to install its plugins |
| `make git` | `~/.gitignore_global` | Sets `core.excludesfile` |

`make install-zinit` installs missing Zinit without updating an existing installation.
`make zsh-plugins` installs missing declared shell plugins and the gitstatus binary,
without relinking configs or updating existing plugin repositories.
Interactive shell startup does not clone Zinit or plugin repositories.

`make test` includes an installed-plugin PTY check when its dependencies are available;
missing dependencies are reported as skips.
`make benchmark` uses seven warm samples per mode and measures startup-and-exit,
not time to the first prompt or deferred plugin readiness.

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

All config targets use `scripts/link-config.zsh`.
An already-correct link is left unchanged.
An existing file, directory, or unrelated link is moved to `<destination>.backup` before linking:

```text
~/.zshrc        → ~/.zshrc.backup
~/.zsh.d/       → ~/.zsh.d.backup/
~/.config/nvim/ → ~/.config/nvim.backup/
~/.tmux.conf    → ~/.tmux.conf.backup
```

If the backup already exists, installation stops without replacing it or the destination.
`make clean` unlinks only destinations that resolve to this repository's matching source.
It preserves real configs, unrelated links, backups, and source directories; it does not restore backups.

## System Variables

| Variable | Value |
|----------|-------|
| `DOTFILES` | `$(CURDIR)`; override when invoking Makefile elsewhere |
| `CONFIG_DIR` | `$(HOME)/.config` |
| `KITTY_CONFIG` | `$(HOME)/.config/kitty` |
| `XDG_DATA_HOME` | `$(HOME)/.local/share` unless supplied |
| `ZINIT_HOME` | `$(XDG_DATA_HOME)/zinit/zinit.git` unless supplied |

See [REFERENCE.md](REFERENCE.md) for all Makefile targets.
