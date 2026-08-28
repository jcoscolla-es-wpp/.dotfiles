# ZSH Configuration

Fast, modular shell config.
Startup: ~47ms thanks to lazy-loaded plugins via Zinit.
All config lives in `zsh.d/` — edit independently, changes take effect on next shell.

## Loading Order

Modules load in sequence. Order matters, but each is independent.

```text
zshrc
  ├─ env.zsh          — PATH, locale, EDITOR
  ├─ options.zsh      — Shell options (AUTO_CD, PUSHD, etc.)
  ├─ history.zsh      — History (10k lines, deduplicated)
  ├─ plugins.zsh      — Zinit + lazy plugins
  ├─ prompt.zsh       — Git-aware prompt (customize via PROMPT_* vars)
  ├─ completion.zsh   — Completion styles
  ├─ colors.zsh       — LS_COLORS
  ├─ kitty.zsh        — Kitty integration
  ├─ alias.zsh        — Shortcuts (git, tmux, etc.)
  └─ tools.zsh        — mise, fzf, bat, zoxide
```

## Key Plugins

| Plugin | What it does |
|--------|--------------|
| `romkatv/gitstatus` | Fast git prompt (~5ms) |
| `zsh-users/zsh-completions` | Better completions |
| `zsh-users/zsh-autosuggestions` | Command history suggestions |
| `zdharma-continuum/fast-syntax-highlighting` | Syntax highlighting |

## Customize the Prompt

Edit `PROMPT_*` variables at the top of `zsh.d/prompt.zsh`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `PROMPT_COLOR_DIR` | 31 (red) | Directory color |
| `PROMPT_COLOR_GIT_BRANCH` | 76 (blue) | Git branch color |
| `PROMPT_SHOW_GIT` | true | Show git status |
| `PROMPT_SHOW_VIRTUALENV` | true | Show virtualenv |

Changes take effect on next shell.

## Quick Aliases

| Alias | Does |
|-------|------|
| `ls` | Native ls (faster, avoids iCloud timeouts) |
| `cat` | bat (syntax highlight) |
| `grep` | ripgrep (rg) |
| `find` | fd-find (fd) |
| `vim` | Neovim (nvim) |
| `g` / `gs` / `ga` / `gc` | git shortcuts |
| `t` / `ta` / `tn` / `tl` | tmux shortcuts |

## Check Startup Time

```bash
time zsh -i -c exit    # Should be ~47ms
```

See [REFERENCE.md](REFERENCE.md) for complete alias list.
