# Autocompletion Configuration
# Note: compinit is handled by zinit turbo mode in plugins.zsh (zicompinit)

# Bash compatibility (deferred via precmd hook for ~20ms speedup)
_load_bashcompinit() {
    autoload -Uz bashcompinit && bashcompinit
    # Remove this hook after first run
    # shellcheck disable=SC2206
    precmd_functions=(${precmd_functions:#_load_bashcompinit})
}
precmd_functions+=(_load_bashcompinit)

# Zinit completions
autoload -Uz _zinit
# shellcheck disable=SC2154
(( ${+_comps} )) && _comps[zinit]=_zinit

# Completion styling
zstyle ':completion:*' menu select                          # Select completions with arrow keys
zstyle ':completion:*' group-name ''                        # Group results by category
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive completion
# shellcheck disable=SC2296
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colorize completions
zstyle ':completion:*' special-dirs true                    # Complete . and .. special directories
zstyle ':completion:*' rehash true                          # Automatically find new executables in path

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
