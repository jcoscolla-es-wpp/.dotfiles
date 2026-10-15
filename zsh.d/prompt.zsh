# Custom ZSH Prompt - Simple and informative
# Colors matched to Powerlevel10k configuration
# No external dependencies (no Pure, no Powerlevel10k)
#
# Segments are computed once per prompt in a precmd hook and stored in
# variables. Computing them inside $(...) would run in a subshell, losing
# every cache and forking a process per prompt.

setopt PROMPT_SUBST

# ============================================================================
# PROMPT CONFIGURATION - Edit these variables to customize your prompt
# ============================================================================

# Color scheme (use ZSH color codes: 0-255 or named colors like 'red', 'blue')
# Reference: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
typeset -g PROMPT_COLOR_DIR=31              # Directory path (cyan)
typeset -g PROMPT_COLOR_GIT_BRANCH=76       # Git branch (bright green)
typeset -g PROMPT_COLOR_GIT_CLEAN=31        # Git brackets when clean (cyan)
typeset -g PROMPT_COLOR_GIT_STAGED=76       # Staged changes indicator (bright green)
typeset -g PROMPT_COLOR_GIT_UNSTAGED=178    # Unstaged changes indicator (yellow/orange)
typeset -g PROMPT_COLOR_GIT_UNTRACKED=160   # Untracked files indicator (red)
typeset -g PROMPT_COLOR_GIT_ACTION=160      # Git action (rebase, merge, etc.) (red)
typeset -g PROMPT_COLOR_SUCCESS=70          # Success indicator (green)
typeset -g PROMPT_COLOR_ERROR=160           # Error indicator (red)
typeset -g PROMPT_COLOR_ARROW=white         # Prompt arrow (white)
typeset -g PROMPT_COLOR_VIRTUALENV=37       # Python virtualenv (cyan light)
typeset -g PROMPT_COLOR_KUBECTL=134         # Kubectl context (magenta/pink)

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

# ============================================================================
# END OF CONFIGURATION
# ============================================================================

typeset -g _PROMPT_GIT="" _PROMPT_VENV="" _PROMPT_KUBE=""
typeset -g _PROMPT_KUBE_CONTEXT="" _PROMPT_KUBE_MTIME=0

# Exit status segment: the %(?...) test is rendered per prompt, the string is built once
typeset -g _PROMPT_STATUS="%(?.%F{$PROMPT_COLOR_SUCCESS}${PROMPT_SYMBOL_SUCCESS}%f.%F{$PROMPT_COLOR_ERROR}${PROMPT_SYMBOL_ERROR}%f)"

# gitstatus daemon: started once per shell, queried on every prompt (~ms)
if [[ $PROMPT_SHOW_GIT == true ]] && (( $+functions[gitstatus_start] )); then
  gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY' 2>/dev/null
fi

# kubeconfig mtime without forking stat
(( $+commands[kubectl] )) && zmodload -F zsh/stat b:zstat 2>/dev/null

_prompt_git_update() {
  _PROMPT_GIT=""
  [[ $PROMPT_SHOW_GIT == true ]] || return 0

  if (( $+functions[gitstatus_query] )); then
    gitstatus_query -t 1 'MY' 2>/dev/null || return 0
    [[ $VCS_STATUS_RESULT == ok-sync ]] || return 0

    local branch="${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT}}" indicators=""
    [[ -n $VCS_STATUS_ACTION ]] && indicators+="%F{$PROMPT_COLOR_GIT_ACTION}|$VCS_STATUS_ACTION%f"
    ((VCS_STATUS_HAS_STAGED))    && indicators+="%F{$PROMPT_COLOR_GIT_STAGED}${PROMPT_SYMBOL_GIT_STAGED}%f"
    ((VCS_STATUS_HAS_UNSTAGED))  && indicators+="%F{$PROMPT_COLOR_GIT_UNSTAGED}${PROMPT_SYMBOL_GIT_UNSTAGED}%f"
    ((VCS_STATUS_HAS_UNTRACKED)) && indicators+="%F{$PROMPT_COLOR_GIT_UNTRACKED}${PROMPT_SYMBOL_GIT_UNTRACKED}%f"
    _PROMPT_GIT=" %F{$PROMPT_COLOR_GIT_CLEAN}(%f%F{$PROMPT_COLOR_GIT_BRANCH}${branch}%f${indicators}%F{$PROMPT_COLOR_GIT_CLEAN})%f"
    return 0
  fi

  # Fallback when gitstatus is unavailable: built-in vcs_info (slower)
  autoload -Uz vcs_info
  zstyle ':vcs_info:git*' formats ' (%b)'
  zstyle ':vcs_info:git*' actionformats ' (%b|%a)'
  vcs_info
  [[ -n $vcs_info_msg_0_ ]] && _PROMPT_GIT="%F{$PROMPT_COLOR_GIT_BRANCH}${vcs_info_msg_0_}%f"
  return 0
}

_prompt_venv_update() {
  _PROMPT_VENV=""
  [[ $PROMPT_SHOW_VIRTUALENV == true ]] || return 0

  if [[ -n $VIRTUAL_ENV ]]; then
    _PROMPT_VENV="%F{$PROMPT_COLOR_VIRTUALENV}(${VIRTUAL_ENV:t})%f "
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    _PROMPT_VENV="%F{$PROMPT_COLOR_VIRTUALENV}(${CONDA_DEFAULT_ENV})%f "
  fi
}

# kubectl is expensive (~130ms): re-query only when the kubeconfig changes
_prompt_kube_update() {
  _PROMPT_KUBE=""
  [[ $PROMPT_SHOW_KUBECTL == true ]] && (( $+commands[kubectl] )) || return 0

  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  [[ -f $kubeconfig ]] || return 0

  local -a mtime
  zstat -A mtime +mtime -- "$kubeconfig" 2>/dev/null || return 0
  if [[ $mtime[1] != $_PROMPT_KUBE_MTIME ]]; then
    _PROMPT_KUBE_CONTEXT="$(kubectl config current-context 2>/dev/null)"
    _PROMPT_KUBE_MTIME=$mtime[1]
  fi

  [[ -n $_PROMPT_KUBE_CONTEXT ]] &&
    _PROMPT_KUBE="%F{$PROMPT_COLOR_KUBECTL}${PROMPT_SYMBOL_KUBECTL} ${_PROMPT_KUBE_CONTEXT}%f "
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
