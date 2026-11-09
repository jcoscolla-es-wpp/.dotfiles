# Prompt dependencies load now; completion and editing plugins load after the prompt.
typeset -ga ZSH_PLUGINS=(
  romkatv/gitstatus
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  zdharma-continuum/fast-syntax-highlighting
)
typeset -g _ZSH_COMPLETIONS_DEFERRED=false
typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(history)
typeset -g ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # ANSI bright black = comment, 5.23 contrast

(( $+functions[zinit] )) || return 0

for _plugin in $ZSH_PLUGINS; do
  if [[ ${DOTFILES_INSTALL_PLUGINS:-0} == 1 && ! -o interactive ]]; then
    zinit light "$_plugin"
    continue
  fi

  # A missing plugin must not turn terminal startup into a network operation.
  if [[ ! -d "${ZINIT[PLUGINS_DIR]}/${_plugin//\//---}" ]]; then
    print -ru2 -- "Missing plugin $_plugin. Run make zsh-plugins to install it."
    continue
  fi

  case $_plugin in
    romkatv/gitstatus)
      zinit ice depth=1
      ;;
    zsh-users/zsh-completions)
      _ZSH_COMPLETIONS_DEFERRED=true
      zinit ice wait'0a' lucid blockf atpull'zinit creinstall -q .' atload'_completion_init'
      ;;
    zsh-users/zsh-autosuggestions)
      zinit ice wait'0b' lucid atload'_zsh_autosuggest_start'
      ;;
    zdharma-continuum/fast-syntax-highlighting)
      zinit ice wait'0c' lucid
      ;;
    *)
      zinit ice wait'0b' lucid
      ;;
  esac
  zinit light "$_plugin"
done
unset _plugin
