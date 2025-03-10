function pkgup --description 'Update all packages'
  if which apt
    sudo apt update -y
    and sudo apt upgrade -y $argv

    sudo apt autoremove
  end

  if which flatpak
    flatpak update $argv
    sudo flatpak update $argv
  end

  if which nix
    nix flake check (realpath $FLAKE)
    and nix run nixpkgs#nh -- home switch --update (realpath $FLAKE)

    nix run nixpkgs#git -- -C $FLAKE diff --quiet $FLAKE/flake.lock
    and run nixpkgs#git -- -C $FLAKE add --quiet $FLAKE/flake.lock
    and run nixpkgs#git -- -C $FLAKE commit -m (nix run nixpkgs#home-manager -- generations | head -n 1)
    and run nixpkgs#git -- -C $FLAKE push

    nix upgrade-nix
  end

  if which pop-upgrade
    pop-upgrade status | grep -q inactive
    and pop-upgrade recovery check
    # and pop-upgrade release check
    and pop-upgrade release update
    and pop-upgrade cancel
    #and pop-upgrade release; upgrade
  end
end
