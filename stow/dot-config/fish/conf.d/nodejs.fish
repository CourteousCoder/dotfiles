#!/usr/bin/env fish


if test -x ~/.cargo/bin/fnm
    fish_add_path -gm ~/.cargo/bin
end
if command -q fnm
    fnm env --use-on-cd --version-file-strategy recursive --corepack-enabled --resolve-engines | source
end
