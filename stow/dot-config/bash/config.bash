# ~/.config/bash/config.bash
# vim: filetype=bash

###
# source_many
#
# Source multiple script files in the order given
# If none are given, then this does nothing.
#
# Unlike the source builtin, this silently ignores script files that are not readable by $USER or dont exist.
###
source_many() {
  local script_files=( "$@" )
  for f in $script_files; do
    echo $f
    if [ -r "$f" ]; then
      . "$f"
    fi
  done
}

###
# Load each of given dotenv files that exists, in the order given.
# if none are given, then load ./.env if it exists.
#
# Usage:
#   load_env [...dotenv_files]
#
# HACK: This will executes .env files as bash code rather than parsing the key-value pairs of an env file.
# It works under the assumption that the syntax of .env files is a subset the syntax of bash.
# This might not always be what you want, as it is a security concern.
###
load_dotenv() {
  local env_files=( "$@" )
  (( $# )) && env_files+="./.env"
  set -a
  # This will 
  source_many "${env_files[@]}"
  set +a
}



# Similar to source_many
# Recursively source all readable scripts matching the given patterns under a directory tree
source_recursive() {
  [[ $# -lt 1 ]] || return 1
  local base_dir="$1"
  shift 1
  local patterns=("${@:-*.sh *.bash *.bashrc}")
  #
  # Dynamically build args `find`
  local find_args=("$base_dir" '-type' 'f')

  # Args for pttern-matching names with `find`
  local match_names=( '-false' )
  for pattern in "${patterns[@]}"; do
    match_names+=( '-o' '-name' "$pattern" )
  done

  find_args+=(
    '('
    "${match_names[@]}"
    ')'
    '-print'
  )
  echo $find_args
  find "${find_args[@]}" | sort | xargs | while read -r args; do
    source_many "${args[@]}"
  done
}

# 
# SOURCES_D="$HOME/.config/bash/config.d"
# if [ -d "$SOURCES_D" ]; then
#   for f in "$SOURCES_D"/*.{sh,rc,bashrc,bash}; do
#     [ -r "$f" ] && . "$f"
#   done
# fi
# 
# # — Load any *.sh in themes.d/ if you want modular chunks
# SOURCES_D="$HOME/.config/bash/themes"
# if [ -d "$SOURCES_D" ]; then
#   for f in "$SOURCES_D"/*.{sh,rc,bashrc,bash}; do
# 
#     [ -r "$f" ] && . "$f"
#   done
# fi
# 
# # — Load themes
# SOURCES_D="$HOME/.config/bash/completions"
# if [ -d "$SOURCES_D" ]; then
#   for f in "$SOURCES_D"/*.{sh,rc,bashrc,bash}; do
#     [ -r "$f" ] && . "$f"
#   done
# fi
# 


# Load shell environment variables
load_dotenv "$HOME/.config/env/common.env" "$HOME"/.config/bash/env/*.env


# For a modular bashrc, load *.sh files recursively from each of these directories in lexicographical order
for module in 'config.d' 'themes' 'completions'; do
  source_recursive "$HOME/.config/bash/$module" '*.sh' '*.bash' '*.bashrc'
done

export -f source_many source_recursive load_dotenv

