{ config, pkgs, lib, nixpkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chloe";
  home.homeDirectory = "/home/chloe";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing

  #pkgs.config.allowUnfree = true;


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    jetbrains.pycharm-community
    librewolf
    neofetch
    #discord
    bitwarden
    obsidian
    steam
    libreoffice
    firefox
    thunderbird
    vlc
    nh
    bat
    devenv
    direnv
    eza
    fish
    bash
    git
    gh
    fjo
    vscodium
    lunarvim
    rustup
    pipx
    fnm
    gparted
    gpu-screen-recorder
    font-awesome
    powerline-rs
    powerline-fonts
    powerline-symbols
    nerdfonts
    nerdfix
    starship
    taskwarrior
    tmsu
    thefuck
    nautilus
    pcmanfm
    kitty
    syncthing
    asciinema
    #nixgl
    alacritty
    
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    #(pkgs.alacritty.overrides { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    (pkgs.writeShellScriptBin "terminal.sh" ''
     nix run github:nix-community/nixGL#nixGLIntel -- nixpkgs#alacritty & 
    '')
      
    (pkgs.writeShellScriptBin "home-rebuild.sh" ''
    #!/usr/bin/env bash

    set -e

    export EDITOR=${EDITOR:-lvim}
    dotfiles=~/dotfiles

    pushd "$dotfiles"

    home-manager edit
    git diff -U0 *.nix

    echo "Rebuilding Nix home manager..."
    nh home switch "$dotfiles" &>nh-home-switch.log || (
      cat nh-home-switch.log | grep --color error && false)

    gen="$(home-manager generations | head -n 1)"
    git commit -am "$gen"

    popd
    '')
  ];
  # ++ import ./packages.nix { inherit pkgs; };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
#     ".config/fish".source = dotfiles/.config/fish/config.fish

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
