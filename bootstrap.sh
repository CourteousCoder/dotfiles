#!/usr/bin/env sh

REMOTE_URL='git@codeberg.org/CourteousCoder/dotfiles.git'
DOTFILES_LOCAL="$HOME/.dotfiles"

main() {
    echo $REMOTE_REPO $DOTFILES_LOCAL
    get_repo "$REMOTE_REPO" "$DOTFILES_LOCAL"
    cd $DOTFILES_LOCAL
    

    run_cmd just setup
    run_cmd just update
}

install_nix() {
    export NIX_INSTALLER_NO_CONFIRM=1
    export NIX_INSTALLER_EXTRA_CONF='trusted-users = "@wheel"'
    command -v nix || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

get_repo() {
    local _remote="$1"
    local _local="$2"
    if [ -d "$_local" ]; then
        echo "Already have $_local"
        return
    fi
    export local _timestamp="$(date '+%Yy_%jd_%Hh_%Mm_%S.%Ns')"
    export local _tmp="$(mktemp -d)"

    if run_cmd git clone "$_remote" "$_tmp"; then
        mv "$_tmp" "$_local"
        echo "Cloned $_local from $_remote"
    else
        # cleanup incomplete state
        mkdir -p "$_tmp"
        rm -rf "$_tmp"

        # Restore backup
        mv "$_backup_at" "$_local"
        
        echo Failed to clone remote "$_remote" to local "$_local" > /dev/stderr
        exit 1
    fi
}


run_cmd() {
    local cmd="$1"
    shift

    if command -v "$cmd"; then 
        "$cmd" "$@"
    elif command -v "nix"; then
        nix run 'nixpkgs#comma' -- "$cmd" "$@"
    else
        install_nix && nix run 'nixpkgs#comma' -- "$cmd" "$@"
        return
    fi
}

main "$@"
