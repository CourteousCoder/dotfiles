# ~/.config/bash/config.bash
# vim: filetype=bash

######## Load environment variables ########

env_file="$HOME/.config/bash/env/common.env"
if [[ -r $env_file ]]; then
  set -a
  source $env_file
  set +a
fi
unset _env_file

######## Load PATH ########
path_list_file="$HOME/.config/env/path.list"
for p in $(tac "$path_list_file"); do
  p="$(eval echo "$p")"
  [[ -d $p ]] && export PATH="$p:$PATH"
  unset p
done 
unset path_list_file

config_module="$HOME/.config/bash/config.d"
if [ -d "$config_module" ]; then
  for f in "$config_module"/*.{sh,rc,bashrc,bash}; do
    [ -r "$f" ] && . "$f"
  done
fi
unset config_module

# — Load any *.sh in themes.d/ if you want modular chunks
config_module="$HOME/.config/bash/themes"
if [ -d "$config_module" ]; then
  for f in "$config_module"/*.{sh,rc,bashrc,bash}; do

    [ -r "$f" ] && . "$f"
  done
fi
unset config_module

# — Load themes
config_module="$HOME/.config/bash/completions"
if [ -d "$config_module" ]; then
  for f in "$config_module"/*.{sh,rc,bashrc,bash}; do
    [ -r "$f" ] && . "$f"
  done
fi
unset config_module



######### Load config modules ########
#
#__bashrc_modules=(
#  config.d
#  themes
#  completions
#)
#for module in "$bashrc_modules"; do
#  find "$HOME/.config/bash/$module" -type f '(' -name '*.bashrc' -o -name '*.bash' -o  -name '*.sh' ')' | sort -u | while read -r file; do
#    [ -r "$file" ] && source "$file"
#  done
#done
#unset __bashrc_modules
