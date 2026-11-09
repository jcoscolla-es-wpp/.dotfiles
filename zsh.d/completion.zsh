# Completion owns compinit; highlighting must not initialize it.
typeset -g _ZSH_COMPLETIONS_READY=false

_completion_init() {
  [[ $_ZSH_COMPLETIONS_READY == true ]] && return 0
  autoload -Uz compinit
  compinit -i || return
  (( $+functions[zicdreplay] )) && zicdreplay
  (( $+functions[zinit] )) && compdef _zinit zinit
  _ZSH_COMPLETIONS_READY=true
  (( $+functions[_tools_completion_init] )) && _tools_completion_init
  return 0
}

# Completion styling
zstyle ':completion:*' menu select                          # Select completions with arrow keys
zstyle ':completion:*' group-name ''                        # Group results by category
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colorize completions
zstyle ':completion:*' special-dirs true                    # Complete . and .. special directories

# Completion descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Completion order
zstyle ':completion:::::' completer _expand _complete _ignored _approximate

# Makefile completion
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:make:*' tag-order targets

# Process completion
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,comm'

# Native completion still works when Zinit or its completion plugin is missing.
[[ $_ZSH_COMPLETIONS_DEFERRED == true ]] || _completion_init
