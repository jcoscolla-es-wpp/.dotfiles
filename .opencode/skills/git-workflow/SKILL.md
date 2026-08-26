---
name: git-workflow
description: Git workflow, conventional commits, co-author requirement, and branch strategy. Use when committing changes, creating PRs, or managing branches.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: git-operations
  tags: git,commits,workflow,github
---

# Git Workflow Skill

Complete guide to the Git workflow and conventions used in this dotfiles project.

## Conventional Commits

All commits must follow the **Conventional Commits** specification:

```
type(scope): description

[optional body]

[optional footer]
```

### Commit Types

- **feat:** A new feature
- **fix:** A bug fix
- **docs:** Documentation changes
- **refactor:** Code refactoring (no feature or bug fix)
- **chore:** Maintenance tasks (deps, build, etc.)
- **test:** Adding or updating tests
- **perf:** Performance improvements
- **ci:** CI/CD configuration changes
- **style:** Code style changes (formatting, etc.)

### Examples

```bash
# Feature
git commit -m "feat(zsh): add new module for tool X"

# Bug fix
git commit -m "fix(tmux): correct pbcopy binding"

# Documentation
git commit -m "docs: update README with new instructions"

# Refactoring
git commit -m "refactor(makefile): consolidate duplicate targets"

# Chore
git commit -m "chore(deps): update pre-commit hooks"
```

## Co-Author Requirement

**EVERY commit must include a co-author.** This is mandatory.

```bash
git commit -m "feat(zsh): add new module" \
  -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
```

### Why Co-Author?

- Acknowledges AI assistance in the development process
- Maintains transparency about how code was created
- Follows ethical AI development practices
- Required by project policy (see AGENTS.md)

### How to Add Co-Author

**Option 1: Command line (recommended)**
```bash
git commit -m "type(scope): description" \
  -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
```

**Option 2: Git config (one-time setup)**
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
# Then add co-author in commit message as shown above
```

**Option 3: Git hooks (automatic)**
Create `.git/hooks/prepare-commit-msg`:
```bash
#!/bin/bash
if ! grep -q "Co-Authored-By:" "$1"; then
  echo "" >> "$1"
  echo "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>" >> "$1"
fi
```

## Branch Strategy

### Main Branches

- **main** — Stable, production-ready code
- **develop** — Active development, integration branch

### Feature Branches

Create feature branches for new work:

```bash
git checkout -b feature/description
# or
git checkout -b fix/description
git checkout -b docs/description
```

### Branch Naming

Follow the pattern: `<type>/<description>`

- `feature/add-new-zsh-module`
- `fix/tmux-pbcopy-binding`
- `docs/update-readme`
- `refactor/simplify-makefile`

## Workflow: Creating a Commit

### Step 1: Make Changes

Edit files in the repository:
```bash
# Edit config files
vim zsh.d/alias.zsh
vim tmux.conf

# Validate changes
make verify
bash scripts/validate-configs.sh
```

### Step 2: Stage Changes

```bash
# Stage specific files
git add zsh.d/alias.zsh tmux.conf

# Or stage all changes
git add .

# Verify what's staged
git status
git diff --staged
```

### Step 3: Commit with Conventional Message

```bash
git commit -m "feat(zsh): add new alias for tool X" \
  -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
```

### Step 4: Push to Remote

```bash
# Push to your feature branch
git push origin feature/description

# Or push to develop (if working directly on develop)
git push origin develop
```

### Step 5: Create Pull Request (if needed)

```bash
# Create PR from feature branch to develop
gh pr create --base develop --head feature/description
```

## Pre-Commit Hooks

Pre-commit hooks run automatically before each commit. They validate:

- ✅ No merge conflicts
- ✅ File endings (LF only)
- ✅ Trailing whitespace
- ✅ YAML/JSON/TOML syntax
- ✅ No large files (>1MB)
- ✅ No hardcoded secrets (gitleaks)
- ✅ Shell script syntax (ShellCheck)
- ✅ Markdown linting
- ✅ Typos
- ✅ Config validation (tmux, zsh)

**If a hook fails:**
1. Read the error message
2. Fix the issue
3. Stage the changes
4. Retry the commit

```bash
# Retry after fixing
git add .
git commit -m "type(scope): description" \
  -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
