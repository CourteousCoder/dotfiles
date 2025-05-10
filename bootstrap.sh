#!/usr/bin/env sh

set -euo pipefail

REMOTE_REPO='git@codeberg.org:CourteousCoder/dotfiles.git'
DOTFILES_LOCAL="$HOME/.dotfiles"

_BACKUP_AT="$DOTFILES_LOCAL.$(date '+%Yy_%jd_%Hh_%Mm_%S.%Ns').backup";
_TEMP_WORKDIR="$(mktemp -dt 'dot-dotfiles-XXXXX')"
_EXIT_CODE=0

main() {
    initialize
    echo Bootstrapping $REMOTE_REPO to $DOTFILES_LOCAL

    install_nix
    verify_nix

    clone_dotfiles_repo
    setup_dotfiles

    exit_cleanly
}

initialize() {
    trap exit_cleanly EXIT INT HUP

    if [ -d "$DOTFILES_LOCAL" ]; then
        echo "Already have $DOTFILES_LOCAL"
        echo "Making a backup of  $DOTFILES_LOCAL at $_BACKUP_AT"
        cp -rap --reflink=auto "$DOTFILES_LOCAL" "$_BACKUP_AT"
    fi

}

install_nix() {
    export NIX_INSTALLER_NO_CONFIRM=true
    export NIX_INSTALLER_EXTRA_CONF="extra-trusted-users = @wheel $USER"
    if ! command -v nix &>/dev/null; then
        curl -sSf -L https://install.lix.systems/lix > "$_TEMP_WORKDIR/lix-installer.sh"
        sh "$_TEMP_WORKDIR/lix-installer.sh" \
            --extra-conf "$NIX_INSTALLER_EXTRA_CONF" \
            --no-confirm
    fi
}

verify_nix() {
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # multi-user install:
        # this file guards itself so it only runs once per shell
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
        # single-user install:
        . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    else
        exit_cleanly 1
    fi
}

clone_dotfiles_repo() {
    if nix flake clone "$REMOTE_REPO" "$_TEMP_WORKDIR/repo"; then
        mkdir -p "$DOTFILES_LOCAL"
        rm -rf "$DOTFILES_LOCAL"
        cp -rap --reflink=auto "$_TEMP_WORKDIR/repo" "$DOTFILES_LOCAL"
        echo "Cloned $REMOTE_REPO to $DOTFILES_LOCAL"
    else
        echo "❌ Could not clone remote '$REMOTE_REPO' to local '$DOTFILES_LOCAL'" >&2
        exit_cleanly 1
    fi
}

setup_dotfiles()
    cd $DOTFILES_LOCAL
    nix run $DOTFILES_LOCAL -- setup
}

exit_cleanly() {
    _EXIT_CODE="$1"
    if [ -d "$_TEMP_WORKDIR" ]; then
        echo deleting temporary files
        rm -rf "$_TEMP_WORKDIR"
    fi

    # reset trap EXIT so that tear_down is not called again if more than one signal was trapped.
    trap - EXIT
    popd > /dev/null

    if [ "$_EXIT_CODE" -eq '0' -a -d "$_BACKUP_AT" ]; then
        echo "⚠️  Pre-existing '$DOTFILES_LOCAL' has been backed up to '$_BACKUP_AT'"
        echo "✔️  Dotfiles successfully initialized in $DOTFILES_LOCAL"
    elif [ "$_EXIT_CODE" -eq '0' ]; then
        echo "✔️  Dotfiles successfully initialized in $DOTFILES_LOCAL"
    elif [ -d "$_BACKUP_AT" ]; then
        echo "❌ Error encountered during setup. Restoring previous state from backup." >&2
        mkdir -p "$DOTFILES_LOCAL"
        rm -rf "$DOTFILES_LOCAL"
        echo Copying "$_BACKUP_AT" back to "$DOTFILES_LOCAL" 1>&2
        cp -rap --reflink=auto  "$_BACKUP_AT" "$DOTFILES_LOCAL" && rm -rf "$_BACKUP_AT"
    else
        echo "❌ Error encountered during setup Exiting..." >&2
    fi

    exit $_EXIT_CODE
}


main "$@"
