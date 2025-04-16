#!/usr/bin/env sh

REMOTE_REPO='git@codeberg.org:CourteousCoder/dotfiles.git'
DOTFILES_LOCAL="$HOME/.dotfiles"

_BACKUP_AT="$DOTFILES_LOCAL.$(date '+%Yy_%jd_%Hh_%Mm_%S.%Ns').backup";
_TEMP_WORKDIR="$(mktemp -dt 'dot-dotfiles-XXXX')"
_EXIT_CODE=1

main() {
    echo Bootstrapping $REMOTE_REPO to $DOTFILES_LOCAL
    initialize
    get_repo
    pushd $DOTFILES_LOCAL > /dev/null
    _EXIT_CODE=0
    run_cmd just setup
    run_cmd just update
    popd > /dev/null
}

initialize() {
    set -e
    trap cleanup EXIT INT HUP
    pushd $HOME > /dev/null

    if [ -d "$DOTFILES_LOCAL" ]; then
        echo "Already have $DOTFILES_LOCAL"
        echo "Making a backup of  $DOTFILES_LOCAL at $_BACKUP_AT"
        cp -rap --reflink=auto "$DOTFILES_LOCAL" "$_BACKUP_AT"
    fi
}

cleanup() {
    if [ -d "$_TEMP_WORKDIR" ]; then
        echo deleting temporary files
        rm -rf "$_TEMP_WORKDIR"
    fi

    # reset trap EXIT so that tear_down is not called again if more than one signal was trapped.
    trap - EXIT
    popd > /dev/null

    if [ "$_EXIT_CODE" -eq '0' -a -d "$_BACKUP_AT" ]; then
        echo "Success. Dotfiles successfully initialized in $DOTFILES_LOCAL"
        echo "Pre-existing $DOTFILES_LOCAL has been backed up to $_BACKUP_AT"
    elif [ "$_EXIT_CODE" -eq '0' ]; then
        echo "Dotfile ssuccessfully initialized in $DOTFILES_LOCAL"
    elif [ -d "$_BACKUP_AT" ]; then
        echo 'Error encountered. Restoring from backup.' > /dev/stderr
        mkdir -p "$DOTFILES_LOCAL"
        rm -rf "$DOTFILES_LOCAL"
        echo Copying "$_BACKUP_AT" back to "$DOTFILES_LOCAL" > /dev/stderr
        cp -rap --reflink=auto  "$_BACKUP_AT" "$DOTFILES_LOCAL" && rm -rf "$_BACKUP_AT"
    else
        echo Error encountered. Exiting... > /dev/sdterr
    fi

    set +e
    exit $_EXIT_CODE
}


install_nix() {
    export NIX_INSTALLER_NO_CONFIRM=true
    export NIX_INSTALLER_EXTRA_CONF='trusted-users = "@wheel"'
    command -v nix || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

get_repo() {
    if run_cmd git clone "$REMOTE_REPO" "$_TEMP_WORKDIR"; then
        mkdir -p "$DOTFILES_LOCAL"
        rm -rf "$DOTFILES_LOCAL"
        cp -rap --reflink=auto "$_TEMP_WORKDIR" "$DOTFILES_LOCAL"
        echo "Cloned $REMOTE_REPO to $DOTFILES_LOCAL"
    else
        echo Failed to clone remote "$REMOTE_REPO" to local "$DOTFILES_LOCAL" > /dev/stderr
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
