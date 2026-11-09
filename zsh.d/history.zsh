# History Configuration

HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history file
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_FIND_NO_DUPS         # Do not display duplicates in search
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in history file
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
unsetopt INC_APPEND_HISTORY INC_APPEND_HISTORY_TIME
setopt SHARE_HISTORY             # Imports and appends history between sessions
