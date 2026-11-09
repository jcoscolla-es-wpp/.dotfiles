# ~/.dotfiles

Personal macOS development environment managed via a single `Makefile`.

[![macOS](https://img.shields.io/badge/macOS-Ventura%2B-black?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/Shell-ZSH-green?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/Editor-Neovim-57A143?style=flat-square&logo=neovim&logoColor=white)](https://neovim.io/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

[![Validate (Ubuntu)](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/validate.yml/badge.svg)](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/validate.yml)
[![Validate (macOS)](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/validate-macos.yml/badge.svg)](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/validate-macos.yml)
[![Security](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/security.yml/badge.svg)](https://github.com/jcoscolla-es-wpp/.dotfiles/actions/workflows/security.yml)

---

## Quick Start

```zsh
git clone https://github.com/jcoscolla-es-wpp/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

make verify   # Check system prerequisites
make all      # Full install: Homebrew → mise → configs → tools → Kitty
exec zsh
```

> macOS only. Review the code before running — these are personal dotfiles. Fork and adapt.

---

## Key Features

- **Explicit installation** — `make all` installs tools and configs; existing configs are backed up without overwriting backups
- **Modular ZSH** — ten ordered core modules, Zinit, and four declared plugins installed through Makefile
- **Predictable commands** — native Unix tools keep their names; fzf owns `Ctrl-R` history search
- **Unified theme** — Emerald Arcana (emerald and violet) across Kitty, Tmux, Neovim, fzf, bat, and the prompt
- **Native clipboard** — tmux copy-mode wired to `pbcopy`/`pbpaste`; no plugins
- **Version management** — mise handles Node.js, Go, Ruby, and Terraform side-by-side

---

## Tech Stack

| Component | Tool | Notes |
|-----------|------|-------|
| Shell | [ZSH](https://www.zsh.org/) + [Zinit](https://github.com/zdharma-continuum/zinit) | Plugin manager with deferred loading |
| Prompt | [gitstatus](https://github.com/romkatv/gitstatus) | Bounded queries; vcs_info fallback if the daemon is unavailable |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated, Emerald Arcana theme |
| Multiplexer | [Tmux](https://github.com/tmux/tmux) | Prefix `C-a`, native pbcopy bindings |
| Editor | [Neovim](https://neovim.io/) + [lazy.nvim](https://github.com/folke/lazy.nvim) | LSP via Mason, Lua config |
| Versions | [mise](https://mise.jdx.dev/) | Node.js, Go, Ruby, Terraform |
| Packages | [Homebrew](https://brew.sh/) | Everything else |

---

## Project Structure

```text
~/.dotfiles/
├── Makefile                    # Installer, safe linking, validation, tests
├── zshrc                       # ZSH entry point → ~/.zshrc
├── zsh.d/                      # Modular ZSH → ~/.zsh.d/
│   ├── env.zsh                 # Environment & PATH
│   ├── options.zsh             # ZSH options
│   ├── history.zsh             # History config
│   ├── plugins.zsh             # Four-plugin Zinit registry
│   ├── prompt.zsh              # Parametrizable prompt (PROMPT_* vars)
│   ├── completion.zsh          # Completion initialization and styles
│   ├── colors.zsh              # less, ls and completion colors
│   ├── dircolors               # LS_COLORS source (ANSI codes)
│   ├── kitty.zsh               # Kitty integration
│   ├── alias.zsh               # Aliases (lsd, bat, git, tmux)
│   ├── tools.zsh               # mise, fzf, bat, zoxide integration
│   └── aws.zsh                 # Optional generic AWS cost helper
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
│   ├── link-config.zsh         # Safe config linking and owned-link cleanup
│   ├── validate-configs.zsh    # Isolated tmux parsing and static checks
│   ├── test-shell.zsh          # Regression tests in disposable homes
│   └── benchmark-shell.zsh     # macOS startup-and-exit medians, non-TTY and PTY
└── docs/                       # Per-technology reference docs
```

---

## Usage

### Install individual components

```zsh
make profile    # Install profile configs and missing shell plugins/TPM
make zsh        # ZSH config, Zinit, and declared plugins
make zsh-plugins # Install missing shell plugins without relinking configs
make neovim     # Neovim only
make tmux       # Tmux + TPM
make tools      # CLI utilities (bat, lsd, fd, ripgrep, fzf, zoxide)
make clean      # Remove only this repository's config links
```

### Validate after changes

```zsh
make validate   # Syntax/static checks; private tmux socket; clipboard untouched
make test       # Validator plus regression tests in disposable homes
make verify     # Report system prerequisites; install nothing
make benchmark  # macOS warm startup-and-exit medians; not plugin-ready latency
```

The validator checks clipboard bindings and command availability, not clipboard contents or behavior.
`make test` includes an installed-plugin PTY check when Zinit, its editing/completion plugins,
fzf, and zoxide are present; otherwise it reports a skip.
Check actual interactive behavior in a terminal as well.

### Customize the prompt

Edit `PROMPT_*` variables at the top of `zsh.d/prompt.zsh` directly — no separate config file.

```zsh
$EDITOR zsh.d/prompt.zsh
exec zsh
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
