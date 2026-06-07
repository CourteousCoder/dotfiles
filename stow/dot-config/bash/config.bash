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

