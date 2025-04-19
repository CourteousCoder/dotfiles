function fish_command_not_found --wraps=__fish_default_command_not_found_handler
    __fish_default_command_not_found_handler $argv
    contains "$(string lower "$FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS")" true 1 yes y set on enable enabled always 
    and command -q nix
    and test -e "~/.cache/nix-index/files"
    and ping -c 1 github.com > /dev/null
    or return 1
    
    echo Attempting to download and run $argv[1] from nixpkgs... > /dev/stderr

    if command -q comma
        comma -- $argv
    else 
        nix --extra-experimental-features 'nix-command flakes' run 'nixpkgs#comma' -- $argv
    end
end
