#!/usr/bin/env zsh
# Regression tests use disposable homes, never the user's configs or clipboard.
setopt ERR_EXIT NO_UNSET PIPE_FAIL

DOTFILES="${0:A:h:h}"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tests.XXXXXX")
integer checks=0
typeset -g _TEST_PTY_OUTPUT=""

pass() {
  (( checks += 1 ))
  print -r -- "OK: $1"
}

wait_for_output() {
  local expected=$1 received transcript=""
  float deadline=$(( EPOCHREALTIME + 10 ))
  while (( EPOCHREALTIME < deadline )); do
    if zpty -r interactive received; then
      transcript+="$received"
      if [[ $transcript == *$expected* ]]; then
        _TEST_PTY_OUTPUT="$transcript"
        return 0
      fi
      [[ $transcript == *PLUGIN_TEST_FAIL* ]] && break
    else
      sleep 0.01
    fi
  done
  print -ru2 -- "FAIL: interactive shell did not produce $expected"
  print -ru2 -- "$transcript"
  return 1
}

{
  mkdir -p "$temp_dir/home/.zsh.d" "$temp_dir/source" "$temp_dir/destination"
  for module in env options history plugins prompt completion colors kitty alias tools aws; do
    ln -s "$DOTFILES/zsh.d/$module.zsh" "$temp_dir/home/.zsh.d/$module.zsh"
  done
  ln -s "$DOTFILES/zshrc" "$temp_dir/home/.zshrc"

  env -i HOME="$temp_dir/home" PATH=/usr/bin:/bin TERM=xterm-256color \
    HOMEBREW_PREFIX="$temp_dir/missing-brew" ZINIT_HOME="$temp_dir/missing-zinit" \
    /bin/zsh -di -c '
      [[ $_ZSH_COMPLETIONS_READY == true ]] || exit 1
      (( $+functions[compdef] )) || exit 1
      for tool in cat find grep ps du df; do
        (( $+aliases[$tool] == 0 )) || exit 1
      done
      [[ ${aliases[zshreload]} == "exec zsh" ]] || exit 1
      [[ ${options[sharehistory]} == on && ${options[incappendhistory]} == off ]] || exit 1
      [[ $HISTSIZE -gt $SAVEHIST ]] || exit 1
      if (( $+commands[nvim] )); then
        [[ $EDITOR == nvim ]] || exit 1
      else
        [[ $EDITOR == vi ]] || exit 1
      fi
    ' >"$temp_dir/startup.log" 2>&1
  [[ ! -e "$temp_dir/missing-zinit" ]]
  pass 'native completion, history, commands, editor fallback, and offline startup'

  mkdir -p "$temp_dir/git-repo"
  git -C "$temp_dir/git-repo" init -q --initial-branch=prompt-test
  env -i HOME="$temp_dir/home" PATH=/usr/bin:/bin DOTFILES="$DOTFILES" \
    TEST_REPO="$temp_dir/git-repo" /bin/zsh -df -c '
      cd "$TEST_REPO"
      gitstatus_start() { return 1; }
      gitstatus_query() { return 1; }
      source "$DOTFILES/zsh.d/prompt.zsh"
      _prompt_git_update
      [[ $_PROMPT_GIT == *prompt-test* ]] || exit 1
      [[ $_PROMPT_GIT_READY == false ]] || exit 1
      _PROMPT_GIT_READY=true
      gitstatus_start() { return 0; }
      gitstatus_check() { return 1; }
      _prompt_git_update
      [[ $_PROMPT_GIT == *prompt-test* ]] || exit 1
      _PROMPT_GIT_READY=true
      gitstatus_check() { return 0; }
      _prompt_git_update
      [[ -z $_PROMPT_GIT && $_PROMPT_GIT_READY == true ]] || exit 1
    '
  pass 'Git fallback covers startup and daemon failure; slow healthy queries stay bounded'

  mkdir -p "$temp_dir/bin"
  cat >"$temp_dir/bin/kubectl" <<'ZSH'
#!/usr/bin/env zsh
print -r -- call >> "$TEST_CALLS"
print -r -- "${KUBECONFIG:t}"
ZSH
  chmod +x "$temp_dir/bin/kubectl"
  print -r -- first >"$temp_dir/context-one"
  print -r -- second >"$temp_dir/context-two"
  touch -r "$temp_dir/context-one" "$temp_dir/context-two"
  env -i HOME="$temp_dir/home" PATH="$temp_dir/bin:/usr/bin:/bin" DOTFILES="$DOTFILES" \
    TEST_ROOT="$temp_dir" TEST_CALLS="$temp_dir/kube-calls" /bin/zsh -df -c '
      source "$DOTFILES/zsh.d/prompt.zsh"
      export KUBECONFIG="$TEST_ROOT/context-one"
      _prompt_kube_update
      [[ $_PROMPT_KUBE_CONTEXT == context-one ]] || exit 1
      _prompt_kube_update
      export KUBECONFIG="$TEST_ROOT/context-two"
      _prompt_kube_update
      [[ $_PROMPT_KUBE_CONTEXT == context-two ]] || exit 1
      export KUBECONFIG="$TEST_ROOT/context-one:$TEST_ROOT/context-two"
      _prompt_kube_update
      [[ -n $_PROMPT_KUBE ]] || exit 1
      export KUBECONFIG="$TEST_ROOT/missing"
      _prompt_kube_update
      [[ -z $_PROMPT_KUBE_CONTEXT && -z $_PROMPT_KUBE ]] || exit 1
    '
  [[ $(wc -l < "$temp_dir/kube-calls") -eq 3 ]]
  pass 'Kubernetes cache handles path changes, multiple files, deletion, and cache hits'

  linker="$DOTFILES/scripts/link-config.zsh"
  destination="$temp_dir/destination/config"
  /bin/zsh "$linker" "$temp_dir/source" "$destination"
  /bin/zsh "$linker" "$temp_dir/source" "$destination"
  [[ -L "$destination" && ! -e "$temp_dir/source/source" ]]
  pass 'directory links are idempotent without nesting links inside their targets'
  /bin/zsh "$linker" --unlink "$temp_dir/source" "$destination"
  [[ ! -L "$destination" && -d "$temp_dir/source" ]]
  pass 'unlink preserves the source directory'

  print -r -- original >"$destination"
  /bin/zsh "$linker" "$temp_dir/source" "$destination"
  [[ $(<"$destination.backup") == original && -L "$destination" ]]
  /bin/zsh "$linker" --unlink "$temp_dir/source" "$destination"
  print -r -- replacement >"$destination"
  if /bin/zsh "$linker" "$temp_dir/source" "$destination" >"$temp_dir/link.log" 2>&1; then
    print -ru2 -- 'FAIL: an existing backup was overwritten'
    exit 1
  fi
  [[ $(<"$destination.backup") == original && $(<"$destination") == replacement ]]
  /bin/zsh "$linker" --unlink "$temp_dir/source" "$destination"
  [[ -f "$destination" && ! -L "$destination" ]]
  pass 'backup collisions and unmanaged files are preserved'

  ln -s "$temp_dir/missing-target" "$temp_dir/destination/unrelated"
  /bin/zsh "$linker" --unlink "$temp_dir/source" "$temp_dir/destination/unrelated"
  [[ -L "$temp_dir/destination/unrelated" ]]
  pass 'cleanup preserves unrelated broken symlinks'

  mkdir -p "$temp_dir/clean-home/.config/nvim" "$temp_dir/clean-home/.config/kitty"
  print -r -- user-config >"$temp_dir/clean-home/.zshrc"
  print -r -- editor-config >"$temp_dir/clean-home/.config/nvim/user.lua"
  ln -s "$DOTFILES/zsh.d" "$temp_dir/clean-home/.zsh.d"
  ln -s "$DOTFILES/tmux.conf" "$temp_dir/clean-home/.tmux.conf"
  ln -s "$temp_dir/missing-target" "$temp_dir/clean-home/.gitignore_global"
  make -s -C "$DOTFILES" clean HOME="$temp_dir/clean-home" >"$temp_dir/clean.log"
  [[ -f "$temp_dir/clean-home/.zshrc" && -f "$temp_dir/clean-home/.config/nvim/user.lua" ]]
  [[ ! -L "$temp_dir/clean-home/.zsh.d" && ! -L "$temp_dir/clean-home/.tmux.conf" ]]
  [[ -L "$temp_dir/clean-home/.gitignore_global" ]]
  pass 'make clean removes only links owned by this repository'

  if (( $+commands[tmux] )); then
    HOME="$temp_dir/home" tmux -S "$temp_dir/tmux-socket" -f /dev/null \
      new-session -d -s test /bin/sleep 30
    HOME="$temp_dir/home" tmux -S "$temp_dir/tmux-socket" source-file "$DOTFILES/tmux.conf"
    [[ $(tmux -S "$temp_dir/tmux-socket" show-options -gv prefix) == C-a ]]
    [[ $(tmux -S "$temp_dir/tmux-socket" list-keys -T prefix p) == *previous-window* ]]
    [[ $(tmux -S "$temp_dir/tmux-socket" list-keys -T prefix ']') == *paste-buffer* ]]
    [[ $(tmux -S "$temp_dir/tmux-socket" list-keys -T prefix C-r) == *send-keys*C-l* ]]
    [[ $(tmux -S "$temp_dir/tmux-socket" list-keys -T root C-l) == *select-pane*-R* ]]
    [[ $(tmux -S "$temp_dir/tmux-socket" list-keys -T copy-mode-vi Enter) == *pbcopy* ]]
    tmux -S "$temp_dir/tmux-socket" set-option -g mouse
    [[ $(tmux -S "$temp_dir/tmux-socket" show-options -gv mouse) == off ]]
    pass 'effective tmux prefix, navigation, paste, copy, and native mouse toggle'
  else
    print -r -- 'SKIP: effective tmux binding tests (tmux not installed)'
  fi

  zinit_file="${ZINIT_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git}/zinit.zsh"
  plugin_root="${zinit_file:h:h}"
  if [[ -r "$zinit_file" && -d "$plugin_root/plugins/zsh-users---zsh-completions" &&
    -d "$plugin_root/plugins/zsh-users---zsh-autosuggestions" &&
    -d "$plugin_root/plugins/zdharma-continuum---fast-syntax-highlighting" ]] &&
    (( $+commands[fzf] && $+commands[zoxide] )); then
    zmodload zsh/zpty
    zmodload zsh/datetime
    mkdir -p "$temp_dir/plugin-home"
    ln -s "$temp_dir/home/.zsh.d" "$temp_dir/plugin-home/.zsh.d"
    cat >"$temp_dir/plugin-home/.zshrc" <<'ZSH'
typeset -gA ZINIT
ZINIT[HOME_DIR]="$HOME/zinit"
ZINIT[PLUGINS_DIR]="$TEST_PLUGIN_ROOT/plugins"
ZINIT[COMPLETIONS_DIR]="$TEST_PLUGIN_ROOT/completions"
source "$DOTFILES/zshrc"
builtin cd "$TEST_REPO"
PROMPT='PLUGIN_TEST_PROMPT> '
ZSH
    env -i HOME="$temp_dir/plugin-home" PATH=/usr/bin:/bin TERM=xterm-256color \
      DOTFILES="$DOTFILES" HOMEBREW_PREFIX="$temp_dir/missing-brew" \
      ZINIT_HOME="${zinit_file:h}" TEST_PLUGIN_ROOT="$temp_dir/empty-plugins" \
      TEST_REPO="$temp_dir/git-repo" DOTFILES_INSTALL_PLUGINS=1 \
      /bin/zsh -di -c '[[ $_ZSH_COMPLETIONS_READY == true ]] && (( $+functions[compdef] ))' \
      >"$temp_dir/missing-plugins.log" 2>&1
    [[ ! -d "$temp_dir/empty-plugins/plugins/romkatv---gitstatus" ]]
    pass 'missing plugins use native completion without cloning, even with installer mode inherited'

    zpty -b interactive env -i HOME="$temp_dir/plugin-home" \
      PATH="$PATH" TERM=xterm-256color DOTFILES="$DOTFILES" \
      HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}" \
      ZINIT_HOME="${zinit_file:h}" TEST_PLUGIN_ROOT="$plugin_root" \
      TEST_REPO="$temp_dir/git-repo" \
      GITSTATUS_CACHE_DIR="${GITSTATUS_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/gitstatus}" \
      TMPDIR="${TMPDIR:-/tmp}" /bin/zsh -di
    wait_for_output PLUGIN_TEST_PROMPT
    float ready_deadline=$(( EPOCHREALTIME + 5 ))
    while (( EPOCHREALTIME < ready_deadline )); do
      # Real input/prompt cycles let the dispatcher progress without invoking its internals.
      zpty -w interactive 'if [[ $_ZSH_COMPLETIONS_READY == true && $(bindkey "^R") == *fzf-history-widget* && $(bindkey "^T") == *fzf-file-widget* && ${_comps[z]:-} == __zoxide_z_complete ]] && (( $+functions[_zsh_autosuggest_start] && $+functions[__zoxide_z] && $+functions[_zsh_highlight] )); then print -r -- PLUGIN_TEST_"RESULT_READY"; else print -r -- PLUGIN_TEST_"RESULT_PENDING"; fi'
      wait_for_output PLUGIN_TEST_RESULT
      [[ $_TEST_PTY_OUTPUT == *PLUGIN_TEST_RESULT_READY* ]] && break
      sleep 0.05
    done
    if [[ $_TEST_PTY_OUTPUT != *PLUGIN_TEST_RESULT_READY* ]]; then
      print -ru2 -- 'FAIL: installed plugins were not ready within five seconds'
      exit 1
    fi
    zpty -w interactive 'if [[ $_PROMPT_GIT == *prompt-test* ]]; then print -r -- GIT_TEST_"PASS"; else print -r -- GIT_TEST_"FAIL"; fi'
    wait_for_output GIT_TEST_PASS
    zpty -w interactive exit
    zpty -d interactive
    pass 'real PTY loads completions, fzf keys, zoxide, suggestions, and highlighting'
  else
    print -r -- 'SKIP: installed-plugin PTY test (run make zsh-plugins and install fzf/zoxide)'
  fi

  print -r -- "Passed $checks regression groups."
} always {
  if (( $+builtins[zpty] )); then
    zpty -d interactive 2>/dev/null || true
  fi
  if (( $+commands[tmux] )); then
    tmux -S "$temp_dir/tmux-socket" kill-server >/dev/null 2>&1 || true
  fi
  rm -r -- "$temp_dir"
}
