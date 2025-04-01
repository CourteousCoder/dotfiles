#!/usr/bin/env fish
function nixup
    set -lx FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS true

    set -lx FLAKE (realpath $FLAKE)
    alias git="git -C '$FLAKE'"
    alias nix-flake "command nix --extra-experimental-features 'nix-command flakes' flake"

    nix-flake check "$FLAKE"
    and nix-flake update --flake "$FLAKE"
    and git add flake.lock
    and nh home switch -ub ".backup_$(date -u +%s).bak" "$FLAKE" | tee "$FLAKE/nh-home-switch.log"
    or return 1

    git commit -am "$gen"
    set -l gen (home-manager generations --flake "$FLAKE" | head -n 1)
    and git commit -am $gen
    # and git push
end
