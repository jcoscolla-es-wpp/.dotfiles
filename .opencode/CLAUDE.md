# OpenCode Integration Guide

This file provides guidance for working with this dotfiles repository using **OpenCode** agents and skills.

## What is OpenCode?

OpenCode is an AI-native development platform that coordinates multiple specialized agents to solve complex problems. This repository is configured to use:

- **Shadow Architect** — Meta-orchestrator, defines standards and coordinates work
- **Rankle** — Purple Team lead, orchestrates security assessments
- **Puck** — Defensive security executor (scans, audits, hardening)
- **Shadow** — Offensive security executor (exploitation, PoCs)
- **Daedalus** — Infrastructure/IaC architect (Terraform, DevSecOps)
- **Atticus** — Documentation architect (Markdown, Diátaxis, style)

## Invoking Agents

### Primary Agent: Shadow Architect

```bash
@shadow-architect audit this repository
@shadow-architect review the ZSH configuration
@shadow-architect should we refactor the Makefile?
```

### Specialized Agents

```bash
# Security audit
@rankle audit the dotfiles for security vulnerabilities

# Infrastructure review
@daedalus review the Makefile for IaC best practices

# Documentation audit
@atticus audit README.md for Diátaxis compliance
```

## Available Skills

Skills are specialized knowledge modules that agents load automatically. You can also load them manually:

### Core Skills

1. **env-setup** — Installation order, prerequisites, troubleshooting
2. **makefile-targets** — All Makefile targets reference and when to use
3. **neovim-setup** — lazy.nvim configuration, LSP, Mason
4. **shell-best-practices** — Shell scripting patterns and conventions
5. **tmux-config** — Prefix bindings, pbcopy integration, keybindings
6. **validate-dotfiles** — Syntax checking, architecture compliance
7. **zsh-modules** — Loading order, module responsibilities
8. **git-workflow** — Conventional commits, co-author requirement, branch strategy
9. **opencode-integration** — How to use agents, skills, and rules

### Loading Skills Manually

```bash
@shadow-architect /skill load env-setup
@shadow-architect /skill load validate-dotfiles
```

## Project-Specific Rules

This project follows strict standards defined in `AGENTS.md` and `rules/**/*.rule.md`:

### Universal Rules

- **communication.rule.md** — English-only, concise, no filler
- **code-quality.rule.md** — DRY, KISS, SOLID principles
- **safety.rule.md** — Non-destructive, research-first
- **reporting.rule.md** — Clear findings, actionable recommendations

### Stack Rules

- **shell.rule.md** — Shell scripting standards
- **github.rule.md** — GitHub workflow and CI/CD
- **opencode.rule.md** — OpenCode configuration standards

## Common Workflows

### Workflow 1: Validate Configuration Changes

```bash
@shadow-architect validate these config changes
# Agent will:
# 1. Load validate-dotfiles skill
# 2. Check syntax (tmux, zsh, neovim)
# 3. Verify architecture compliance
# 4. Run pre-commit hooks
# 5. Report findings
```

### Workflow 2: Add a New ZSH Module

```bash
@shadow-architect I want to add a new ZSH module for X. What's the checklist?
# Agent will:
# 1. Load zsh-modules skill
# 2. Explain loading order
# 3. Suggest which module should own the config
# 4. Provide validation steps
# 5. Suggest commit message
```

### Workflow 3: Security Audit

```bash
@rankle audit this repository for security vulnerabilities
# Rankle will:
# 1. Delegate to @puck (defensive scanning)
# 2. Delegate to @shadow (offensive testing)
# 3. Synthesize findings into MITRE ATT&CK-tagged report
# 4. Provide remediation roadmap
```

### Workflow 4: Documentation Review

```bash
@atticus audit README.md for Diátaxis compliance
# Atticus will:
# 1. Check structure (tutorials, how-tos, reference, explanation)
# 2. Verify semantic line breaks
# 3. Check for active voice, present tense
# 4. Report style violations
# 5. Suggest improvements
```

## Project Configuration

### opencode.json

Located at `.opencode/opencode.json`, this file configures:

- **Default agent:** shadow-architect
- **Instructions:** AGENTS.md, this file, and all rules
- **Skills paths:** `.opencode/skills/`
- **Permissions:** Restrictive for safety (no webfetch, limited bash)
- **Compaction:** Auto-enabled for long sessions

### AGENTS.md

The source of truth for agent guidance and project constraints. Read this first before working with agents.

### Rules

Located in `rules/**/*.rule.md`:
- Universal rules apply to all work
- Stack-specific rules apply to shell, GitHub, OpenCode, etc.

## Permissions & Safety

This project has strict permissions:

✅ **Allowed:**
- Read all files (except `.env`, `.claude/`)
- Git operations (status, log, diff, add, commit, etc.)
- Bash: make, zsh -n, validation scripts
- Edit files (with confirmation)

❌ **Denied:**
- Dangerous bash: `rm -rf`, `git reset --hard`, `git clean`
- Force-push: `git push --force`
- Sudo operations
- File permission changes

⚠️ **Ask First:**
- Edits to any file
- Git push/pull/checkout/branch/merge/rebase
- File operations (rm, mv, cp, mkdir)

## Troubleshooting

### Agent Won't Load a Skill

```bash
# Verify skill exists
ls .opencode/skills/

# Check skill frontmatter
head -10 .opencode/skills/<skill-name>/SKILL.md

# Restart opencode (config is loaded once at startup)
# Exit and restart opencode
```

### Permissions Denied

Check `.opencode/opencode.json` `permission` section. If you need to allow a command:

1. Edit `.opencode/opencode.json`
2. Add the command to the appropriate `bash` rule
3. Restart opencode
4. Retry the operation

### Configuration Error

If opencode won't start:

```bash
# Use escape hatch to bypass project config
OPENCODE_DISABLE_PROJECT_CONFIG=1 opencode

# Edit .opencode/opencode.json to fix the error
# Restart opencode normally
```

## Best Practices

1. **Always validate before committing**
   ```bash
   @shadow-architect validate these changes
   make verify
   bash scripts/validate-configs.sh
   ```

2. **Use conventional commits with co-author**
   ```bash
   git commit -m "feat(zsh): add new module" \
     -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
   ```

3. **Load relevant skills for complex tasks**
   ```bash
   @shadow-architect /skill load validate-dotfiles
   @shadow-architect /skill load zsh-modules
   # Now ask your question
   ```

4. **Reference AGENTS.md for constraints**
   - Read AGENTS.md before starting work
   - Understand the quirks (tmux prefix, ls alias, etc.)
   - Follow the architecture documented there

5. **Keep OpenCode config minimal**
   - Use skills for detailed knowledge
   - Use rules for standards
   - Use AGENTS.md for guidance

## References

- **AGENTS.md** — Agent guidance and project constraints (read first!)
- **README.md** — Project overview and quick start
- **docs/*.dotfiles.md** — Per-technology reference
- **Makefile** — All installation and configuration targets
- **rules/** — Universal and stack-specific standards
- **.opencode/opencode.json** — Project configuration

---

**Maintained By:** Shadow Architect + Human collaboration  
**Authority:** This file is the OpenCode integration guide for the dotfiles project  
**Last Updated:** August 27, 2026
