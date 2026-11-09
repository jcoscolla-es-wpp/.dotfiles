# ZSH Tools Configuration
# Optimized for macOS with Homebrew

# mise - dev tools version manager (https://mise.jdx.dev)
# Reads ~/.tool-versions and mise.toml. Replaces ASDF.
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# fzf - Fuzzy finder configuration
# Documentation: https://github.com/junegunn/fzf
if command -v fzf &>/dev/null; then
  # fzf appearance and behavior
  export FZF_DEFAULT_OPTS='
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --color=fg:#dcd7f0,bg:#13101f,hl:#a98bf5
    --color=fg+:#dcd7f0,bg+:#1d1830,hl+:#2fd49b
    --color=info:#8a82ab,prompt:#2fd49b,pointer:#a98bf5
    --color=marker:#2fd49b,spinner:#d38cf5,header:#a98bf5,border:#3a3160
  '

  # Use fd instead of find if available
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# bat - Better cat (if installed)
# Documentation: https://github.com/sharkdp/bat
if command -v bat &>/dev/null; then
  # "ansi" uses the terminal palette, so bat follows Emerald Arcana
  export BAT_THEME="ansi"
  export BAT_STYLE="numbers,changes,header"
fi

# These integrations need compinit and must precede the editing plugins.
_tools_completion_init() {
  if (( $+commands[fzf] )); then
    source <(fzf --zsh)
  fi
  if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
  fi
}
[[ $_ZSH_COMPLETIONS_READY == true ]] && _tools_completion_init

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi
