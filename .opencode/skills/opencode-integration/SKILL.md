---
name: opencode-integration
description: How to use OpenCode agents, skills, and rules in this dotfiles project. Use when learning to work with agents or understanding project configuration.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: opencode-usage
  tags: opencode,agents,skills,configuration
---

# OpenCode Integration Skill

Complete guide to using OpenCode with this dotfiles project.

## What is OpenCode?

OpenCode is an AI-native development platform that coordinates multiple specialized agents to solve complex problems. It provides:

- **Agents** — Specialized AI workers (shadow-architect, rankle, puck, shadow, daedalus, atticus)
- **Skills** — Reusable knowledge modules (env-setup, validate-dotfiles, zsh-modules, etc.)
- **Rules** — Standards and constraints (universal and stack-specific)
- **Permissions** — Safety guardrails for bash, file operations, etc.

## Project Configuration

### opencode.json

Located at `.opencode/opencode.json`, this file configures:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "shadow-architect",
  "instructions": ["AGENTS.md", ".opencode/CLAUDE.md", "rules/**/*.rule.md"],
  "skills": { "paths": [".opencode/skills"] },
  "permission": { ... }
}
```

**Key settings:**
- **default_agent:** shadow-architect (meta-orchestrator)
- **instructions:** AGENTS.md, this guide, and all rules
- **skills.paths:** `.opencode/skills/` (auto-discovered)
- **permissions:** Restrictive for safety

### AGENTS.md

The source of truth for agent guidance and project constraints. Read this first.

### Rules

Located in `rules/**/*.rule.md`:
- **Universal rules** — Apply to all work (communication, code-quality, safety, reporting)
- **Stack rules** — Apply to specific technologies (shell, github, opencode, etc.)

## Available Agents

### Shadow Architect (Primary)

Meta-orchestrator who defines standards and coordinates work.

**Invoke:**
```bash
@shadow-architect audit this repository
@shadow-architect review the ZSH configuration
@shadow-architect should we refactor the Makefile?
```

**Capabilities:**
- Architecture reviews
- Standards enforcement
- Tech debt prioritization
- Cross-domain coordination
- Delegation to specialized agents

### Rankle (Purple Team Lead)

Orchestrates security assessments (defensive + offensive).

**Invoke:**
```bash
@rankle audit this repository for security vulnerabilities
@rankle perform a full security engagement
```

**Capabilities:**
- Coordinates @puck (defensive) and @shadow (offensive)
- Synthesizes findings into MITRE ATT&CK-tagged reports
- Provides remediation roadmaps

### Puck (Defensive Security)

Scans for vulnerabilities, misconfigurations, and hardening.

**Invoke:**
```bash
@rankle delegate to puck for defensive scanning
```

**Tools:**
- nmap, nuclei, sslscan, openssl, whatweb, httpx

### Shadow (Offensive Security)

Builds proof-of-concept exploits and attack chains.

**Invoke:**
```bash
@rankle delegate to shadow for offensive testing
```

**Capabilities:**
- Exploitation testing
- Attack chain development
- Business impact demonstration

### Daedalus (Infrastructure/IaC)

Terraform and DevSecOps architect.

**Invoke:**
```bash
@daedalus review the Makefile for IaC best practices
@daedalus audit infrastructure configuration
```

**Capabilities:**
- Terraform module review
- SLSA compliance
- DevSecOps standards

### Atticus (Documentation)

Documentation architect (Markdown, Diátaxis, style).

**Invoke:**
```bash
@atticus audit README.md for Diátaxis compliance
@atticus review documentation standards
```

**Capabilities:**
- Diátaxis framework compliance
- Markdown style enforcement
- Documentation health scoring

## Available Skills

Skills are specialized knowledge modules. Agents load them automatically, or you can load manually:

```bash
@shadow-architect /skill load env-setup
@shadow-architect /skill load validate-dotfiles
```

### Core Skills

1. **env-setup** — Installation order, prerequisites, troubleshooting
2. **makefile-targets** — All Makefile targets reference
3. **neovim-setup** — lazy.nvim, LSP, Mason configuration
4. **shell-best-practices** — Shell scripting patterns
5. **tmux-config** — Prefix, pbcopy, keybindings
6. **validate-dotfiles** — Syntax, architecture, validation
7. **zsh-modules** — Loading order, module responsibilities
8. **git-workflow** — Conventional commits, co-author, branch strategy
9. **opencode-integration** — This skill (how to use OpenCode)

### Skill Auto-Discovery

OpenCode automatically discovers skills from `.opencode/skills/*/SKILL.md`. Each skill must have:

```markdown
---
name: skill-name
description: What this skill does and when to use it
---

# Skill Content
...
```

## Common Workflows

### Workflow 1: Validate Configuration Changes

```bash
@shadow-architect validate these config changes
```

**What happens:**
1. Agent loads `validate-dotfiles` skill
2. Checks syntax (tmux, zsh, neovim)
3. Verifies architecture compliance
4. Runs pre-commit hooks
5. Reports findings

### Workflow 2: Add a New ZSH Module

```bash
@shadow-architect I want to add a new ZSH module for X. What's the checklist?
```

**What happens:**
1. Agent loads `zsh-modules` skill
2. Explains loading order
3. Suggests which module should own the config
4. Provides validation steps
5. Suggests commit message

### Workflow 3: Security Audit

```bash
@rankle audit this repository for security vulnerabilities
```

**What happens:**
1. Rankle delegates to @puck (defensive scanning)
2. Rankle delegates to @shadow (offensive testing)
3. Synthesizes findings into MITRE ATT&CK-tagged report
4. Provides remediation roadmap

### Workflow 4: Documentation Review

```bash
@atticus audit README.md for Diátaxis compliance
```

**What happens:**
1. Checks structure (tutorials, how-tos, reference, explanation)
2. Verifies semantic line breaks
3. Checks for active voice, present tense
4. Reports style violations
5. Suggests improvements

### Workflow 5: Makefile Review

```bash
@shadow-architect review the Makefile for best practices
```

**What happens:**
1. Agent loads `makefile-targets` skill
2. Reviews target organization
3. Checks for idempotency
4. Verifies dependency ordering
5. Suggests improvements

## Permissions & Safety

This project has strict permissions to prevent accidents:

### ✅ Allowed

- Read all files (except `.env`, `.claude/`)
- Git operations (status, log, diff, add, commit, etc.)
- Bash: `make`, `zsh -n`, validation scripts
- Edit files (with confirmation)

### ❌ Denied

- Dangerous bash: `rm -rf`, `git reset --hard`, `git clean`
- Force-push: `git push --force`
- Sudo operations
- File permission changes

### ⚠️ Ask First

- Edits to any file
- Git push/pull/checkout/branch/merge/rebase
- File operations (rm, mv, cp, mkdir)

### Checking Permissions

View current permissions in `.opencode/opencode.json`:

```json
"permission": {
  "read": { "*": "allow", "*.env": "deny" },
  "edit": "ask",
  "bash": { "make *": "allow", "rm -rf *": "deny" }
}
```

### Modifying Permissions

To allow a new command:

1. Edit `.opencode/opencode.json`
2. Add the command to the appropriate `bash` rule
3. Restart opencode (config is loaded once at startup)
4. Retry the operation

**Example:**
```json
"bash": {
  "make *": "allow",
  "my-custom-script *": "allow",  // Add this
  "*": "ask"
}
```

## Rules & Standards

### Universal Rules

Apply to all work in this project:

- **communication.rule.md** — English-only, concise, no filler
- **code-quality.rule.md** — DRY, KISS, SOLID principles
- **safety.rule.md** — Non-destructive, research-first
- **reporting.rule.md** — Clear findings, actionable recommendations

### Stack Rules

Apply to specific technologies:

- **shell.rule.md** — Shell scripting standards
- **github.rule.md** — GitHub workflow and CI/CD
- **opencode.rule.md** — OpenCode configuration standards

### How Rules Work

Agents load rules from `rules/**/*.rule.md` and apply them to all work. Rules are:

- **Enforceable** — Agents follow them strictly
- **Overridable** — User can request exceptions (with justification)
- **Documented** — Each rule explains its purpose and rationale

## Troubleshooting

### Agent Won't Load a Skill

**Problem:** Skill not found or not loading

**Solution:**
```bash
# Verify skill exists
ls .opencode/skills/

