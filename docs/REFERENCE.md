# Quick Reference

Personal dotfiles quick lookup table. For detailed info, see individual docs.

---

## Components Overview

| Component | Location | Version | Key Binding | Docs |
|-----------|----------|---------|-------------|------|
| **Shell** | `zshrc` + `zsh.d/` | ZSH 5.9+ | — | [zsh.dotfiles.md](zsh.dotfiles.md) |
| **Editor** | `nvim/` | Neovim 0.10+ | `<leader>` = Space | [neovim.dotfiles.md](neovim.dotfiles.md) |
| **Terminal** | `kitty.conf` | Kitty 0.32+ | `kitty_mod` = Cmd | [kitty.dotfiles.md](kitty.dotfiles.md) |
| **Multiplexer** | `tmux.conf` | Tmux 3.4+ | `prefix` = Ctrl-A | [tmux.dotfiles.md](tmux.dotfiles.md) |
| **Installer** | `Makefile` | GNU Make | `make` targets | [makefile.dotfiles.md](makefile.dotfiles.md) |
| **Version Mgr** | `~/.tool-versions` | mise (latest) | `mise` commands | [mise.dotfiles.md](mise.dotfiles.md) |

---

## Critical Keybindings

### Tmux (prefix = `C-a`)

| Action | Key |
|--------|-----|
| New session | `prefix + C-c` |
| New window | `prefix + c` |
| New pane (horizontal) | `prefix + -` |
| New pane (vertical) | `prefix + _` |
| Navigate panes | `C-h/j/k/l` (vim-aware) |
| Copy mode | `prefix + [` |
| Paste | `prefix + ]` |
| Reload config | `prefix + r` |

### Neovim (leader = `<Space>`)

| Action | Key |
|--------|-----|
| Toggle file explorer | `C-n` or `<leader>n` |
| Fuzzy find files | `C-p` or `<leader>ff` |
| Fuzzy find text | `<leader>fg` |
| Go to definition | `gd` |
| Code action | `<leader>ca` |
| Rename symbol | `<leader>rn` |
| Format buffer | `<leader>f` |
| Toggle comment | `gcc` |
| Split horizontal | `<leader>sh` |
| Split vertical | `<leader>sv` |

### Kitty (mod = `Cmd`)

| Action | Key |
|--------|-----|
| New window | `cmd+n` |
| New tab | `cmd+t` |
| New split | `cmd+enter` |
| Close split/tab | `cmd+w` |
| Next/prev tab | `cmd+shift+right/left` |
| Next/prev split | `cmd+]/[` |
| Clear scrollback | `cmd+k` |
| Search scrollback | `cmd+f` |
| Reload config | `cmd+shift+,` |

---

## Makefile Essentials

| Target | Purpose |
|--------|---------|
| `make all` | Full install: Xcode → Homebrew → mise → configs → tools → Kitty |
| `make verify` | Check system prerequisites |
| `make profile` | Symlink zsh + nvim + tmux + git configs only |
| `make update` | `brew upgrade` + `mise upgrade` all tools |
| `make clean` | Remove all symlinks |
| `make zsh` | Install ZSH config only |
| `make neovim` | Install Neovim config only |
| `make tmux` | Install Tmux config + TPM |
| `make tools` | Install CLI utilities (bat, lsd, fd, rg, fzf, zoxide, etc.) |
| `make nodejs` | Install Node.js LTS via mise |
| `make kubernetes` | Install kubectl, helm, kind, kubectx |

---

## ZSH Aliases

| Alias | Expands To | Use |
|-------|-----------|-----|
| `ls` | `/bin/ls -G` | Native ls (avoids iCloud timeout) |
| `lsl`/`lsll`/`lslt` | lsd variants | When safe to use |
| `cat` | `bat --paging=never` | Syntax-highlighted cat |
| `grep` | `rg` | ripgrep |
| `find` | `fd` | fd-find |
| `vi`/`vim` | `nvim` | Neovim |
| `brewup` | brew update+upgrade+cleanup | Homebrew maintenance |
| `g` | `git` | Git shortcut |
| `gs`/`gst` | `git status` | Status |
| `ga` | `git add` | Add |
| `gc` | `git commit` | Commit |
| `gp` | `git push` | Push |
| `t` | `tmux` | Tmux |
| `ta` | `tmux attach` | Attach to session |
| `tn` | `tmux new` | New session |
| `tl` | `tmux list-sessions` | List sessions |

