function fish_command_not_found --wraps=__fish_default_command_not_found_handler
    __fish_default_command_not_found_handler $argv
    contains "$(string lower "$FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS")" true 1 yes y set on enable enabled always 
    or return 1

    echo Attempting to download and run $argv[1] from nixpkgs...
    switch $argv[1]
        case nix
            
        case comma ','
            nix --extra-experimental-features 'nix-command flakes' run nixpkgs#comma -- $argv
        case '*'
            command comma -- $argv
    end
end

function __fish_command_not_found_handler --wraps fish_command_not_found --on-event fish_command_not_found
     fish_command_not_found $argv
end
