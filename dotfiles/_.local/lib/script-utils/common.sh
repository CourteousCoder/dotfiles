#!/bin/env -s sh -c 'echo "You should source this at the beginning of your script instead of running it."; false'
# shellcheck shell=dash
# This script is based off https://git.lix.systems/lix-project/lix-installer/src/commit/0726d84546e06617b89fb5e778fa30af810ace24/lix-installer.sh

if [ "${__SOURCE_GUARD_ALREADY_SOURCED__common_}+true}" != "true" ]; then
    __SOURCE_GUARD_ALREADY_SOURCED__script-utils_=true

    if [ "$KSH_VERSION" = 'Version JM 93t+ 2010-03-05' ]; then
        # The version of ksh93 that ships with many illumos systems does not
        # support the "local" extension.  Print a message rather than fail in
        # subtle ways later on:
        echo ' does not work with this ksh93 version; please try bash!' >&2
        exit 1
    fi

    runn() {
        # Run cmd locally if available
        if check_cmd "$1"; then
            "$@"
            # no op
        elif check_cmd "nix"; then
            # , "$@"
            _cmd="$1"
            shift
            nix --extra-experimental-features "nix-command flakes" run "nixpkgs#${_cmd}" -- "$@"
        else
            # To try runnin cmd anyway and give cmd's stdout and stderr
            "$@"
        fi
    }

    say() {
        printf "$0: %s\n" "$1"
    }

    err() {
        say "$1" >&2
        exit 1
    }

    need_cmd() {
        if ! check_cmd "$1"; then
            err "need '$1' (command not found)"
        fi
    }

    check_cmd() {
        command -v "$1" >/dev/null 2>&1
    }

    assert_nz() {
        if [ -z "$1" ]; then err "assert_nz $2"; fi
    }

    # Run a command that should never fail. If the command fails execution
    # will immediately terminate with an error showing the failing
    # command.
    ensure() {
        if ! "$@"; then err "command failed: $*"; fi
    }

    # This is just for indicating that commands' results are being
    # intentionally ignored. Usually, because it's being executed
    # as part of error handling.
    ignore() {
        "$@"
    }
fi
