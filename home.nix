{ config, pkgs, lib, misc, ... }: 
let
  username = "chloe";
  homeDirectory = "/home/${username}";
  myHomeManagerFlake = "${homeDirectory}/.dotfiles";
  mydotfiles = "${myHomeManagerFlake}/dotfiles";
in 
{

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true; 
  home.stateVersion = "24.05";

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
      
      
    };
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink myHomeManagerFlake;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  } // (
    # This declares an attribute set that describes that each linkName is a
    # symlink from ~/${linkName} to ${mydotfiles}/_${linkName}.
    # The target path format is arbitrary and merely the convention I chose.
    lib.attrsets.mergeAttrsList (lib.lists.map (linkName: { 
      "${linkName}".source = config.lib.file.mkOutOfStoreSymlink "${mydotfiles}/_${linkName}";
    }) [
    # Thus, these symlinks point to targets outside of the nix store
    # and therefore both writable and tracked by this flake's version control
    ".bin"
    ".config/emacs"
    ".config/fish"
    ".config/starship.toml"
    ".gitconfig"
    ".gitignore"
  ]));

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
    EDITOR = "lvim";
    VISUAL = "codium";
    PAGER = "bat";
  };
  # packages are just installed (no configuration applied)
  # programs are installed and configuration applied to dotfiles
  home.packages = [
    pkgs.asciinema
    pkgs.bash
    pkgs.bashInteractive
    pkgs.bat
    pkgs.bitwarden
    pkgs.btop
    pkgs.cheat
    pkgs.distrobox
    pkgs.docker
    pkgs.emacs
    pkgs.eza
    pkgs.firefox
    pkgs.fish
    pkgs.fjo
    pkgs.fnm
    pkgs.font-awesome
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.glab
    pkgs.gparted
    pkgs.gpu-screen-recorder
    pkgs.helix
    pkgs.htop
    pkgs.jq
    pkgs.just
    pkgs.lazygit
    pkgs.libreoffice
    pkgs.librewolf
    pkgs.mdcat
    pkgs.nautilus
    pkgs.neofetch
    pkgs.neovim
    pkgs.nerdfix
    pkgs.nerdfonts
    pkgs.nh
    pkgs.obsidian
    pkgs.pipx
    pkgs.powerline-fonts
    pkgs.powerline-rs
    pkgs.powerline-symbols
    pkgs.qflipper
    pkgs.ripgrep
    pkgs.rustup
    pkgs.shellcheck
    pkgs.starship
    pkgs.syncthing
    pkgs.taskwarrior3
    pkgs.thefuck
    pkgs.thunderbird
    pkgs.tmsu
    pkgs.ventoy-full
    pkgs.vlc
    pkgs.vscodium
    pkgs.zsh

    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

}
