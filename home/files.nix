# Dotfile-import module.
#
# Phase 0: intentionally empty (pure flake restructure, no behavior change).
# Phase 1 fills this with the out-of-store symlink mirror of the old stow tree.
{...}: {
  xdg.configFile = {};
}
