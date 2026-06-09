# Added by flyctl installer
set -g FLYCTL_INSTALL "$HOME/.fly"
fish_add_path -g --prepend "$FLYCTL_INSTALL/bin"
test (command -v flyctl) = "$FLYCTL_INSTALL/bin/flyctl"
and abbr --add --position command -- fly 'flyctl'
