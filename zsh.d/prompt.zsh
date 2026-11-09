# Prompt segments are computed in the parent shell to preserve caches.

setopt PROMPT_SUBST

# ============================================================================
# PROMPT CONFIGURATION - Edit these variables to customize your prompt
# ============================================================================

# Color scheme: ANSI indexes 0-15, mapped by the terminal to Emerald Arcana
# (kitty.conf, scripts/palette.zsh). Avoid 16-255: those ignore the palette.
typeset -g PROMPT_COLOR_DIR=6               # Directory path (aqua)
typeset -g PROMPT_COLOR_GIT_BRANCH=2        # Git branch (emerald)
typeset -g PROMPT_COLOR_GIT_CLEAN=4         # Git brackets (indigo)
typeset -g PROMPT_COLOR_GIT_STAGED=2        # Staged changes indicator (emerald)
typeset -g PROMPT_COLOR_GIT_UNSTAGED=3      # Unstaged changes indicator (amber)
typeset -g PROMPT_COLOR_GIT_UNTRACKED=1     # Untracked files indicator (rose)
typeset -g PROMPT_COLOR_GIT_ACTION=1        # Git action (rebase, merge, etc.) (rose)
typeset -g PROMPT_COLOR_SUCCESS=2           # Success indicator (emerald)
typeset -g PROMPT_COLOR_ERROR=1             # Error indicator (rose)
typeset -g PROMPT_COLOR_ARROW=white         # Prompt arrow (attenuated text)
typeset -g PROMPT_COLOR_VIRTUALENV=4        # Python virtualenv (indigo)
typeset -g PROMPT_COLOR_KUBECTL=5           # Kubectl context (orchid)

# Symbols and characters
typeset -g PROMPT_SYMBOL_ARROW="❯"          # Main prompt arrow
typeset -g PROMPT_SYMBOL_SUCCESS="✓"        # Command succeeded
typeset -g PROMPT_SYMBOL_ERROR="✗"          # Command failed
typeset -g PROMPT_SYMBOL_GIT_STAGED="●"     # Staged changes
typeset -g PROMPT_SYMBOL_GIT_UNSTAGED="●"   # Unstaged changes
typeset -g PROMPT_SYMBOL_GIT_UNTRACKED="…"  # Untracked files
typeset -g PROMPT_SYMBOL_KUBECTL="☸"        # Kubernetes icon

# Prompt format options
typeset -g PROMPT_SHOW_GIT=true             # Show git status (true/false)
typeset -g PROMPT_SHOW_VIRTUALENV=true      # Show Python virtualenv (true/false)
typeset -g PROMPT_SHOW_KUBECTL=true         # Show kubectl context (true/false)
typeset -g PROMPT_GIT_TIMEOUT=0.05          # Maximum query wait in seconds

# ============================================================================
# END OF CONFIGURATION
# ============================================================================

typeset -g _PROMPT_GIT="" _PROMPT_VENV="" _PROMPT_KUBE=""
typeset -g _PROMPT_KUBE_CONTEXT="" _PROMPT_KUBE_SIGNATURE=""
typeset -g _PROMPT_GIT_READY=false
typeset -g GITSTATUS_AUTO_INSTALL=0

# Exit status segment: the %(?...) test is rendered per prompt, the string is built once
typeset -g _PROMPT_STATUS="%(?.%F{$PROMPT_COLOR_SUCCESS}${PROMPT_SYMBOL_SUCCESS}%f.%F{$PROMPT_COLOR_ERROR}${PROMPT_SYMBOL_ERROR}%f)"

# Start the daemon while tool integrations load; only presence indicators are needed.
if [[ $PROMPT_SHOW_GIT == true ]] && (( $+functions[gitstatus_start] )); then
  if gitstatus_start -a -t 1 -s 1 -u 1 -c 1 -d 1 'MY' 2>/dev/null; then
    _PROMPT_GIT_READY=true
  fi
fi

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats ' (%b)'
zstyle ':vcs_info:git*' actionformats ' (%b|%a)'
zmodload -F zsh/stat b:zstat

