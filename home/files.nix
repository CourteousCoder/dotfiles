# Dotfile-import module: out-of-store symlink mirror of the old stow tree.
#
# nativelyManaged starts empty (pure symlink mirror) and only grows in Phase 4
# as tools are converted to programs.*. Audit rule: any config/<x> that an
# enabled programs.* also writes must be added here (or its dir removed) in the
# same commit, or the two collide. Audited 2026-06-08: the enabled modules
# (eza bat atuin zoxide direnv starship dircolors) are clean, so [] is correct.
{
  config,
  lib,
  ...
}: let
  dots = import ../lib/dotfiles.nix {inherit lib config;};
  home = config.home.homeDirectory;
  nativelyManaged = []; # Phase 4 only: add "git" "fish" "nvim" ... as converted
in {
  # config/* -> ~/.config/* (xdg.configFile prepends ~/.config, so no dot- prefix)
  xdg.configFile = dots.mkOutOfStoreTree {
    src = ../config;
    repoSub = "config";
    exclude = nativelyManaged;
  };

  # home-files/dot-* -> ~/.*   and   home-bin/* -> ~/.local/bin/*
  # plus the two top-level theme/icon trees. All merged into one home.file
  # value (Nix forbids `home.file = …` alongside `home.file."x" = …`).
  home.file =
    dots.mkOutOfStoreTree {
      src = ../home-files;
      repoSub = "home-files";
    }
    // dots.mkOutOfStoreTree {
      src = ../home-bin;
      repoSub = "home-bin";
      destPrefix = ".local/bin/";
    }
    // {
      ".themes".source = dots.mkOutOfStoreSymlink "${home}/.dotfiles/themes";
      ".icons".source = dots.mkOutOfStoreSymlink "${home}/.dotfiles/icons";
    };
}
