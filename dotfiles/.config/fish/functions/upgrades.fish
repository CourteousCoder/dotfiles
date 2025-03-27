#!/usr/bin/env fish
function upgrades --description 'Perform a full upgrade of all packages managers'
    set -l FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS true
    sudo printf Authenticated for sudo

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
        yay -Syyu --needed --combinedupgrade --noredownload --norebuild --cleanafter --noconfirm $argv
    end

    if command -q nix
        upgrade-nhm
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


