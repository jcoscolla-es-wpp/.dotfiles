#!/usr/bin/env zsh
# Link configuration without overwriting existing files or backups.
setopt ERR_EXIT NO_UNSET PIPE_FAIL

operation=link
if [[ ${1:-} == --unlink ]]; then
  operation=unlink
  shift
fi
if (( $# != 2 )); then
  print -ru2 -- 'Usage: link-config.zsh [--unlink] SOURCE DESTINATION'
  exit 1
fi

source_file="${1:A}"
destination="${2:a}"

if [[ $operation == unlink ]]; then
  if [[ -L "$destination" && ${destination:A} == "$source_file" ]]; then
    unlink "$destination"
    print -r -- "Unlinked $destination"
  elif [[ -e "$destination" || -L "$destination" ]]; then
    print -r -- "Preserved unmanaged configuration: $destination"
  fi
  exit 0
fi

if [[ ! -e "$source_file" ]]; then
  print -ru2 -- "Source does not exist: $source_file"
  exit 1
fi
[[ -L "$destination" && ${destination:A} == "$source_file" ]] && exit 0

if [[ -e "$destination" || -L "$destination" ]]; then
  backup="$destination.backup"
  if [[ -e "$backup" || -L "$backup" ]]; then
    print -ru2 -- "Refusing to overwrite backup: $backup"
    exit 1
  fi
  mv -- "$destination" "$backup"
  print -r -- "Backed up $destination to $backup"
fi

mkdir -p -- "${destination:h}"
ln -s -- "$source_file" "$destination"
print -r -- "Linked $destination -> $source_file"
