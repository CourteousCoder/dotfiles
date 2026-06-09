{
  config,
  pkgs,
  unstable,
  lib,
  misc,
  ...
}: let
  username = "chloe";
  homeDirectory = "/home/${username}";
in {
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = _: true;

  # Home Manager owns every dotfile via out-of-store symlinks (see home/files.nix).

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/chloe/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "codium";
    PAGER = "bat";
    DIFFTOOL = "delta";
    XDG_DATA_DIRS = "${homeDirectory}:$XDG_DATA_DIRS";
  };
}
