# Neovim Configuration

Fast, extensible Lua config.
Plugin manager: `lazy.nvim`. LSP servers auto-installed via Mason.

## Structure

```text
nvim/
├── init.lua              # Bootstrap: lazy.nvim setup
├── lazy-lock.json        # Plugin version lockfile
└── lua/
    ├── config/
    │   ├── options.lua   # vim.opt settings
    │   ├── keymaps.lua   # Global keymaps
    │   └── autocmds.lua  # Autocommands
    └── plugins/
        ├── editor.lua    # Theme, explorer, statusline, git
        ├── lsp.lua       # LSP servers (Mason)
        ├── completion.lua # Autocompletion
        └── treesitter.lua # Syntax parsing
```

## Language Support (LSP)

| Language | Server |
|----------|--------|
| Lua | lua_ls |
| Python | pyright |
| TypeScript/JavaScript | ts_ls |
| Go | gopls |
| Rust | rust_analyzer |
| Bash | bashls |
| JSON/YAML | jsonls, yamlls |

Install via `:Mason` command.

## Core Plugins

| Plugin | What it does |
|--------|--------------|
| `folke/tokyonight.nvim` | Theme (Night) |
| `nvim-neo-tree/neo-tree.nvim` | File explorer |
| `nvim-telescope/telescope.nvim` | Fuzzy finder |
| `nvim-lualine/lualine.nvim` | Statusline |
| `lewis6991/gitsigns.nvim` | Git diff signs |
| `hrsh7th/nvim-cmp` | Autocompletion |

## Essential Keybindings

Leader = `<Space>`

| Key | Action |
|-----|--------|
| `C-n` | Toggle file explorer |
| `C-p` | Find files |
| `<leader>fg` | Search text |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format buffer |
| `[d` / `]d` | Previous/next diagnostic |

See [REFERENCE.md](REFERENCE.md) for full keybindings.

## Common Commands

```bash
# Reset (clean install)
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
nvim   # Lazy.nvim installs plugins

# Update plugins
nvim +"Lazy sync" +qa

# Manage LSP
:Mason              # Install servers
:LspInfo            # Check status
```
