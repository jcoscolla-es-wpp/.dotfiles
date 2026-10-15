# ~/.dotfiles

Personal macOS development environment managed via a single `Makefile`.

[![macOS](https://img.shields.io/badge/macOS-Ventura%2B-black?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/Shell-ZSH-green?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/Editor-Neovim-57A143?style=flat-square&logo=neovim&logoColor=white)](https://neovim.io/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

[![Validate (Ubuntu)](https://github.com/javicosvml/.dotfiles/actions/workflows/validate.yml/badge.svg)](https://github.com/javicosvml/.dotfiles/actions/workflows/validate.yml)
[![Validate (macOS)](https://github.com/javicosvml/.dotfiles/actions/workflows/validate-macos.yml/badge.svg)](https://github.com/javicosvml/.dotfiles/actions/workflows/validate-macos.yml)
[![Security](https://github.com/javicosvml/.dotfiles/actions/workflows/security.yml/badge.svg)](https://github.com/javicosvml/.dotfiles/actions/workflows/security.yml)

---

## Quick Start

```bash
git clone https://github.com/javicosvml/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

make verify   # Check system prerequisites
make all      # Full install: Homebrew → mise → configs → tools → Kitty
source ~/.zshrc
```

> macOS only. Review the code before running — these are personal dotfiles. Fork and adapt.

---

## Key Features

- **One-command install** — `make all` chains every step idempotently; safe to re-run
- **Modular ZSH** — 11 ordered modules in `zsh.d/` with ~47ms startup via gitstatus
- **Unified theme** — TokyoNight Night across Kitty, Neovim, and Tmux
- **Native clipboard** — tmux copy-mode wired to `pbcopy`/`pbpaste`; no plugins
- **Version management** — mise handles Node.js, Go, Ruby, and Terraform side-by-side

---

## Tech Stack

| Component | Tool | Notes |
|-----------|------|-------|
| Shell | [ZSH](https://www.zsh.org/) + [Zinit](https://github.com/zdharma-continuum/zinit) | Plugin manager with deferred loading |
| Prompt | [gitstatus](https://github.com/romkatv/gitstatus) | ~47ms; falls back to vcs_info |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated, TokyoNight theme |
| Multiplexer | [Tmux](https://github.com/tmux/tmux) | Prefix `C-a`, native pbcopy bindings |
| Editor | [Neovim](https://neovim.io/) + [lazy.nvim](https://github.com/folke/lazy.nvim) | LSP via Mason, Lua config |
| Versions | [mise](https://mise.jdx.dev/) | Node.js, Go, Ruby, Terraform |
| Packages | [Homebrew](https://brew.sh/) | Everything else |

---

## Project Structure

```text
~/.dotfiles/
├── Makefile                    # Unified installer — all targets idempotent
├── zshrc                       # ZSH entry point → ~/.zshrc
├── zsh.d/                      # Modular ZSH → ~/.zsh.d/
│   ├── env.zsh                 # Environment & PATH
│   ├── options.zsh             # ZSH options
│   ├── history.zsh             # History config
│   ├── plugins.zsh             # Zinit plugins
│   ├── prompt.zsh              # Parametrizable prompt (PROMPT_* vars)
│   ├── completion.zsh          # Deferred completions
│   ├── colors.zsh              # ls color schemes
│   ├── kitty.zsh               # Kitty integration
│   ├── alias.zsh               # Aliases (lsd, bat, git, tmux)
│   ├── tools.zsh               # mise, fzf, bat, zoxide integration
│   └── claude.zsh              # Claude Code / AWS Bedrock (untracked)
├── nvim/                       # Neovim → ~/.config/nvim/
│   ├── init.lua                # Bootstraps lazy.nvim
│   ├── lazy-lock.json          # Plugin version lockfile
│   └── lua/
│       ├── config/             # Options, keymaps, autocmds
│       └── plugins/            # LSP, treesitter, editor, completion
├── tmux.conf                   # Tmux → ~/.tmux.conf
├── kitty.conf                  # Kitty → ~/.config/kitty/kitty.conf
├── gitignore_global            # Global gitignore → ~/.gitignore_global
├── scripts/
│   └── validate-configs.zsh    # Validates tmux syntax, ZSH modules, clipboard
└── docs/                       # Per-technology reference docs
```

---

## Usage

### Install individual components

```bash
make profile    # Symlink all configs (zsh, neovim, tmux, git)
make zsh        # ZSH only
make neovim     # Neovim only
make tmux       # Tmux + TPM
make tools      # CLI utilities (bat, lsd, fd, ripgrep, fzf, zoxide)
make clean      # Remove all symlinks
```

### Validate after changes

```bash
zsh scripts/validate-configs.zsh   # tmux syntax, ZSH modules, clipboard
make verify                        # System prerequisites check
```

### Customize the prompt

Edit `PROMPT_*` variables at the top of `zsh.d/prompt.zsh` directly — no separate config file.

```bash
$EDITOR ~/.zsh.d/prompt.zsh
source ~/.zshrc
```

### Tmux clipboard (copy-mode-vi)

| Action | Key |
|--------|-----|
| Enter copy mode | `C-a [` |
| Start selection | `Space` |
| Copy to clipboard | `y` or `Enter` |
| Paste | `C-a ]` |
| Paste from system | Right-click |

Mouse drag, double-click, and triple-click all pipe directly to `pbcopy`.

---

## Documentation

| Document | Purpose |
|----------|---------|
| [docs/zsh.dotfiles.md](docs/zsh.dotfiles.md) | ZSH loading order, plugins, prompt variables, aliases |
| [docs/tmux.dotfiles.md](docs/tmux.dotfiles.md) | Key bindings, clipboard, Neovim integration |
| [docs/neovim.dotfiles.md](docs/neovim.dotfiles.md) | Plugin list, LSP servers, key bindings |
| [docs/kitty.dotfiles.md](docs/kitty.dotfiles.md) | Terminal settings, shortcuts, theme |
| [docs/makefile.dotfiles.md](docs/makefile.dotfiles.md) | All Makefile targets reference |
| [docs/mise.dotfiles.md](docs/mise.dotfiles.md) | mise version manager and managed runtimes |
| [docs/devops.dotfiles.md](docs/devops.dotfiles.md) | CI/CD workflows, GitHub Actions, branch protection |
| [docs/github.dotfiles.md](docs/github.dotfiles.md) | GitHub DevSecOps config, branching strategy |

---

## Contributing

This is a personal configuration repository. Contributions are not expected, but issues and forks are welcome.

Branching: work on `develop`, merge to `main` via PR. See [docs/github.dotfiles.md](docs/github.dotfiles.md) for the full workflow.

## License

[MIT](LICENSE)
