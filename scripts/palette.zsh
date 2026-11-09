# Emerald Arcana: single source of truth for every hex color in this repository.
# Configs that cannot source this file (kitty.conf, tmux.conf, fzf options) copy these
# values; scripts/validate-configs.zsh fails when one of them uses a hex outside it.
#
# Roles: emerald = primary, active, success | violet = accent, focus
#        aqua = info | amber = warning, bell | rose = error | orchid = special
# Contrast is WCAG against bg (text minimum 4.5); decorative colors are marked.

typeset -gA PALETTE=(
  bg_dark   '#0e0b17'   # tab bar, deepest layer
  bg        '#13101f'   # background
  surface   '#1d1830'   # bars, inactive tabs, ANSI black
  border    '#3a3160'   # inactive borders (decorative)
  selection '#3b2f66'   # selected text background
  fg        '#dcd7f0'   # text, 13.39
  fg_dim    '#b4aed0'   # attenuated text, ANSI white, 8.83
  comment   '#8a82ab'   # comments, ANSI bright black, 5.23
  emerald   '#2fd49b'   # 9.82
  emerald_deep '#1fa87a' # 6.19
  violet    '#a98bf5'   # 6.86
  violet_deep '#5b46ad' # search background in Neovim, 5.14 with fg
  indigo    '#8aa0f7'   # ANSI blue, 7.54
  orchid    '#d38cf5'   # ANSI magenta, 7.88
  aqua      '#52d6c8'   # ANSI cyan, 10.53
  amber     '#e8b46a'   # ANSI yellow, 9.96
  rose      '#f2728c'   # ANSI red, 6.74
  rose_deep '#d9566f'   # deeper error accent, 4.91
  fox       '#f0985a'   # orange detail matching the tmux fox, 8.33
)

# Tints derived by blending palette colors into bg (Neovim diff backgrounds).
typeset -ga PALETTE_DERIVED=(
  '#163636'   # emerald_deep 25%
  '#442133'   # rose_deep 25%
  '#191529'   # border 15%
)
