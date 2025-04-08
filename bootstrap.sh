#!/usr/bin/env sh

main() {
    install_nix
    run_cmd setup
}

install_nix() {
    export NIX_INSTALLER_NO_CONFIRM=1
    export NIX_INSTALLER_NO_CONFIRM=1
    export NIX_INSTALLER_EXTRA_CONF='trusted-users = "@wheel"'
    which nix || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

run_cmd() {
    if command -v just; then 
        just "$@"
    elif command -v nix; then
        nix run nixpkgs#comma -- just "$@"
    fi
}

main "$@"
