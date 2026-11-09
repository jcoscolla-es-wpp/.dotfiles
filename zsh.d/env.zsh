# Environment Variables and Paths
# Loaded early in shell initialization

# Keep PATH free of duplicates when integrations prepend their directories.
typeset -U path PATH

# Zsh already provides the platform and architecture; no subprocess is needed.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  case "$OSTYPE:$CPUTYPE" in
    darwin*:arm64|darwin*:aarch64) HOMEBREW_PREFIX=/opt/homebrew ;;
    *) HOMEBREW_PREFIX=/usr/local ;;
  esac
fi
export HOMEBREW_PREFIX

if [[ -d "$HOMEBREW_PREFIX" ]]; then
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH:-}"
  export INFOPATH="$HOMEBREW_PREFIX/share/info${INFOPATH:+:$INFOPATH}"
fi

for _dir in "$HOMEBREW_PREFIX/sbin" "$HOMEBREW_PREFIX/bin" \
  "$HOME/.local/bin" "$HOME/bin" "$HOME/.opencode/bin"; do
  [[ -d "$_dir" ]] && path=("$_dir" $path)
done
unset _dir

# Locale configuration (UTF-8 support); LC_ALL is left unset so LC_* overrides work
export LANG=en_US.UTF-8

# TERM is left to the terminal (xterm-kitty) and tmux (tmux-256color)
export COLORTERM="truecolor"

if (( $+commands[nvim] )); then
  export EDITOR=nvim
else
  export EDITOR="${EDITOR:-vi}"
fi
export VISUAL="$EDITOR"
