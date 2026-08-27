# AGENTS.md

Agent-focused guidance for working in this macOS dotfiles repository. Every entry answers: "Would an agent likely miss this?"

## OpenCode Integration

This repository is **100% OpenCode-native**. All agents, skills, and rules are configured in `.opencode/opencode.json`.

### Quick Start with OpenCode

```bash
# Invoke the primary agent (shadow-architect)
@shadow-architect audit this repository
@shadow-architect review the ZSH configuration

# Load a specific skill
@shadow-architect /skill load validate-dotfiles
@shadow-architect /skill load zsh-modules

# Invoke specialized agents
@rankle audit for security vulnerabilities
@atticus audit README.md for Diátaxis compliance
@daedalus review the Makefile for best practices
```

### Available Agents

- **shadow-architect** — Meta-orchestrator, defines standards, coordinates work
- **rankle** — Purple Team lead, orchestrates security assessments
- **puck** — Defensive security executor (scans, audits, hardening)
- **shadow** — Offensive security executor (exploitation, PoCs)
- **daedalus** — Infrastructure/IaC architect (Terraform, DevSecOps)
- **atticus** — Documentation architect (Markdown, Diátaxis, style)

### Available Skills

Skills are now consolidated into rules for better maintainability. Only 4 unique skills remain:

- **makefile-targets** — Quick reference of all Makefile targets
- **neovim-setup** — Neovim plugin configuration guide
- **tmux-config** — Tmux keybindings and configuration guide
- **zsh-modules** — ZSH module loading order guide

**Note:** Detailed knowledge is now in rules (see below). Skills are quick references only.

### Available Rules

All project standards and best practices are defined in rules:

**Universal Rules:**
- `communication.rule.md` — English-only, concise, no filler
- `code-quality.rule.md` — DRY, KISS, SOLID principles
- `safety.rule.md` — Non-destructive, research-first
- `reporting.rule.md` — Clear findings, actionable recommendations

**Stack Rules:**
- `shell.rule.md` — Shell scripting, ZSH setup, environment configuration
- `github.rule.md` — Git workflow, conventional commits, co-author requirement
- `opencode.rule.md` — OpenCode configuration, permissions, agent usage
- `makefile.rule.md` — Makefile targets, installation order, idempotency
- `neovim.rule.md` — Neovim configuration, lazy.nvim, LSP setup
- `tmux.rule.md` — Tmux configuration, keybindings, clipboard integration
- `zsh.rule.md` — ZSH modules, loading order, plugin management
- `markdown.rule.md` — Markdown style and conventions
- `diagrams.rule.md` — Diagram standards
- `flutter.rule.md` — Flutter development standards
- `python.rule.md` — Python development standards
- `color.rule.md` — Color scheme standards
- `zensical.rule.md` — Zensical documentation standards

### Configuration Files

