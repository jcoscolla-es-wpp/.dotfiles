# Tmux Configuration

Session persistence and vim-style pane navigation.
Theme: Emerald Arcana. Prefix: `C-a` (GNU Screen style).

## Core Settings

| Setting | Value |
|---------|-------|
| Prefix | `C-a` for both `prefix` and `prefix2`; `C-b` is unbound |
| Terminal | `tmux-256color` (RGB support) |
| History | 50,000 lines |
| Mouse | On (scrolling, selection, resize) |
| Base index | 1 (windows and panes start at 1) |
| Status bar refresh | 10s |

## Session & Window Management

| Binding | Action |
|---------|--------|
| `prefix + C-c` | New session |
| `prefix + C-f` | Find/switch session |
| `prefix + BTab` | Last session |
| `prefix + c` | New window |
| `prefix + Tab` | Last window |
| `prefix + C-h`/`C-l` | Previous/next window |
| `prefix + p`/`n` | Previous/next window |
| `prefix + r` | Reload config |
| `prefix + m` | Toggle mouse mode |

## Pane Navigation (Vim-style)

| Binding | Action |
|---------|--------|
| `C-h/j/k/l` | Navigate panes (aware of Neovim splits) |
| `prefix + h/j/k/l` | Navigate panes (explicit) |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + -` | Split horizontal (current path) |
| `prefix + _` | Split vertical (current path) |
| `prefix + >` / `<` | Swap pane forward/back |
| `prefix + C-r` | Send `C-l` to the application (shell clear-screen) |

Unprefixed `C-l` navigates right or passes through to Neovim; it is not a shell clear-screen binding.

## Copy Mode (vi keys)

| Binding | Action |
|---------|--------|
| `prefix + [` | Enter copy mode |
| `Space` or `v` | Begin selection |
| `C-v` | Rectangle selection |
| `y` | Copy to `pbcopy` (macOS clipboard) and exit |
| `Enter` | Copy to `pbcopy` and exit |
| `H` / `L` | Jump to line start/end |

**Mouse actions:** Drag, double-click, and triple-click all copy to `pbcopy`.
**Paste:** `prefix + ]` or right-click.

## Clipboard Design

No clipboard plugin. Native `pbcopy` integration:

- `y` in copy mode pipes directly to `pbcopy`
- Mouse drag/double-click also use `pbcopy`
- Right-click pastes via `pbpaste`

Troubleshoot:

```zsh
tmux list-keys -T copy-mode-vi | grep "y send"
tmux show -g mouse
```

## Neovim Integration

Native tmux bindings route `C-h/j/k/l` to Neovim when it is running, otherwise to tmux panes.
The Neovim-side `vim-tmux-navigator` plugin handles editor splits.
No duplicate tmux-side navigator plugin is loaded.

## Plugins (TPM)

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tmux-sensible` | Sensible defaults |
| `tmux-plugins/tmux-resurrect` | Save/restore sessions |
| `tmux-plugins/tmux-continuum` | Auto-save every 15 min |

Resurrect saves nvim sessions and pane contents.
Continuum auto-restores on tmux start when the plugins are installed.
TPM loads only when its executable exists.

## Install & Reload

```zsh
make tmux              # Symlink + install TPM
tmux source-file ~/.tmux.conf  # Reload live
# In tmux:
prefix + I             # Install TPM plugins
prefix + U             # Update TPM plugins
```

Use `make validate` for isolated parse-only checks, not a live reload.
`make test` checks effective bindings on a private tmux server without running clipboard commands.

## Color Scheme (Emerald Arcana)

The full palette lives in `scripts/palette.zsh` and is documented in `kitty.dotfiles.md`.

| Element | Color |
|---------|-------|
| Background | `#13101f` |
| Foreground | `#dcd7f0` |
| Session segment and messages | `#2fd49b` |
| Active window and border | `#a98bf5` |
| Inactive text | `#8a82ab` |
| Inactive pane border | `#3a3160` |
| User and host | `#52d6c8` |
| Bell | `#e8b46a` |

See [REFERENCE.md](REFERENCE.md) for tmux quick bindings.
