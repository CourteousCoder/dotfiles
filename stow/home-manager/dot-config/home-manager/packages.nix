{pkgs, ...}: let
  unstablePkgs = with pkgs.unstable; [
    # Unstable nixpkgs branch
    font-awesome
    legcord
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.monoid
    nerd-fonts.noto
    nerd-fonts.source-code-pro
    nerdfix
    noto-fonts-color-emoji
    nh
    powerline
    powerline-fonts
    powerline-symbols
  ];
  stablePkgs = with pkgs; [
    alejandra
    asciinema
    bash
    bashInteractive
    bat
    #bitwarden
    brave
    #btop
    #chezmoi
    codeberg-cli
    delta
    deluge
    emacs
    eza
    firefox-bin
    fish
    #forgejo
    fnm
    fzf
    gcc
    gh
    git
    git-stack
    #glab
    gnumake
    gparted
    #htop
    lazygit
    #libreoffice
    librewolf-bin
    #mdcat
    neovim
    obsidian
    #qflipper
    #redshift
    ripgrep
    #rustup
    shellcheck
    signal-desktop
    starship
    syncthing
    tailscale
    taskwarrior3
    thefuck
    tmsu
    unzrip
    ventoy-full
    vlc
    vscodium
    wireguard-tools
    wl-clipboard-rs
    wofi
    #    xonsh
    zsh
  ];
in {
  home.packages = stablePkgs ++ unstablePkgs;
}
#just chemacs

