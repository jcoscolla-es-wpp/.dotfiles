# Kitty Terminal Configuration

GPU-accelerated rendering with rich features, native macOS integration.
Theme: Emerald Arcana. Font: JetBrains Mono 10pt.

## Core Settings

| Setting | Value |
|---------|-------|
| Font | JetBrains Mono 10pt |
| Cell height | 120% (increased line spacing) |
| Background opacity | 0.93 (frosted glass effect) |
| Background blur | 50 (macOS frosted glass) |
| Scrollback | 10,000 lines |
| Initial size | 1200×700 |
| Window padding | 12px |
| Cursor | Block, blinking 550ms |

## Keyboard Shortcuts

`kitty_mod` = `Cmd` (macOS native)

### Window & Tab Management

| Shortcut | Action |
|----------|--------|
| `cmd+n` | New OS window |
| `cmd+t` | New tab |
| `cmd+w` | Close window/tab |
| `cmd+enter` | New split |
| `cmd+]`/`cmd+[` | Next/prev split |
| `cmd+shift+right/left` | Next/prev tab |
| `cmd+1-9` | Go to tab N |
| `cmd+l` | Next layout |

### Transparency & Scrolling

| Shortcut | Action |
|----------|--------|
| `cmd+shift+a` | Increase opacity +0.1 |
| `cmd+shift+s` | Decrease opacity -0.1 |
| `cmd+shift+d` | Reset to default opacity |
| `cmd+k` | Clear scrollback |
| `cmd+shift+k` | Reset terminal |
| `cmd+shift+,` | Reload config |

### Search & Navigation

| Shortcut | Action |
|----------|--------|
| `cmd+f` | Search in scrollback (fzf overlay) |
| `cmd+up/down` | Scroll line |
| `cmd+page_up/down` | Scroll page |

## Theme (Emerald Arcana)

Emerald and violet on a violet-black background. `scripts/palette.zsh` is the single source of
truth for every hex in the repository. Kitty, tmux, fzf, and Neovim copy its values, and
`make validate` fails when one of them uses a hex outside the palette. Contrast is WCAG against
the background; text needs 4.5 or more.

| Role | Color | Used for |
|------|-------|----------|
| Background | `#13101f` | Terminal, tmux, Neovim |
| Surface | `#1d1830` | Inactive tabs, bars, ANSI black |
| Foreground | `#dcd7f0` | Text (13.39) |
| Comment | `#8a82ab` | Comments, ANSI bright black, autosuggestions (5.23) |
| Emerald | `#2fd49b` | Primary, active, success (9.82) |
| Violet | `#a98bf5` | Accent, focus, active tab and border (6.86) |
| Aqua | `#52d6c8` | Information, ANSI cyan (10.53) |
| Amber | `#e8b46a` | Warning, bell (9.96) |
| Rose | `#f2728c` | Error (6.74) |
| Orchid | `#d38cf5` | Kubernetes, ANSI magenta (7.88) |
| Indigo | `#8aa0f7` | ANSI blue (7.54) |
| Fox | `#f0985a` | Orange detail (8.33) |

The prompt, `less`, `ls`, completion lists (`zsh.d/dircolors`), and `bat` (`ansi` theme) use
ANSI indexes 0-15 only, so the terminal palette decides their colors. Indexes 16-255 ignore it.

## macOS Features

- Seamless titlebar integration
- Wide color gamut (Display P3) on modern Macs
- Remote control via `kitty @` CLI
- Copy-on-select (mouse drag → clipboard)

## Transparency Adjustment

```conf
# More transparent
background_opacity 0.88
background_blur 40

# More frosted
background_opacity 0.95
background_blur 70
```

## Reload Config

**Keyboard:** `cmd+shift+,`

**Terminal:**

```bash
kill -SIGUSR1 $(pgrep kitty)
```

## Tab Bar

Fade style (smooth gradient). Shows activity + tab index. Hidden when only 1 tab open.

See [REFERENCE.md](REFERENCE.md) for all Kitty shortcuts.
