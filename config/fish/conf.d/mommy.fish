#!/usr/bin/env fish
if type -q mommy cargo-mommy
    if type -q loadenv
        set -l env_files $HOME/.config/fish/conf.d/*mommy*.env
        and loadenv $env_files
    end
end