- **.opencode/opencode.json** — Project-level configuration (default agent, permissions, skills paths)
- **.opencode/CLAUDE.md** — OpenCode integration guide (workflows, troubleshooting)
- **AGENTS.md** — This file (agent guidance and project constraints)
- **rules/** — Universal and stack-specific standards

### Key Principle

**Read AGENTS.md first.** It's the source of truth for agent guidance and project constraints. All agents load this file as an instruction.

---

## What This Repo Is

Personal macOS development dotfiles. All components symlink into `~/.zshrc`, `~/.zsh.d/`, `~/.config/nvim/`, `~/.tmux.conf`, and `~/.config/kitty/`. macOS-only. Single source of truth is `Makefile`.

## Critical Commands (Agents Often Miss)

```bash
make verify              # ALWAYS run before editing config — checks deps and system state
make all                 # Full install: Xcode -> Homebrew -> mise -> profile -> tools -> Kitty
make profile             # Symlink only (zsh, neovim, tmux, git) — faster than `make all`
bash scripts/validate-configs.sh  # Validates tmux syntax, ZSH modules, clipboard

# After edits, reload without re-running install:
source ~/.zshrc
tmux source-file ~/.tmux.conf
nvim +"Lazy sync" +qa
```

**Why:** Agents often re-run full installs when `make profile` suffices. Config validation is critical before committing.

## Installation Order Matters

`make all` chains these targets in order. Each is idempotent but order is enforced:

1. `check-xcode` -> Xcode CLT (blocking dialog may appear)
2. `brew` -> Homebrew
3. `mise` -> Version manager (modern ASDF replacement)
4. `profile` -> Symlink configs
5. `tools` -> CLI utilities (bat, lsd, fd, ripgrep, fzf, zoxide, etc.)
6. `kitty` -> Kitty terminal + JetBrains Mono

**Why:** Later stages depend on earlier stages being present. Do not skip or reorder.

## Configuration Validation is Strict

Pre-commit hooks (`.pre-commit-config.yaml`) block commits on:

- ShellCheck on `.sh` files (but **ZSH modules in `zsh.d/` are excluded** — they're sourced, not executed)
- Syntax validation via `scripts/validate-configs.sh` on `tmux.conf`, `zshrc`, `zsh.d/*.zsh`
- YAMLLint, Markdownlint, Typos, Gitleaks

**Why:** Broken config files break the entire environment. Agents must validate before committing.

## ZSH Loading Order is Strict

`zshrc` is the entry point. It auto-starts tmux (login shells only with TTY), bootstraps Zinit, then sources 10 core modules from `~/.zsh.d/` in this exact order:

```text
env.zsh -> options.zsh -> history.zsh -> plugins.zsh -> prompt.zsh →
completion.zsh -> colors.zsh -> kitty.zsh -> alias.zsh -> tools.zsh
```

**Note:** `oracle.zsh` (user-specific Oracle DB config) is optional and untracked — see **Optional Local Modules** section below.

**Critical:** `tools.zsh` is the integration hub (mise, fzf, bat config, zoxide). Changes here affect everything downstream.

**Why:** Out-of-order sourcing breaks PATH, aliases, and shell features. Agents often edit the wrong module or insert code in the wrong place.

## Repository Structure & Ownership

| Path | Purpose | Never Delete |
|------|---------|--------------|
| `zshrc` | Entry point -> `~/.zshrc` | **YES** |
| `zsh.d/` | 10 core modular config files | **YES** — all 10 required |
| `nvim/` | Neovim config -> `~/.config/nvim/` | YES |
| `tmux.conf` | Tmux config -> `~/.tmux.conf` | YES |
| `kitty.conf` | Kitty config -> `~/.config/kitty/` | YES |
| `gitignore_global` | Global gitignore -> `~/.gitignore_global` | YES |
| `Makefile` | Installer & orchestrator | YES |
| `.pre-commit-config.yaml` | Git hooks | YES |
| `scripts/validate-configs.sh` | Config validation | YES |
| `.opencode/` | OpenCode configuration | YES |
| `docs/*.dotfiles.md` | Reference docs (per-technology) | NO — reference only |

**Why:** Agents might accidentally delete or skip critical modules, breaking the entire system.

## Quirks That Will Trip Agents

### 1. Tmux Supports `C-a` as Primary Prefix (GNU Screen-compatible)

Primary prefix is `C-a` (not default `C-b`). Set as `prefix` and `prefix2` for GNU Screen compatibility. Code uses `bind C-a` to support this. All custom bindings should respect this dual-prefix setup.

### 2. Tmux Has Native `pbcopy`/`pbpaste`, No tmux-yank

Copy-mode-vi `y` pipes directly to `pbcopy`. Mouse drag/triple-click also use `pbcopy`. Do not add `tmux-yank` plugin — it conflicts.

### 3. `ls` Uses Native `/bin/ls -G`, Not `lsd`

Native `ls` avoids iCloud/network file timeout issues (`os error 60`). `lsd` available explicitly via `lsl` / `lsll` / `lslt` aliases when safe.

### 4. Prompt Uses `gitstatus`, Not vcs_info

`prompt.zsh` uses **gitstatus** for ~47ms git status (not vcs_info). Falls back to vcs_info if gitstatus unavailable. Fast startup critical.

### 5. Prompt is Parametrized, Not Templated

Customize by editing `PROMPT_*` variables at the top of `zsh.d/prompt.zsh` directly. No separate config file exists.

### 6. Tmux Auto-Start in Login Shells Only

Tmux auto-starts in login shells with a TTY (not in non-interactive shells or IDEs). This prevents unexpected terminal multiplexing in environments like VS Code or Claude Code.

**Guard in zshrc:**
```bash
if [[ -z "$TMUX" ]] && [[ -o login ]] && [[ -t 0 ]]; then
  exec tmux new-session -A -s main
fi
```

**Why:** Simplified startup logic; IDE-specific handling deferred to environment configuration.

### 7. Version Manager: mise (Not ASDF)

Uses `mise` (modern ASDF replacement). Makefile has `mise use --global <tool>@latest`. Language versions: Node.js (LTS even-numbered), Go, Ruby, Terraform.

**Why:** Agents unfamiliar with mise might call ASDF commands. Agents might add `tmux-yank` or change `ls` alias. Agents might edit the wrong prompt variables.

## Sensitive Configuration Files

Files in `.gitignore` — never create, edit, or commit these:

| File | Purpose | Why Excluded |
|------|---------|--------------|
| `.env` | Environment variables with secrets | Contains sensitive credentials |
| `secrets/` | Sensitive configuration files | Contains sensitive data |
| `credentials/` | API keys and tokens | Contains sensitive data |

These are intentionally excluded from version control. Agents should never write to them or attempt to commit them.

**Note:** `claude.zsh` and `CLAUDE.md` have been removed. Use `.opencode/CLAUDE.md` for OpenCode integration guidance instead.

## Optional Local Modules

These are untracked local-only configs. Agents may encounter them but **should not commit**:

- `zsh.d/oracle.zsh` — User-specific Oracle Database client paths (if developer uses Oracle SQL)
- Any future `*.zsh` files in `zsh.d/` not committed to repo

**How to add local config safely:**
```bash
# 1. Create new module in zsh.d/
echo "# My local config" > zsh.d/mylocal.zsh

# 2. Source it in zshrc after tools.zsh
# (add: source "${ZSH_CONFIG_DIR}/mylocal.zsh")

# 3. Add filename to .gitignore
echo "zsh.d/mylocal.zsh" >> .gitignore

# 4. Validate
bash scripts/validate-configs.sh
```

**Why:** Keeps personal/environment-specific configs separate from tracked configurations.

## Documentation Policy

- `README.md`: Main docs (Quick Start, Tech Stack, Structure, Usage)
- `docs/*.dotfiles.md`: Per-technology reference (zsh, tmux, neovim, kitty, makefile, mise, github)
- `AGENTS.md`: Agent guidance and project constraints (source of truth)
- **Never create other `.md` files** (reports, changelogs, analysis). Only edit these three locations.

**Note:** `.opencode/` files are separate configuration for OpenCode agent infrastructure:
- `.opencode/opencode.json` — Project-level OpenCode configuration
- `.opencode/CLAUDE.md` — OpenCode integration guide (replaces root CLAUDE.md)
- `.opencode/skills/` — Reusable knowledge modules for agents

**Why:** Agents often create new markdown files instead of updating existing ones.

## How to Verify Work

After any change:

```bash
# 1. Validate syntax
bash scripts/validate-configs.sh

# 2. Verify system state
make verify

# 3. Test a focused component
make zsh          # ZSH only
make tmux         # Tmux only
make neovim       # Neovim only

# 4. Git hooks run automatically before commit
git commit -m "your message"  # Blocks if validation fails
```

**Why:** Agents often skip validation or don't know what commands verify correctness.

## Common Agent Mistakes

1. **Editing wrong module** — Modifying `alias.zsh` when edit should be in `tools.zsh`
2. **Reordering ZSH sources** — Breaks PATH and subsequent modules
3. **Changing tmux prefix or removing pbcopy** — Breaks clipboard workflow
4. **Adding `tmux-yank`** — Conflicts with native bindings
5. **Editing `claude.zsh`** — Should never be committed (in .gitignore)
6. **Creating new markdown docs** — Should update existing docs only
7. **Running `make all` when `make profile` suffices** — Wastes time
8. **Forgetting `make verify` before changes** — Detects prereq issues early
9. **Not running validation before commit** — Pre-commit hooks catch later
10. **Changing `ls` alias to `lsd`** — Causes network timeouts on iCloud

**Why:** These are real mistakes found in version history and common in multi-session edits.

## Symlink Model

All config files are **symlinked from repo** into home directory:

- `~/.zshrc` -> `$DOTFILES/zshrc`
- `~/.zsh.d` -> `$DOTFILES/zsh.d`
- `~/.config/nvim` -> `$DOTFILES/nvim`
- `~/.tmux.conf` -> `$DOTFILES/tmux.conf`
- `~/.config/kitty/kitty.conf` -> `$DOTFILES/kitty.conf`
- `~/.gitignore_global` -> `$DOTFILES/gitignore_global`

Where `$DOTFILES` = `/Users/javiercoscolla/.dotfiles` (or `$(pwd)` from repo root).

**Why:** Agents should edit files in the repo, not the home directory. Editing `~/.zshrc` directly breaks the symlink.

## Branching & Contributing

**Single-feature workflow:**
- Work on feature branch (`feature/name`) or `develop`
- Commit to feature branch with conventional commits (`feat:`, `fix:`, `refactor:`, etc.)
- Open PR: `feature/*` -> `develop` or `feature/*` -> `main`
- All changes must pass `make verify` and `bash scripts/validate-configs.sh`
- Squash merge to target branch; auto-delete after merge
- Pre-commit hooks are enforced — fix issues and retry commit

**Multi-feature coordination (if multiple in-flight):**
- Don't merge feature branches directly to `main` if `develop` is ahead
- Coordinate merge order: stabilize on `develop` first, then to `main`
- Use descriptive PR titles and commit messages
- Reference issues in commits: `fixes #123` auto-closes on merge

**Commit requirements:**
- **Co-author all commits** with: `Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>`
- Message format: `type(scope): description` (e.g. `feat(zsh): add new plugin`)
- No force-push, no `git reset --hard`, no squashing after merge

**Why:** Personal repo but CI/CD enforced. Agents need to know not to force-push or skip validation. Multi-feature coordination prevents merge conflicts and ensures stable main branch.