```

## Common Git Commands

### View History

```bash
# Last 10 commits
git log --oneline -10

# Commits by author
git log --author="Roy Batty"

# Commits for a file
git log -- zsh.d/alias.zsh

# Commits with diff
git log -p -5
```

### View Changes

```bash
# Unstaged changes
git diff

# Staged changes
git diff --staged

# Changes in a commit
git show <commit-hash>

# Changes between branches
git diff develop..feature/description
```

### Undo Changes

```bash
# Discard unstaged changes in a file
git restore zsh.d/alias.zsh

# Unstage a file
git restore --staged zsh.d/alias.zsh

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1  # ⚠️ Destructive!
```

### Branches

```bash
# List branches
git branch -a

# Create branch
git checkout -b feature/description

# Switch branch
git checkout develop

# Delete branch
git branch -d feature/description

# Delete remote branch
git push origin --delete feature/description
```

## Pull Request Workflow

### Creating a PR

```bash
# Push your feature branch
git push origin feature/description

# Create PR (using GitHub CLI)
gh pr create --base develop --head feature/description \
  --title "feat(zsh): add new alias for tool X" \
  --body "Description of changes"
```

### PR Checklist

Before creating a PR, ensure:

- [ ] All changes are committed with co-author
- [ ] Commit messages follow Conventional Commits
- [ ] All pre-commit hooks pass
- [ ] `make verify` passes
- [ ] `bash scripts/validate-configs.sh` passes
- [ ] No merge conflicts with base branch
- [ ] Documentation is updated (if needed)

### PR Merge Strategy

- **Squash merge** — Combine all commits into one
- **Delete branch** — Auto-delete after merge
- **Target branch** — `develop` (or `main` for releases)

```bash
# Merge PR (using GitHub CLI)
gh pr merge <pr-number> --squash --delete-branch
```

## Troubleshooting

### Commit Failed: Pre-commit Hook Error

**Problem:** Hook validation failed (syntax, secrets, etc.)

**Solution:**
1. Read the error message
2. Fix the issue in the file
3. Stage the changes: `git add .`
4. Retry the commit

### Commit Failed: No Co-Author

**Problem:** Commit message missing co-author

**Solution:**
```bash
# Amend the last commit to add co-author
git commit --amend -m "type(scope): description" \
  -m "Co-Authored-By: Roy Batty <roy.batty@cosckoya.bot>"
```

### Push Rejected: Branch Behind Remote

**Problem:** `git push` fails because local branch is behind remote

**Solution:**
```bash
# Pull latest changes
git pull origin develop

# Resolve any conflicts
# Then retry push
git push origin develop
```

### Accidentally Committed to Wrong Branch

**Problem:** Made commit on `main` instead of `develop`

**Solution:**
```bash
# Create new branch from current commit
git branch feature/description

# Reset main to previous commit
git reset --hard HEAD~1

# Switch to feature branch
git checkout feature/description

# Push feature branch
git push origin feature/description
```

## Best Practices

1. **Commit frequently** — Small, focused commits are easier to review
2. **Write clear messages** — Describe what and why, not how
3. **Always include co-author** — Every commit, no exceptions
4. **Validate before pushing** — Run `make verify` and pre-commit hooks
5. **Keep branches short-lived** — Merge within a few days
6. **Use descriptive branch names** — `feature/add-zsh-module`, not `fix-stuff`
7. **Review your own PR first** — Check diff before requesting review
8. **Respond to feedback promptly** — Keep PR momentum going

## References

- **Conventional Commits:** https://www.conventionalcommits.org/
- **GitHub CLI:** https://cli.github.com/
- **Git Documentation:** https://git-scm.com/doc
- **AGENTS.md** — Project policies and requirements

---

**Maintained By:** Shadow Architect  
**Authority:** Git workflow standard for this project  
**Last Updated:** August 27, 2026