---

## Startup & Reload

| Task | Command |
|------|---------|
| **Reload ZSH** | `source ~/.zshrc` |
| **Reload Tmux** | `tmux source-file ~/.tmux.conf` |
| **Reload Kitty** | `cmd+shift+,` (in Kitty) or `kill -SIGUSR1 $(pgrep kitty)` |
| **Update Neovim plugins** | `nvim +"Lazy sync" +qa` |
| **Update all tools** | `make update` |
| **Profile ZSH startup** | `time zsh -i -c exit` |
| **Validate configs** | `bash scripts/validate-configs.sh` |

---

## Symlinks

All configs are symlinked from repo into home directory. **Edit in repo, not home.**

| Home Directory | Symlinks To |
|---|---|
| `~/.zshrc` | `$DOTFILES/zshrc` |
| `~/.zsh.d/` | `$DOTFILES/zsh.d/` |
| `~/.config/nvim` | `$DOTFILES/nvim/` |
| `~/.tmux.conf` | `$DOTFILES/tmux.conf` |
| `~/.config/kitty/kitty.conf` | `$DOTFILES/kitty.conf` |
| `~/.gitignore_global` | `$DOTFILES/gitignore_global` |

---

## Managed Tools (via mise)

| Tool | Latest | Set With |
|------|--------|----------|
| Node.js | LTS even (20, 22, 24…) | `mise use --global node@lts` |
| Go | Latest stable | `mise use --global go@latest` |
| Ruby | Latest stable | `mise use --global ruby@latest` |
| Terraform | Latest stable | `mise use --global terraform@latest` |
| kubectl | Latest stable | `mise use --global kubectl@latest` |
| Helm | Latest stable | `mise use --global helm@latest` |
| kind | Latest stable | `mise use --global kind@latest` |
| AWS CLI | Latest stable | `mise use --global awscli@latest` |

---

## Git Workflow

| Step | Command |
|------|---------|
| **Start feature** | `git checkout -b feat/name develop` |
| **Stage changes** | `git add -p` |
| **Commit** | `git commit -m "feat(scope): description"` |
| **Push** | `git push -u origin feat/name` |
| **Open PR** | `gh pr create --base develop` |
| **Merge to develop** | `gh pr merge <#> --squash --delete-branch` |
| **PR to main** | `gh pr create --base main` |
| **Merge to main** | `gh pr merge <#> --squash` |

**Commit types:** `feat`, `fix`, `docs`, `refactor`, `chore`, `test`

---

## Validation

Run before opening PR:

```bash
bash scripts/validate-configs.sh    # All checks
make verify                         # System prereqs
zsh -n zshrc                        # ZSH syntax
for f in zsh.d/*.zsh; do zsh -n "$f"; done  # All modules
tmux source-file ~/.tmux.conf       # Tmux syntax
```

---

## Troubleshooting

| Issue | Debug |
|-------|-------|
| **ZSH startup slow** | `for f in zsh.d/*.zsh; do time zsh -n "$f"; done` |
| **Tmux clipboard broken** | `tmux list-keys -T copy-mode-vi \| grep "y send"` |
| **Neovim LSP not working** | `:Mason` (install servers), `:LspInfo` (check status) |
| **Kitty config not loading** | `kitty --check-config`, `cmd+shift+,` to reload |
| **Git workflow failing** | Run `bash scripts/validate-configs.sh` locally first |

---

## Documentation

- **[README.md](../README.md)** — Overview, quick start, key features
- **[zsh.dotfiles.md](zsh.dotfiles.md)** — ZSH modules, plugins, prompt, aliases
- **[neovim.dotfiles.md](neovim.dotfiles.md)** — LSP servers, plugins, keybindings
- **[tmux.dotfiles.md](tmux.dotfiles.md)** — Key bindings, clipboard, Neovim integration
- **[kitty.dotfiles.md](kitty.dotfiles.md)** — Terminal settings, themes, shortcuts
- **[makefile.dotfiles.md](makefile.dotfiles.md)** — All installer targets
- **[mise.dotfiles.md](mise.dotfiles.md)** — Version manager, managed tools
- **[github.dotfiles.md](github.dotfiles.md)** — Branching, commits, workflows
- **[devops.dotfiles.md](devops.dotfiles.md)** — CI/CD workflows, automation
