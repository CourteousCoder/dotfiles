#!/usr/bin/fish
function fish_command_not_found --wraps=__fish_default_command_not_found_handler
    __fish_default_command_not_found_handler $argv

    # and Check if we opted in to this
    contains "$(string lower "$FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS")" true 1 yes y set on enable enabled always 
    and command -q nix
    and command -q nc
    and nc -z github.com 443  #
    and test -e "~/.cache/nix-index/files"
    or return 1

    echo Attempting to download and run $argv[1] from nixpkgs... > /dev/stderr

    if command -q comma
        comma -- $argv
    else 
        nix --extra-experimental-features 'nix-command flakes' run 'nixpkgs#comma' -- $argv
    end
end
