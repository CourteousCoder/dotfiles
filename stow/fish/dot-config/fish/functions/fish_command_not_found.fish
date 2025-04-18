function fish_command_not_found --wraps=__fish_default_command_not_found_handler
    __fish_default_command_not_found_handler $argv
    contains "$(string lower "$FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS")" true 1 yes y set on enable enabled always 
    or return 1

    echo Attempting to download and run $argv[1] from nixpkgs... > /dev/stderr
    switch $argv[1]
        case nix
            set -x NIX_INSTALLER_NO_CONFIRM=true
            set -x NIX_INSTALLER_EXTRA_CONF='trusted-users = "@wheel"'
            command -v nix; or curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
            $argv
        case '*'
            if command -q comma
                command comma -- $argv
                and return $status
            else
                nix --extra-experimental-features 'nix-command flakes' run 'nixpkgs#comma' -- $argv
                and return $status
            end
    end
end
