# ~/.config/bash/config.bashrc

# — Basic environment
ENV_FILE="$HOME/.config/env/common.env"
if [ -r "$ENV_FILE" ]; then
  # turn KEY=VALUE into exports
  # the leading “export” makes it available to child processes
  set -a
  . "$ENV_FILE"
  set +a
fi

# — Aliases
# — Prompt (simple example; customize as you like)
# — Handy functions



# — Load any *.sh in config.d/ if you want modular chunks
CONFIG_D="$HOME/.config/bash/config.d"
if [ -d "$CONFIG_D" ]; then
  for f in "$CONFIG_D"/*.{sh,rc,bashrc,bash}; do
    [ -r "$f" ] && . "$f"
  done
fi

# — Load any *.sh in config.d/ if you want modular chunks
BASH_THEMES_D="$HOME/.config/bash/themes"
if [ -d "$BASH_THEMES_D" ]; then
  for f in "$BASH_THEMES_D"/*.{sh,rc,bashrc,bash}; do
    [ -r "$f" ] && . "$f"
  done
fi

