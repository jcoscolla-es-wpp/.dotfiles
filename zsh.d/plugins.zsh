# Zinit Plugins - Optimized with Turbo Mode

# Turbo-loaded plugins (deferred for faster startup)
# wait'0' = load immediately after prompt, but asynchronously

# gitstatus: Ultra-fast git prompt (10x faster than vcs_info)
# Must load synchronously for prompt to work
zinit ice depth=1
zinit light romkatv/gitstatus

# Completions (load early, needed by other plugins)
zinit ice wait'0' lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# Autosuggestions
zinit ice wait'0' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Syntax highlighting (load last among completions)
zinit ice wait'0' lucid atinit'zicompinit; zicdreplay'
zinit light zdharma-continuum/fast-syntax-highlighting

# History search
zinit ice wait'0' lucid
zinit light zdharma-continuum/history-search-multi-word

# fzf: Fuzzy finder (lazy-loaded for faster startup)
# Load keybindings and completion scripts asynchronously
if [[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
  zinit ice wait'1' lucid \
    multisrc"$HOMEBREW_PREFIX/opt/fzf/shell/{key-bindings,completion}.zsh"
  zinit light zdharma-continuum/null
fi
