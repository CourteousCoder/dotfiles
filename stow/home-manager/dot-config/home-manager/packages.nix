{pkgs, ...}: let
  unstablePkgs = with pkgs.unstable; [
    # Unstable nixpkgs branch
    legcord
    nerd-fonts.fira-code
  ];
  stablePkgs = with pkgs; [
    alejandra
    asciinema
    bash
    bashInteractive
    bat
    bitwarden
    brave
    btop
    chezmoi
    codeberg-cli
    delta
    emacs
    eza
    firefox-bin
    fish
    forgejo
    fnm
    font-awesome
    fzf
    gh
    git
    git-stack
    glab
    gparted
    htop
    lazygit
    libreoffice
    librewolf-bin
    mdcat
    neovim
    nerdfix
    nh
    obsidian
    powerline-fonts
    powerline
    powerline-symbols
    qflipper
    #redshift
    ripgrep
    #rustup
    shellcheck
    starship
    syncthing
    tailscale
    taskwarrior3
    thefuck
    tmsu
    transmission-4
    ventoy-full
    vlc
    vscodium
    wireguard-tools
    wofi
    xonsh
    zsh
    #(nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
in {
  home.packages = stablePkgs ++ unstablePkgs;
}
