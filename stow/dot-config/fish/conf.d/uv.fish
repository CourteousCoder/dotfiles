#!/usr/bin/env fish

if status is-interactive
    command -q uv; and uv --generate-shell-completion fish | source
    command -q uvx; and uvx --generate-shell-completion fish | source
end
