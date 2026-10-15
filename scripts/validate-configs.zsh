#!/usr/bin/env zsh
# Configuration validation script for tmux and zsh
# Validates syntax and configuration integrity
# Used by pre-commit hook

setopt ERR_EXIT NO_UNSET PIPE_FAIL

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

integer ERRORS=0 WARNINGS=0

print_status() {
  local level=$1 message=$2
  case $level in
    error) print -r -- "${RED}✗ ERROR${NC}: $message"; (( ERRORS += 1 )) ;;
    warn)  print -r -- "${YELLOW}⚠ WARN${NC}: $message"; (( WARNINGS += 1 )) ;;
    ok)    print -r -- "${GREEN}✓ OK${NC}: $message" ;;
  esac
}

DOTFILES_DIR="${0:A:h:h}"

print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print "Configuration Validation"
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# TMUX CONFIGURATION VALIDATION
# ============================================================================
print -r -- $'\n'"${YELLOW}[TMUX Configuration]${NC}"

TMUX_CONFIG="$DOTFILES_DIR/tmux.conf"
if [[ ! -f $TMUX_CONFIG ]]; then
  print_status error "tmux.conf not found at $TMUX_CONFIG"
else
  if (( $+commands[tmux] )); then
    if tmux source-file -v "$TMUX_CONFIG" &>/dev/null; then
      print_status ok "tmux configuration syntax is valid"
    else
      print_status error "tmux configuration has syntax errors"
      tmux source-file -v "$TMUX_CONFIG" 2>&1 | head -10
    fi
  else
    print_status warn "tmux not installed, skipping syntax check"
  fi

  if grep -q "copy-pipe-and-cancel.*pbcopy" "$TMUX_CONFIG"; then
    print_status ok "Copy to clipboard binding found"
  else
    print_status error "Missing pbcopy binding in copy-mode-vi"
  fi

  if grep -q "bind -T copy-mode-vi y" "$TMUX_CONFIG"; then
    print_status ok "Vi-style 'y' copy binding found"
  else
    print_status error "Missing Vi-style 'y' copy binding"
  fi

  if grep -q "pbpaste" "$TMUX_CONFIG"; then
    print_status ok "Paste from clipboard binding found"
  else
    print_status error "Missing pbpaste binding"
  fi

  if grep -q "tmux-yank" "$TMUX_CONFIG" && ! grep -q "^# REMOVED.*tmux-yank" "$TMUX_CONFIG"; then
    print_status warn "tmux-yank plugin may conflict with native pbcopy bindings"
  else
    print_status ok "No tmux-yank plugin conflict detected"
  fi

  if grep -q "set -g mouse on" "$TMUX_CONFIG"; then
    print_status ok "Mouse support enabled"
  else
    print_status warn "Mouse support not enabled"
  fi

  if grep -q "bind -T copy-mode-vi MouseDragEnd1Pane" "$TMUX_CONFIG"; then
    print_status ok "Mouse drag-end copy binding found"
  else
    print_status error "Missing mouse drag-end binding"
  fi
fi

# ============================================================================
# ZSH CONFIGURATION VALIDATION
# ============================================================================
print -r -- $'\n'"${YELLOW}[ZSH Configuration]${NC}"

ZSH_CONFIG="$DOTFILES_DIR/zshrc"
if [[ ! -f $ZSH_CONFIG ]]; then
  print_status error "zshrc not found at $ZSH_CONFIG"
else
  if zsh -n "$ZSH_CONFIG" 2>/dev/null; then
    print_status ok "zshrc syntax is valid"
  else
    print_status error "zshrc has syntax errors"
    zsh -n "$ZSH_CONFIG" 2>&1 | head -10
  fi

  if grep -q 'source.*\.d/' "$ZSH_CONFIG" || grep -q 'source.*ZSH_CONFIG_DIR' "$ZSH_CONFIG"; then
    print_status ok "zsh.d modular sources found"
  else
    print_status error "Missing zsh.d module sources"
  fi
fi

# ============================================================================
# ZSH MODULES VALIDATION
# ============================================================================
print -r -- $'\n'"${YELLOW}[ZSH Modules]${NC}"

ZSH_D_DIR="$DOTFILES_DIR/zsh.d"
if [[ ! -d $ZSH_D_DIR ]]; then
  print_status error "zsh.d directory not found"
else
  # Core modules must exist; optional modules (aws, github, oracle) are
  # syntax-checked only when present
  REQUIRED_MODULES=(env options history plugins prompt completion colors kitty alias tools)

  for module in $REQUIRED_MODULES; do
    if [[ ! -f $ZSH_D_DIR/$module.zsh ]]; then
      print_status error "Missing required module: $module.zsh"
    fi
  done

  for module_path in $ZSH_D_DIR/*.zsh(N); do
    if zsh -n "$module_path" 2>/dev/null; then
      print_status ok "${module_path:t} syntax valid"
    else
      print_status error "${module_path:t} has syntax errors"
    fi
  done
fi

# ============================================================================
# CLIPBOARD FUNCTIONALITY TESTS
# ============================================================================
print -r -- $'\n'"${YELLOW}[Clipboard Functionality]${NC}"

if (( $+commands[pbcopy] && $+commands[pbpaste] )); then
  TEST_TEXT="clipboard_test_$(date +%s)"
  if print -r -- "$TEST_TEXT" | pbcopy && pbpaste | grep -q "$TEST_TEXT"; then
    print_status ok "pbcopy/pbpaste working correctly"
  else
    print_status error "pbcopy/pbpaste test failed"
  fi
else
  print_status error "pbcopy/pbpaste commands not found"
fi

if (( $+commands[tmux] )); then
  if tmux new-session -d -s config_test_$$ 2>/dev/null; then
    tmux send-keys -t config_test_$$ "echo 'tmux_clipboard_test'" Enter
    sleep 0.5
    if tmux save-buffer - 2>/dev/null | grep -q tmux_clipboard; then
      print_status ok "tmux buffer operations working"
    else
      print_status warn "tmux buffer test inconclusive"
    fi
    tmux kill-session -t config_test_$$ 2>/dev/null || true
  fi
fi

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
print -r -- $'\n'"${YELLOW}[Environment Variables]${NC}"

ZSH_ENV="$ZSH_D_DIR/env.zsh"
if grep -q "export HOMEBREW_PREFIX" "$ZSH_ENV"; then
  print_status ok "Homebrew path caching configured"
else
  print_status error "Missing HOMEBREW_PREFIX export"
fi

if grep -q "export EDITOR=" "$ZSH_ENV" || grep -q "export EDITOR=" "$ZSH_D_DIR"/*.zsh; then
  print_status ok "EDITOR environment variable configured"
else
  print_status error "EDITOR environment variable not configured"
fi

# ============================================================================
# SUMMARY
# ============================================================================
print ""
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print "Validation Summary"
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print -r -- "Errors:   ${RED}$ERRORS${NC}"
print -r -- "Warnings: ${YELLOW}$WARNINGS${NC}"

if (( ERRORS == 0 )); then
  print -r -- "${GREEN}✓ All validations passed!${NC}"
  (( WARNINGS > 0 )) && print -r -- "${YELLOW}⚠ ($WARNINGS warning(s) - not blocking)${NC}"
  exit 0
else
  print -r -- "${RED}✗ Validation failed with $ERRORS error(s)${NC}"
  exit 1
fi
