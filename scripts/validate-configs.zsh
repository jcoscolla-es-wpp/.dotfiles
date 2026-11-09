#!/usr/bin/env zsh
# Configuration validation script for tmux and zsh
# Safe for pre-commit: parse configuration without changing live sessions or clipboard.

setopt ERR_EXIT NO_UNSET PIPE_FAIL

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

integer ERRORS=0 WARNINGS=0

print_status() {
  local level=$1 message=$2
  case $level in
    error) print -r -- "${RED}ERROR${NC}: $message"; (( ERRORS += 1 )) ;;
    warn)  print -r -- "${YELLOW}WARN${NC}: $message"; (( WARNINGS += 1 )) ;;
    ok)    print -r -- "${GREEN}OK${NC}: $message" ;;
  esac
}

DOTFILES_DIR="${0:A:h:h}"

validate_tmux_syntax() {
  local temp_dir output
  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tmux.XXXXXX")
  {
    # No user config, login shell, plugins, or default tmux socket is involved.
    if ! output=$(tmux -S "$temp_dir/socket" -f /dev/null \
      new-session -d -s syntax /bin/sleep 30 2>&1); then
      print -ru2 -- "$output"
      return 1
    fi
    if ! output=$(tmux -S "$temp_dir/socket" source-file -n -v "$TMUX_CONFIG" 2>&1); then
      print -ru2 -- "$output"
      return 1
    fi
  } always {
    tmux -S "$temp_dir/socket" kill-server >/dev/null 2>&1 || true
    [[ ! -e "$temp_dir/socket" ]] || rm -f -- "$temp_dir/socket"
    rmdir -- "$temp_dir"
  }
}

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
    if validate_tmux_syntax; then
      print_status ok "tmux configuration syntax is valid"
    else
      print_status error "tmux configuration has syntax errors"
    fi
  else
    print_status warn "tmux not installed, skipping syntax check"
  fi

  if grep -q '^bind .*copy-pipe-and-cancel.*pbcopy' "$TMUX_CONFIG"; then
    print_status ok "Copy to clipboard binding found"
  else
    print_status error "Missing pbcopy binding in copy-mode-vi"
  fi

  if grep -q '^bind -T copy-mode-vi y ' "$TMUX_CONFIG"; then
    print_status ok "Vi-style 'y' copy binding found"
  else
    print_status error "Missing Vi-style 'y' copy binding"
  fi

  if grep -q '^bind .*pbpaste' "$TMUX_CONFIG"; then
    print_status ok "Paste from clipboard binding found"
  else
    print_status error "Missing pbpaste binding"
  fi

  if grep -q '^set .*@plugin.*tmux-yank' "$TMUX_CONFIG"; then
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
  if zsh -dfn "$ZSH_CONFIG" 2>/dev/null; then
    print_status ok "zshrc syntax is valid"
  else
    print_status error "zshrc has syntax errors"
    zsh -dfn "$ZSH_CONFIG" 2>&1 || true
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
  # Core modules must exist; optional modules (aws, oracle) are
  # syntax-checked only when present
  REQUIRED_MODULES=(env options history plugins prompt completion colors kitty alias tools)

  for module in $REQUIRED_MODULES; do
    if [[ ! -f $ZSH_D_DIR/$module.zsh ]]; then
      print_status error "Missing required module: $module.zsh"
    fi
  done

  for module_path in $ZSH_D_DIR/*.zsh(N); do
    if zsh -dfn "$module_path" 2>/dev/null; then
      print_status ok "${module_path:t} syntax valid"
    else
      print_status error "${module_path:t} has syntax errors"
    fi
  done
fi

# ============================================================================
# CLIPBOARD COMMAND AVAILABILITY (NO CLIPBOARD READS OR WRITES)
# ============================================================================
print -r -- $'\n'"${YELLOW}[Clipboard Commands]${NC}"

if (( $+commands[pbcopy] && $+commands[pbpaste] )); then
  print_status ok "pbcopy/pbpaste available; clipboard contents untouched"
elif [[ $OSTYPE != darwin* ]]; then
  print_status warn "macOS clipboard commands unavailable on this platform"
else
  print_status error "pbcopy/pbpaste commands not found"
fi

print -r -- $'\n'"${YELLOW}[Script Syntax]${NC}"
for script_file in "$DOTFILES_DIR"/scripts/*.zsh(N); do
  if zsh -dfn "$script_file"; then
    print_status ok "${script_file:t} syntax valid"
  else
    print_status error "${script_file:t} has syntax errors"
  fi
done

# ============================================================================
# COLOR PALETTE (Emerald Arcana)
# ============================================================================
print -r -- $'\n'"${YELLOW}[Color Palette]${NC}"

PALETTE_FILE="$DOTFILES_DIR/scripts/palette.zsh"
if [[ ! -f $PALETTE_FILE ]]; then
  print_status error "palette.zsh not found at $PALETTE_FILE"
else
  source "$PALETTE_FILE"
  typeset -a allowed_hex
  allowed_hex=(${(L)PALETTE} ${(L)PALETTE_DERIVED})
  for color_file in kitty.conf tmux.conf zsh.d/tools.zsh zsh.d/plugins.zsh nvim/lua/plugins/editor.lua; do
    [[ -f $DOTFILES_DIR/$color_file ]] || { print_status error "$color_file not found"; continue }
    typeset -a found_hex unknown_hex
    found_hex=(${(L)${(f)"$(grep -o -E '#[0-9a-fA-F]{6}\b' "$DOTFILES_DIR/$color_file" || true)"}})
    unknown_hex=(${(u)found_hex:|allowed_hex})
    if (( ${#unknown_hex} == 0 )); then
      print_status ok "$color_file uses only palette colors"
    else
      print_status error "$color_file uses colors outside the palette: ${(j:, :)unknown_hex}"
    fi
  done
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

if grep -q "export EDITOR=" "$ZSH_ENV"; then
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
  print -r -- "${GREEN}All syntax and static checks passed.${NC}"
  (( WARNINGS > 0 )) && print -r -- "${YELLOW}($WARNINGS warning(s) - not blocking)${NC}"
  exit 0
else
  print -r -- "${RED}Validation failed with $ERRORS error(s)${NC}"
  exit 1
fi
