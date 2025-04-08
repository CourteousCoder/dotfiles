#!/usr/bin/env fish

if status is-interactive
    uv --generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
end
