# ZSH Configuration

Fast, modular shell config.
All config lives in `zsh.d/` — edit independently, changes take effect on next shell.

## Loading Order

Preserve the core source order below.
`zshrc` initializes an installed Zinit; `make zsh` installs it and the declared plugins.
Missing Zinit/plugins produce warnings rather than repository clones during startup.

```text
zshrc
  ├─ env.zsh          — PATH, locale, EDITOR
  ├─ options.zsh      — Shell options (AUTO_CD, PUSHD, etc.)
  ├─ history.zsh      — Shared history (20k entries in memory, 10k saved)
  ├─ plugins.zsh      — Four-plugin Zinit registry
  ├─ prompt.zsh       — Git-aware prompt (customize via PROMPT_* vars)
  ├─ completion.zsh   — Completion initialization and styles
  ├─ colors.zsh       — less, LSCOLORS, LS_COLORS (dircolors)
  ├─ kitty.zsh        — Kitty integration
  ├─ alias.zsh        — Shortcuts (git, tmux, etc.)
  └─ tools.zsh        — mise, fzf, bat, zoxide, direnv
```

Optional `aws.zsh` and local, untracked `oracle.zsh` load afterwards when readable.
`ZSH_CONFIG_DIR` defaults to `~/.zsh.d`; `ZINIT_HOME` defaults to
`${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git`.
Override them for isolated tests, not to reorder modules.

`SHARE_HISTORY` shares history across sessions; incremental append modes remain disabled.

## Key Plugins

| Plugin | What it does |
|--------|--------------|
| `romkatv/gitstatus` | Git prompt with bounded daemon queries |
| `zsh-users/zsh-completions` | Better completions |
| `zsh-users/zsh-autosuggestions` | Command history suggestions |
| `zdharma-continuum/fast-syntax-highlighting` | Syntax highlighting |

The gitstatus plugin library loads synchronously; daemon initialization starts in the background
and overlaps later tool integration.
After the prompt, Zinit loads completions (`wait'0a'`), autosuggestions (`wait'0b'`),
then highlighting (`wait'0c'`).
`completion.zsh` owns `compinit -i`; fzf and zoxide initialize after completion is ready.
Native completion still initializes when Zinit or its completion plugin is missing.
Autosuggestions use history only, with an 80-character buffer limit.

Install missing plugins and the gitstatus binary explicitly with `make zsh-plugins`;
this does not update existing plugin repositories.
`GITSTATUS_AUTO_INSTALL=0` disables daemon downloads during prompt startup.

## Shell integration

When installed, fzf provides the only added `Ctrl-R` history-search widget;
`history-search-multi-word` is not loaded.
`Ctrl-T` selects files and `Alt-C` selects directories.
The integration uses `fzf --zsh`; installed fzf must support that option.
When `fd` is available, file/directory selection includes hidden paths and excludes `.git`.
mise activates in `tools.zsh`, which also installs the standard `direnv hook zsh`.

## Customize the Prompt

Edit `PROMPT_*` variables at the top of `zsh.d/prompt.zsh`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `PROMPT_COLOR_DIR` | 6 (aqua) | Directory color, ANSI index |
| `PROMPT_COLOR_GIT_BRANCH` | 2 (emerald) | Git branch color, ANSI index |
| `PROMPT_SHOW_GIT` | true | Show git status |
| `PROMPT_SHOW_VIRTUALENV` | true | Show virtualenv |
| `PROMPT_SHOW_KUBECTL` | true | Show cached Kubernetes context |
| `PROMPT_GIT_TIMEOUT` | 0.05 seconds | Per-call wait for pending daemon initialization and queries |

Reload with `exec zsh` or `zshreload`; do not repeatedly source `~/.zshrc`.
Prompt segments are built in a `precmd` hook so their caches remain in the parent shell.
Pending daemon initialization and the subsequent query each use `PROMPT_GIT_TIMEOUT` separately;
this is not a total prompt-update deadline.
If the Git daemon cannot start or fails, the prompt falls back to `vcs_info`.
A timed-out query from a healthy daemon omits the Git segment rather than starting a second scan.
The Kubernetes cache tracks `KUBECONFIG` paths and file identity, modification time, and size,
including multi-file configurations.

## Quick Aliases

| Alias | Does |
|-------|------|
| `ls` | Native `/bin/ls -G` (avoids lsd's iCloud timeouts) |
| `lsl` / `lsll` / `lsla` / `lslt` | Explicit lsd/eza alternatives |
| `catt` / `batp` | bat without paging / bat with plain style |
| `vim` | Neovim (nvim) |
| `g` / `gs` / `ga` / `gc` | git shortcuts |
| `t` / `ta` / `tn` / `tl` | tmux shortcuts |
| `zshreload` | Replace the current shell with `exec zsh` |

`cat`, `grep`, `find`, `ps`, `du`, `df`, and `tree` retain their native command behavior.
Use `bat`, `rg`, `fd`, and other enhanced tools explicitly.

## Check Startup Time

```zsh
make benchmark
```

On macOS, `scripts/benchmark-shell.zsh` reports `non_tty_median_ms` and `pty_median_ms`
from seven samples per mode, following one warmup run each.
PTY measurements include the `script` wrapper overhead.
These measure startup-and-exit, not time to the first prompt or deferred plugin readiness.
Record the machine and installed dependencies when comparing results.
Results vary with caches, filesystem state, and repository size; no fixed startup time is promised.
Use `make test` for the optional installed-plugin PTY check, then verify interactive behavior manually.

See [REFERENCE.md](REFERENCE.md) for complete alias list.
