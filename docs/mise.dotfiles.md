# mise Version Manager

Modern replacement for ASDF.
Installed via Homebrew. Activated in `zsh.d/tools.zsh`.
Reads `~/.tool-versions` (ASDF-compatible) and supports `mise.toml` for per-project overrides.

## Managed Tools

Install each via Makefile target:

| Tool | Command | Notes |
|------|---------|-------|
| Node.js | `make nodejs` | Latest LTS (even-numbered: 20, 22, 24…) |
| Go | `make golang` | Latest stable |
| Ruby | `make ruby` | Latest stable |
| Terraform | `make terraform` | Latest stable |
| kubectl | `make kubectl` | Latest stable |
| Helm | `make helm` | Latest stable |
| kind | `make kind` | Latest stable |
| AWS CLI | `make aws` | Latest stable |

## Quick Commands

```bash
mise ls                        # List all tools + versions
mise current                   # Show active version per tool
mise use --global node@lts     # Set Node.js LTS globally
mise upgrade                   # Upgrade all tools to latest
mise which node                # Show path to binary
```

## Version Resolution

mise checks in this order:
1. `mise.toml` in current or parent directory
2. `.tool-versions` in current or parent directory
3. Global config at `~/.config/mise/config.toml`
4. Global fallback at `~/.tool-versions` (current setup)

Set project version:
```bash
cd ~/my-project
mise use node@20    # Creates .mise.toml in project root
```

## Update Tools

```bash
make update           # brew upgrade mise + mise upgrade all
mise upgrade go       # Upgrade specific tool
```
