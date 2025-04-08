#!/usr/bin/env fish
function pkgup --description 'Perform a full upgrade of all packages managers'
    set -l FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS true
    sudo printf Authenticated for sudo
    
    # TODO:  Consider returning early after the first match, but only if $argv is given
    # 
    if command -q apt
        sudoize apt
        apt update -y
        and apt full-upgrade -y $argv
        apt autoremove -y
    end 
    
    if command -q dnf
        sudoize dnf
        dnf check-update
        and dnf upgrade
        dnf autoremove
    end

    if command -q yay
        yay -Syyu --needed --combinedupgrade --noredownload --norebuild --cleanafter --noconfirm
    end

    if command -q nix
        nixup
    end

    if command -q flatpak
        flatpak update $argv
        sudo flatpak update $argv
    end

    if command -q pop-upgrade
        pop-upgrade status | grep -q inactive
        and pop-upgrade recovery check
        # and pop-upgrade release check
        and pop-upgrade release update
        and pop-upgrade cancel
        #and pop-upgrade release; upgrade
    end

end


