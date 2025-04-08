#!/usr/bin/env fish

set -gx EDITOR nvim

if status is-interactive
    abbr --add vi_and_vim_to_neovim --position command --regex 'vim?' -- nvim
end
