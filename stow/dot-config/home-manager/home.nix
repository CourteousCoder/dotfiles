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
  #myHomeManagerFlake = "${homeDirectory}/.dotfiles";
  myHomeManagerFlake = "${homeDirectory}/.config/home-manager";
  #mydotfiles = "${myHomeManagerFlake}/dotfiles";
in {
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  home.stateVersion = "24.05";

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages

      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'. But I'm using gnu stow instead

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
