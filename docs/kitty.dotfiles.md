# Kitty Terminal Configuration

GPU-accelerated rendering with rich features, native macOS integration.
Theme: TokyoNight Night. Font: JetBrains Mono 10pt.

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

## Theme (TokyoNight Night)

| Role | Color |
|------|-------|
| Foreground | `#c0caf5` |
| Background | `#1a1b26` |
| Selection bg | `#33467c` |
| Active border | `#7aa2f7` |
| Active tab | `#7aa2f7` |
| Inactive tab | `#292e42` |
| Tab bar | `#15161e` |

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
