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
  mydotfiles = "${myHomeManagerFlake}/dotfiles";
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
  # plain files is through 'home.file'.
  home.file =
    {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      #      ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink myHomeManagerFlake;
      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    }
    // (
      # This declares an attribute set that describes that each linkName is a
      # symlink from ~/${linkName} to ${mydotfiles}/_${linkName}.
      # The target path format is arbitrary and merely the convention I chose.
      lib.attrsets.mergeAttrsList (lib.lists.map (linkName: {
          "${linkName}".source = config.lib.file.mkOutOfStoreSymlink "${mydotfiles}/${linkName}";
        }) [
          # Thus, these symlinks point to targets outside of the nix store
          # and therefore both writable and tracked by this flake's version control
          /*
            ".bashrc"
          ".bin"
          ".config/bashrc"
          ".config/distrobox"
          ".config/dunst"
          ".config/emacs"
          ".config/fastfetch"
          ".config/fish"
          ".config/git"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/hypr"
          ".config/kitty"
          ".config/ml4w"
          ".config/nvim"
          ".config/nwg-dock-hyprland"
          ".config/ohmyposh"
          ".config/qt6ct"
          ".config/redshift"
          ".config/rofi"
          ".config/starship.toml"
          ".config/swaync"
          ".config/vim"
          ".config/wal"
          ".config/waybar"
          ".config/waypaper"
          ".config/wlogout"
          ".config/xonsh"
          ".config/xsettingsd"
          ".config/zshrc"
          ".elvish"
          ".gtkrc-2.0"
          ".local/lib"
          ".Xresources"
          ".zshrc"
          */
        ])
    );

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
    XDG_DATA_DIRS = "${homeDirectory}:$XDG_DATA_DIRS";
  };
  # packages are just installed (no configuration applied)
  # programs are installed and configuration applied to dotfiles
  home.packages = [
    pkgs.alejandra
    pkgs.asciinema
    pkgs.bash
    pkgs.bashInteractive
    pkgs.bat
    pkgs.bitwarden
    pkgs.brave
    pkgs.btop
    pkgs.codeberg-cli
    pkgs.emacs
    pkgs.eza
    pkgs.firefox
    pkgs.fish
    pkgs.forgejo
    pkgs.fnm
    pkgs.font-awesome
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.git-stack
    pkgs.glab
    pkgs.gparted
    pkgs.htop
    pkgs.lazygit
    pkgs.unstable.legcord
    pkgs.libreoffice
    pkgs.librewolf
    pkgs.mdcat
    pkgs.neofetch
    pkgs.neovim
    pkgs.nerdfix
    pkgs.unstable.nerd-fonts.fira-code
    pkgs.nh
    pkgs.obsidian
    pkgs.powerline-fonts
    pkgs.powerline
    pkgs.powerline-symbols
    pkgs.qflipper
    #pkgs.redshift
    pkgs.ripgrep
    #pkgs.rustup
    pkgs.shellcheck
    pkgs.starship
    pkgs.syncthing
    pkgs.tailscale
    pkgs.taskwarrior3
    pkgs.thefuck
    pkgs.tmsu
    pkgs.ungoogled-chromium
    pkgs.uutils-coreutils-noprefix
    pkgs.ventoy-full
    pkgs.vlc
    pkgs.vscodium
    pkgs.wireguard-tools
    pkgs.wofi
    pkgs.xonsh
    pkgs.yazi
    pkgs.zsh
    #(pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
}
