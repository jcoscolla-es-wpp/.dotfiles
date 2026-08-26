# Tmux Configuration

Session persistence and vim-style pane navigation.
Theme: TokyoNight Night. Prefix: `C-a` (GNU Screen style).

## Core Settings

| Setting | Value |
|---------|-------|
| Prefix | `C-a` (also supports `C-b`) |
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
| `prefix + r` | Reload config |

## Pane Navigation (Vim-style)

| Binding | Action |
|---------|--------|
| `C-h/j/k/l` | Navigate panes (aware of Neovim splits) |
| `prefix + h/j/k/l` | Navigate panes (explicit) |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + -` | Split horizontal (current path) |
| `prefix + _` | Split vertical (current path) |
| `prefix + >` / `<` | Swap pane forward/back |

## Copy Mode (vi keys)

| Binding | Action |
|---------|--------|
| `prefix + [` | Enter copy mode |
| `Space` | Begin selection |
| `C-v` | Rectangle selection |
| `y` | Copy to `pbcopy` (macOS clipboard) |
| `Enter` | Copy to `pbcopy` and exit |
| `H` / `L` | Jump to line start/end |

**Mouse actions:** Drag, double-click, and triple-click all copy to `pbcopy`.
**Paste:** `prefix + ]` or right-click.

## Clipboard Design

No plugins. Native `pbcopy` integration:
- `y` in copy mode pipes directly to `pbcopy`
- Mouse drag/double-click also use `pbcopy`
- Right-click pastes via `pbpaste`

Troubleshoot:
```bash
tmux list-keys -T copy-mode-vi | grep "y send"
tmux show -g mouse
```

## Neovim Integration

Pane navigation (`C-h/j/k/l`) is aware of Neovim splits via `vim-tmux-navigator` plugin. Seamless switching between tmux panes and Neovim windows.

## Plugins (TPM)

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tmux-sensible` | Sensible defaults |
| `tmux-plugins/tmux-resurrect` | Save/restore sessions |
| `tmux-plugins/tmux-continuum` | Auto-save every 15 min |
| `christoomey/vim-tmux-navigator` | Neovim split navigation |

Resurrect saves nvim sessions and pane contents. Continuum auto-restores on tmux start.

## Install & Reload

```bash
make tmux              # Symlink + install TPM
tmux source-file ~/.tmux.conf  # Reload live
# In tmux:
prefix + I             # Install TPM plugins
prefix + U             # Update TPM plugins
```

## Color Scheme (TokyoNight Night)

| Element | Color |
|---------|-------|
| Background | `#1a1b26` |
| Foreground | `#c0caf5` |
| Active border/accent | `#7aa2f7` |
| Active window | `#7dcfff` |
| Inactive | `#565f89` |
| Success | `#9ece6a` |

See [REFERENCE.md](REFERENCE.md) for tmux quick bindings.
