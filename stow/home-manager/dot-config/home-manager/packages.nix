{pkgs, ...}: let
  unstablePkgs = with pkgs.unstable; [
    # Unstable nixpkgs branch
    font-awesome
    legcord
    nerd-fonts.fira-code
    nerdfix
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
    comma
    delta
    emacs
    eza
    firefox-bin
    fish
    #forgejo
    fnm
    fzf
    gh
    git
    git-stack
    #glab
    gparted
    #htop
    lazygit
    libreoffice-bin
    librewolf-bin
    #mdcat
    neovim
    obsidian
    #qflipper
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
    transmission4
    ventoy-full
    vlc
    vscodium
    wireguard-tools
    wofi
    xonsh
    zsh
  ];
in {
  home.packages = stablePkgs ++ unstablePkgs;
}
