# Color Configuration (optimized for Kitty)

# Configure colors for the 'less' pager
export LESS_TERMCAP_mb=$'\E[1;31m'     # Begin bold - red
export LESS_TERMCAP_md=$'\E[1;36m'     # Begin blink - cyan
export LESS_TERMCAP_me=$'\E[0m'        # End mode
export LESS_TERMCAP_so=$'\E[01;44;33m' # Begin standout - yellow on blue
export LESS_TERMCAP_se=$'\E[0m'        # End standout
export LESS_TERMCAP_us=$'\E[1;32m'     # Begin underline - green
export LESS_TERMCAP_ue=$'\E[0m'        # End underline

# Less options
export LESS='-R -M -i -j10'
export LESSCHARSET='utf-8'

# macOS-specific color configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Enable colors for macOS ls
  export CLICOLOR=1

  # ============================================================================
  # LSCOLORS Configuration
  # ============================================================================
  # Format: 11 pairs of (foreground + background) for:
  # 1. directory  2. symlink  3. socket  4. pipe  5. executable
  # 6. block special  7. char special  8. setuid exec  9. setgid exec
  # 10. dir writable+sticky  11. dir writable no-sticky
  #
  # Color codes (lowercase=normal, uppercase=bold):
  # a/A=black, b/B=red, c/C=green, d/D=brown, e/E=blue, f/F=magenta
  # g/G=cyan, h/H=light grey, x=default foreground/background
  # ============================================================================

  # TokyoNight theme (matches Kitty); other themes live in git history
  export LSCOLORS=GxFxCxDxBxegedabagacad

  # GNU coreutils colors for completion (brew install coreutils); ls itself
  # stays on native /bin/ls in alias.zsh to avoid iCloud timeouts
  if command -v gdircolors >/dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]; then
      eval "$(gdircolors -b ~/.dircolors)"
    else
      eval "$(gdircolors -b)"
    fi
    # shellcheck disable=SC2296
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  fi

  # Colored grep output (matches selected theme)
  export GREP_COLOR='1;32'  # Bold green
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
