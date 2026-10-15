# ZSH Aliases Configuration
# Optimized for macOS

# Docker/Podman container shortcuts
if command -v docker &>/dev/null || command -v podman &>/dev/null; then
  alias kali='docker run --rm -ti kalilinux/kali-last-release bash'
  alias debian='docker run --rm -ti debian:latest bash'
  alias ubuntu='docker run --rm -ti ubuntu:latest bash'
  alias alpine='docker run --rm -ti alpine:latest sh'
fi

# bat - Better cat with syntax highlighting
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catt='bat'  # Full bat with paging
  alias batp='bat --style=plain'  # Plain without line numbers
fi

# Modern ls alternatives with fallback to standard ls
# Note: Using native /bin/ls by default for reliability and speed
# lsd can cause "os error 60" timeouts with iCloud/network files in HOME
alias ls='/bin/ls -G'
alias ll='/bin/ls -lGah'
alias la='/bin/ls -GA'
alias lt='/bin/ls -lGR'
alias l='/bin/ls -lGh'

# Optional: lsd available explicitly when needed (use 'lsl' command)
if command -v lsd &>/dev/null; then
  # lsd - Modern ls with icons (use explicitly to avoid timeout issues)
  # Documentation: https://github.com/lsd-rs/lsd
  alias lsl='lsd --group-directories-first --git-repos=never'
  alias lsll='lsd -lA --group-directories-first --git-repos=never'
  alias lsla='lsd -A --group-directories-first --git-repos=never'
  alias lslt='lsd --tree --group-directories-first --ignore-glob .git'
  alias tree='lsd --tree --ignore-glob .git'
elif command -v eza &>/dev/null; then
  # eza - Alternative modern ls replacement
  # Documentation: https://github.com/eza-community/eza
  alias lsl='eza --icons --group-directories-first'
  alias lsll='eza -la --icons --group-directories-first --git'
  alias lsla='eza -a --icons --group-directories-first'
  alias lslt='eza --tree --icons --group-directories-first --git-ignore'
  alias tree='eza --tree --icons --git-ignore'
fi

# Modern Unix tools replacements
if command -v fd &>/dev/null; then
  alias find='fd'
fi

if command -v rg &>/dev/null; then
  alias grep='rg'
fi

if command -v dust &>/dev/null; then
  alias du='dust'
fi

if command -v duf &>/dev/null; then
  alias df='duf'
fi

if command -v procs &>/dev/null; then
  alias ps='procs'
fi

# macOS specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Show/hide hidden files in Finder
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

  # Flush DNS cache
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

  # Lock screen
  alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Quick look file
  alias ql='qlmanage -p 2>/dev/null'

  # Open in default app
  alias o='open'
  alias o.='open .'
fi

# Safety aliases - prevent accidental overwrites
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Network utilities
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P | grep LISTEN'

# Quick edits
alias zshrc='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc'

# Git shortcuts (if git is available)
if command -v git &>/dev/null; then
  alias g='git'
  alias gs='git status'
  alias gst='git status -sb'
  alias ga='git add'
  alias gc='git commit'
  alias gp='git push'
  alias gpl='git pull'
  alias gd='git diff'
  alias gco='git checkout'
  alias gb='git branch'
  alias gl='git log --oneline --graph --decorate'
  alias glog='git log --oneline --graph --decorate --all'
fi

# Tmux shortcuts (if tmux is available)
if command -v tmux &>/dev/null; then
  alias t='tmux'
  alias ta='tmux attach -t'
  alias tn='tmux new-session -s'
  alias tl='tmux list-sessions'
  alias tk='tmux kill-session -t'
fi

# Homebrew shortcuts
if command -v brew &>/dev/null; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias brewinfo='brew info'
  alias brewlist='brew list'
  alias brewsearch='brew search'
fi

# macOS utilities
alias cpu='top -o cpu'
alias mem='top -o mem'
