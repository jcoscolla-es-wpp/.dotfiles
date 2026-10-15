# Kitty Terminal Integration
# KITTY_WINDOW_ID survives tmux; TERM does not (tmux sets tmux-256color)

if [[ -n "$KITTY_WINDOW_ID" ]] && command -v kitten &>/dev/null; then
  alias ssh="kitten ssh"
  alias icat="kitten icat"
  alias d="kitten diff"
fi
