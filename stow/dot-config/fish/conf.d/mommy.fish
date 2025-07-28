#!/usr/bin/env fish
if command -q cargo-mommy
    and type -q loadenv

    set -l env_files $HOME/.config/fish/conf.d/*mommy*.env
    for f in $env_files
        loadenv $f
    end
end
