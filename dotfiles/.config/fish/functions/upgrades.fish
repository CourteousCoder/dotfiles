#!/usr/bin/env fish
function upgrades --description 'Perform a full upgrade of all packages managers'
    sudo printf Authenticated for sudo

    # HACK: my tmpfs on /tmp keeps running out of memory and i don't feel like repartitioning.
    set -lx TMPDIR /var/tmp
    sudo mount --bind /var/tmp /tmp
    and set -l mounted_tmp_status $status
    

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

    test $mountetd_tmp_status
    and sudo umount /var/tmp /tmp
end


