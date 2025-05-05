#!/usr/bin/fish
function fish_command_not_found --wraps=__fish_default_command_not_found_handler
    __fish_default_command_not_found_handler $argv
    true
        and status is-interactive
        and command -q nix
        and test "$FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS" = true
        and command -q nc
        and nc -zw 1 github.com 443  #
    or return 1

    echo Attempting to run "'$argv[1]'" from nixpkgs
    if not test -e "~/.cache/nix-index/files"
        echo "Building package index..."
        echo '  nix run nixpkgs#nix-index'
        nix run nixpkgs#nix-index
        or return 1
    end

    if command -q comma
        echo "  comma -- $argv"
        comma -- $argv
    else 
        echo "  nix --extra-experimental-features 'nix-command flakes' run 'nixpkgs#comma' -- $argv"
        nix --extra-experimental-features 'nix-command flakes' run 'nixpkgs#comma' -- $argv
    end
end
