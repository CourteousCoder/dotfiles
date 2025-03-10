function upgrades --description 'Perform a full upgrade of all packages managers'
    if which nix
        set --local fish_trace on
        set --local dotfiles (realpath $FLAKE)
        nix flake check $dotfiles
        and nix run nixpkgs#nh -- home switch --update $dotfiles

        nix run nixpkgs#git -- -C $dotfiles diff --quiet $dotfiles/flake.lock
        or begin
            true
            and nix run nixpkgs#git -- -C $dotfiles add flake.lock
            and nix run nixpkgs#git -- -C $dotfiles commit -m (nix run nixpkgs#home-manager -- generations | head -n 1)
            and nix run nixpkgs#git -- -C $dotfiles push
        end
    end

    if which flatpak
        flatpak update $argv
        sudo flatpak update $argv
    end

    if which apt
        sudo apt update -y
        and sudo apt upgrade -y $argv

        sudo apt autoremove
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