# Check skill frontmatter
head -10 .opencode/skills/<skill-name>/SKILL.md

# Restart opencode (config is loaded once at startup)
# Exit and restart opencode
```

### Permissions Denied

**Problem:** Command blocked by permissions

**Solution:**
1. Check `.opencode/opencode.json` `permission` section
2. Add the command to the appropriate `bash` rule
3. Restart opencode
4. Retry the operation

### Configuration Error

**Problem:** opencode won't start due to config error

**Solution:**
```bash
# Use escape hatch to bypass project config
OPENCODE_DISABLE_PROJECT_CONFIG=1 opencode

# Edit .opencode/opencode.json to fix the error
# Restart opencode normally
```

### Agent Behavior Unexpected

**Problem:** Agent not following expected workflow

**Solution:**
1. Check AGENTS.md for agent guidance
2. Load relevant skills manually: `@agent /skill load skill-name`
3. Provide more context in your request
4. Reference specific rules or constraints

## Best Practices

1. **Read AGENTS.md first** — It's the source of truth
2. **Load relevant skills** — Use `/skill load` for complex tasks
3. **Validate before committing** — Always run validation
4. **Use conventional commits** — With co-author (Roy Batty)
5. **Reference rules** — Cite specific rules when requesting exceptions
6. **Keep config minimal** — Use skills for details
7. **Restart after config changes** — Config is loaded once at startup

## Configuration Files

### .opencode/opencode.json

Project-level configuration:
- Default agent
- Instructions
- Skills paths
- Permissions
- Compaction settings

### AGENTS.md

Agent guidance and project constraints:
- What this repo is
- Critical commands
- Architecture details
- Common mistakes
- Branching strategy

### .opencode/CLAUDE.md

OpenCode integration guide (this project):
- How to invoke agents
- Available skills
- Common workflows
- Permissions & safety
- Troubleshooting

### rules/**/*.rule.md

Standards and constraints:
- Universal rules (all work)
- Stack-specific rules (shell, github, opencode, etc.)

## References

- **AGENTS.md** — Agent guidance (read first!)
- **README.md** — Project overview
- **docs/*.dotfiles.md** — Per-technology reference
- **Makefile** — All targets and commands
- **.opencode/opencode.json** — Project configuration
- **rules/** — Standards and constraints

---

**Maintained By:** Shadow Architect  
**Authority:** OpenCode integration guide for this project  
**Last Updated:** August 27, 2026
