# Environment Variables and Paths
# Loaded early in shell initialization

# Keep PATH free of duplicates, including after `source ~/.zshrc`
typeset -U path PATH

# macOS specific environment
export OSTYPE="${OSTYPE:-darwin}"

# Homebrew paths (macOS specific)
# Cache brew prefix to avoid repeated slow calls
# Manual setup is ~100ms faster than 'brew shellenv'
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    export HOMEBREW_PREFIX="/usr/local"
  fi
else
  # Fallback for non-macOS systems
  export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"
fi

# Export Homebrew environment manually (faster than eval)
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}"
export INFOPATH="$HOMEBREW_PREFIX/share/info${INFOPATH+:$INFOPATH}"

# Add directories to PATH (ordered by priority)
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# Locale configuration (UTF-8 support); LC_ALL is left unset so LC_* overrides work
export LANG=en_US.UTF-8

# TERM is left to the terminal (xterm-kitty) and tmux (tmux-256color)
export COLORTERM="truecolor"

# Editor preferences
export EDITOR="nvim"
export VISUAL="nvim"
