# ~/.zshrc - Zsh configuration file for interactive shells

# TMUX: Auto-start before prompt initialization
# Only auto-start in interactive login shells with a TTY
if [[ -z "$TMUX" ]] && [[ -o login ]] && [[ -t 0 ]]; then
  if command -v tmux &>/dev/null; then
    # Try to attach to existing session, create new one if it doesn't exist
    exec tmux new-session -A -s main
  fi
fi

# Zinit: Plugin manager initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load modular configuration files
ZSH_CONFIG_DIR="${HOME}/.zsh.d"

source "${ZSH_CONFIG_DIR}/env.zsh"        # Environment variables and paths
source "${ZSH_CONFIG_DIR}/options.zsh"    # Zsh options (navigation, etc.)
source "${ZSH_CONFIG_DIR}/history.zsh"    # History configuration
source "${ZSH_CONFIG_DIR}/plugins.zsh"    # Zinit plugins and themes
source "${ZSH_CONFIG_DIR}/prompt.zsh"     # Custom prompt configuration
source "${ZSH_CONFIG_DIR}/completion.zsh" # Autocompletion settings
source "${ZSH_CONFIG_DIR}/colors.zsh"     # Color configuration
source "${ZSH_CONFIG_DIR}/kitty.zsh"      # Kitty terminal integration
source "${ZSH_CONFIG_DIR}/alias.zsh"      # Custom aliases
source "${ZSH_CONFIG_DIR}/tools.zsh"      # Tool integrations

# Optional modules: aws and github are generic, oracle is local-only (untracked)
for _module in oracle aws github; do
  [[ -r "${ZSH_CONFIG_DIR}/${_module}.zsh" ]] && source "${ZSH_CONFIG_DIR}/${_module}.zsh"
done
unset _module

# direnv hook: precmd also runs after every cd, so no chpwd hook is needed
if command -v direnv &>/dev/null; then
  _direnv_hook() { eval "$(direnv export zsh)"; }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _direnv_hook
fi
