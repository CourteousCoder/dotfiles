#!/usr/bin/env sh

REMOTE_REPO='git@codeberg.org/CourteousCoder/dotfiles.git'
DOTFILES_LOCAL="$HOME/.dotfiles"

_TEMP_WORKDIR=
_BACKUP_AT=
_SUCCESS="false"

main() {
    echo Bootstrapping $REMOTE_REPO to $DOTFILES_LOCAL
    get_repo "$REMOTE_REPO" "$DOTFILES_LOCAL"
    cd $DOTFILES_LOCAL
    run_cmd just setup
    run_cmd just update
    _SUCCESS="true"
}

set_up() {
    trap clean_up EXIT INT HUP
    _TEMP_WORKDIR="$(mktemp -d)"

    if [ -d "$DOTFILES_LOCAL" ]; then
        echo "Already have $DOTFILES_LOCAL"
        _BACKUP_AT="$DOTFILES_LOCAL.$(date '+%Yy_%jd_%Hh_%Mm_%S.%Ns').backup"
        echo "Making a backup of  $DOTFILES_LOCAL at $_BACKUP_AT"
        cp -ap --reflink=auto "$DOTFILES_LOCAL" "_$BACKUP_AT"
    fi
}

tear_down() {
    if [ -d "$_TEMP_WORKDIR" ]; then
        echo deleting temporary files
        rm -rf $_TEMP_WORKDIR
    fi

    # reset trap EXIT so that tear_down is not called again if more than one signal was trapped.
    trap - EXIT

    if [ "${_SUCCESS:-false}" -eq "true" ]; then   
        exit 0
    elif [ -d "$_BACKUP_AT" ]; then
        echo restoring backup
        mkdir -p $DOTFILES_LOCAL
        rm -rf $DOTFILES_LOCAL
        cp -ap --reflink=auto  $_BACKUP_AT $DOTFILES_LOCAL
    fi

    exit 1
}


install_nix() {
    export NIX_INSTALLER_NO_CONFIRM=1
    export NIX_INSTALLER_EXTRA_CONF='trusted-users = "@wheel"'
    command -v nix || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

get_repo() {
    local _remote="$1"
    local _local="$2"

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
