# AGENTS.md

Agent guidance for this macOS dotfiles repository.
The global `~/.config/opencode/AGENTS.md` also applies: it governs safety, Git
workflow, permissions, and models. This file adds only project-specific rules.

**Last Updated:** 2026-11-06

## What This Repo Is

Personal macOS dotfiles. Files are symlinked from the repo into the home directory,
so edit them here, never under `~`.

| Repo path | Symlinked to |
|-----------|--------------|
| `zshrc` | `~/.zshrc` |
| `zsh.d/` | `~/.zsh.d/` |
| `nvim/` | `~/.config/nvim/` |
| `tmux.conf` | `~/.tmux.conf` |
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `gitignore_global` | `~/.gitignore_global` |

`Makefile` is the single installer. `$DOTFILES` is `/Users/javiercoscolla/.dotfiles`.

## Shell Policy: zsh Only

Write every script, hook, and snippet in zsh (`#!/usr/bin/env zsh`, `.zsh` extension).
Do not write bash. The only exception is the upstream Homebrew installer in the
`Makefile`, which requires bash.
The Makefile runs recipes with `/bin/zsh -eu -o pipefail` and disables parallel execution.

ShellCheck does not understand zsh, so `.zsh` files are excluded from it in
`.pre-commit-config.yaml` and the CI ShellCheck job.

## Verify Before Committing

OpenCode V2 does not run language servers, so verification is command-based.

```zsh
make validate                     # isolated tmux parsing, zsh syntax, static bindings
make test                         # regression tests in disposable homes
zsh -dfn zsh.d/<module>.zsh        # syntax of one module, without startup files
make verify                       # report system dependencies; install nothing
make benchmark                    # macOS startup-and-exit medians, non-TTY and PTY
```

The local startup target is under 110 ms, not a published measurement or the CI runner budget.
Distinguish non-TTY measurements from PTY measurements; repeat samples on the same machine.
Pre-commit runs the validator plus Markdownlint, YAMLLint, Typos, and Gitleaks, not the regression suite.
The validator uses a disposable tmux socket and never reads or writes clipboard contents.
Test prompt changes in a real pty (`script -q /dev/null zsh -ic '...'`);
gitstatus cannot start without a TTY.
`make test` includes a real-plugin PTY check when dependencies are installed; a skip is not a pass.

Use `make profile` to relink configs. Do not run `make all` when it is not needed.

## Rules to Read

OpenCode V2 does not inject rule contents. Read the relevant file before changing
code, from `~/.config/opencode/rules/`:

- ZSH config, scripts, prompt, startup: `stacks/zsh.rule.md`
- Markdown: `stacks/markdown.rule.md`
- Git: `stacks/github.rule.md`
- Tmux, Neovim, Makefile: `stacks/tmux.rule.md`, `stacks/neovim.rule.md`, `stacks/makefile.rule.md`

## ZSH Loading Order

`zshrc` starts tmux (login shells with a TTY only), initializes installed Zinit, then sources
the core modules from `~/.zsh.d/` in this exact order. Never reorder them.

```text
env -> options -> history -> plugins -> prompt -> completion -> colors -> kitty -> alias -> tools
```

Install Zinit and the declared plugins with `make zsh`; use `make zsh-plugins` to repair missing plugins.
Do not clone dependencies during interactive startup.
Keep `GITSTATUS_AUTO_INSTALL=0`; `make zsh-plugins` installs the gitstatus binary explicitly.
`ZINIT_HOME` and `ZSH_CONFIG_DIR` may be overridden for isolated tests.
Completion initialization belongs to `completion.zsh`, independent of highlighting.
Deferred order is completions/tool integration (`0a`), autosuggestions (`0b`), highlighting (`0c`).
fzf is the sole `Ctrl-R` integration; do not restore `history-search-multi-word`.

Optional modules load afterwards, only when the file exists:

| Module | Status | Purpose |
|--------|--------|---------|
| `aws.zsh` | Tracked, generic | `awscost`: month-to-date AWS cost |
| `oracle.zsh` | Local, untracked (`.gitignore`) | Machine-specific Oracle client paths |

Place new code in the module that owns it: PATH and variables in `env.zsh`,
options in `options.zsh`, aliases in `alias.zsh`, tool integrations in `tools.zsh`.
A new generic helper gets its own tracked module sourced from the optional loop in
`zshrc`. Machine-specific config is local: add it to `.gitignore`.

## Quirks That Break Things

- **`ls` stays native** (`/bin/ls -G`). `lsd` is explicit via `lsl`, `lsll`, `lsla`,
  `lslt`, because it times out on iCloud paths (`os error 60`).
- **Standard commands stay native:** `cat`, `grep`, `find`, `ps`, `du`, `df`, and `tree`.
  Use enhanced tools by their own names; keep aliases in `alias.zsh`.
- **Reload with `exec zsh`** (`zshreload`), not repeated sourcing of `~/.zshrc`.
- **Tmux prefix is `C-a`** (also `prefix2`). Copy uses native `pbcopy`/`pbpaste`;
  do not add `tmux-yank`.
- **Tmux keys must not collide:** `p` selects the previous window, `]` pastes,
  root `C-l` navigates right, and `C-a C-r` sends clear-screen to the application.
  Preserve resurrect/continuum restoration and native Neovim-aware routing.
- **Prompt segments are built in a `precmd` hook** (`prompt.zsh`), never in `$(...)`:
  a subshell loses caches and forks per prompt. Edit the `PROMPT_*` variables at the top.
- **`TERM` is not forced.** Kitty integration keys off `KITTY_WINDOW_ID`.
- **PATH is deduplicated** by `typeset -U path PATH` in `env.zsh`.
- **mise replaces ASDF.** Use `mise use --global <tool>@latest`.
- **Guard optional tools** with `command -v` and PATH entries with `[[ -d ]]`.
- **Avoid zsh special names** in scripts: `status`, `path`, `commands`, `options`.
- **Use the shared link helper** in Makefile recipes; never overwrite an existing `.backup`.
  `make clean` removes only links resolving to this repository's config sources.

## Never Commit

- `.env`, `secrets/`, `credentials/`, `zsh.d/oracle.zsh`
- OpenCode runtime directories and `service.json`, `cli.json`, `settings.json`

## Documentation

Edit existing files only: `README.md`, `docs/*.dotfiles.md`, and this file.
Do not create reports, changelogs, or other Markdown files.

## Git Workflow

- Branches: only `main` and `develop`. No feature branches; never delete either.
- Work on `develop`. Open a PR `develop` -> `main` and squash merge.
- Refuse a squash merge from `develop` while GitHub "delete branch on merge" is on.
  It was disabled on 2026-10-15; verify with
  `gh repo view --json deleteBranchOnMerge`.
- Conventional Commits with scope, for example `feat(zsh): add helper`.
- Every commit carries `Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>`.
- Never force-push or `git reset --hard`.
- Remote is HTTPS: `https://github.com/jcoscolla-es-wpp/.dotfiles.git`.

## Common Mistakes

1. Reordering the `source` lines in `zshrc`.
2. Editing `~/.zshrc` instead of the repo file, which breaks the symlink.
3. Putting aliases in `tools.zsh` or integrations in `alias.zsh`.
4. Computing prompt data inside `$(...)`.
5. Writing a bash script, or adding a `.zsh` file to ShellCheck.
6. Committing without running `zsh scripts/validate-configs.zsh`.
7. Creating new Markdown files instead of editing the existing ones.