_prompt_git_update() {
  _PROMPT_GIT=""
  [[ $PROMPT_SHOW_GIT == true ]] || return 0

  if [[ $_PROMPT_GIT_READY == true ]]; then
    # Complete background initialization with the same bounded wait as queries.
    if gitstatus_start -t "$PROMPT_GIT_TIMEOUT" 'MY' 2>/dev/null &&
      gitstatus_query -t "$PROMPT_GIT_TIMEOUT" 'MY' 2>/dev/null; then
      [[ $VCS_STATUS_RESULT == ok-sync ]] || return 0

      local branch="${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT[1,8]}}" indicators=""
      branch="${branch//\%/%%}"
      [[ -n $VCS_STATUS_ACTION ]] && indicators+="%F{$PROMPT_COLOR_GIT_ACTION}|$VCS_STATUS_ACTION%f"
      ((VCS_STATUS_HAS_STAGED > 0))    && indicators+="%F{$PROMPT_COLOR_GIT_STAGED}${PROMPT_SYMBOL_GIT_STAGED}%f"
      ((VCS_STATUS_HAS_UNSTAGED > 0))  && indicators+="%F{$PROMPT_COLOR_GIT_UNSTAGED}${PROMPT_SYMBOL_GIT_UNSTAGED}%f"
      ((VCS_STATUS_HAS_UNTRACKED > 0)) && indicators+="%F{$PROMPT_COLOR_GIT_UNTRACKED}${PROMPT_SYMBOL_GIT_UNTRACKED}%f"
      _PROMPT_GIT=" %F{$PROMPT_COLOR_GIT_CLEAN}(%f%F{$PROMPT_COLOR_GIT_BRANCH}${branch}%f${indicators}%F{$PROMPT_COLOR_GIT_CLEAN})%f"
      return 0
    fi

    # A slow query should not trigger a second synchronous Git scan.
    if (( $+functions[gitstatus_check] )) && gitstatus_check 'MY' 2>/dev/null; then
      return 0
    fi
    _PROMPT_GIT_READY=false
  fi

  # This also covers a failed daemon startup or a daemon that stops responding.
  vcs_info
  [[ -n $vcs_info_msg_0_ ]] && _PROMPT_GIT="%F{$PROMPT_COLOR_GIT_BRANCH}${vcs_info_msg_0_//\%/%%}%f"
  return 0
}

_prompt_venv_update() {
  _PROMPT_VENV=""
  [[ $PROMPT_SHOW_VIRTUALENV == true ]] || return 0

  if [[ -n $VIRTUAL_ENV ]]; then
    _PROMPT_VENV="%F{$PROMPT_COLOR_VIRTUALENV}(${${VIRTUAL_ENV:t}//\%/%%})%f "
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    _PROMPT_VENV="%F{$PROMPT_COLOR_VIRTUALENV}(${CONDA_DEFAULT_ENV//\%/%%})%f "
  fi
}

# Cache by file identity as well as mtime; KUBECONFIG can contain multiple paths.
_prompt_kube_update() {
  _PROMPT_KUBE=""
  [[ $PROMPT_SHOW_KUBECTL == true ]] && (( $+commands[kubectl] )) || return 0

  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}" config_file signature
  local -A file_info
  local -i config_count=0
  signature="$kubeconfig"
  for config_file in "${(@s.:.)kubeconfig}"; do
    [[ -f "$config_file" ]] || continue
    zstat -H file_info -- "$config_file" 2>/dev/null || continue
    signature+=":$file_info[inode]:$file_info[mtime]:$file_info[size]"
    (( config_count += 1 ))
  done
  if (( config_count == 0 )); then
    _PROMPT_KUBE_CONTEXT=""
    _PROMPT_KUBE_SIGNATURE=""
    return 0
  fi

  if [[ $signature != $_PROMPT_KUBE_SIGNATURE ]]; then
    _PROMPT_KUBE_CONTEXT="$(kubectl config current-context 2>/dev/null)"
    _PROMPT_KUBE_SIGNATURE="$signature"
  fi

  [[ -n $_PROMPT_KUBE_CONTEXT ]] &&
    _PROMPT_KUBE="%F{$PROMPT_COLOR_KUBECTL}${PROMPT_SYMBOL_KUBECTL} ${_PROMPT_KUBE_CONTEXT//\%/%%}%f "
  return 0
}

_prompt_update() {
  _prompt_git_update
  _prompt_venv_update
  _prompt_kube_update
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_update

PROMPT='%F{$PROMPT_COLOR_DIR}%~%f${_PROMPT_GIT} ${_PROMPT_STATUS} %F{$PROMPT_COLOR_ARROW}${PROMPT_SYMBOL_ARROW}%f '
RPROMPT='${_PROMPT_VENV}${_PROMPT_KUBE}'
