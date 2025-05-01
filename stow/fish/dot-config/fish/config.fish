#!/usr/bin/env fish

set -gx SHELL (which fish)
set -gx EDITOR nvim
#set -gx VISUAL codium
#set -gx FLAKE $HOME/.dotfiles

set -gx NH_FLAKE $HOME/.config/home-manager
set -gx FLAKE $HOME/.config/home-manager # TODO:deprcated remove
set -gx VIRTUAL_ENV_DISABLE_PROMPT true

fish_add_path --global --move --append "$HOME/.bin"
fish_add_path --global --move --append "$HOME/.local/bin"
fish_add_path --global --move --append "$HOME/.nix-profile/bin"
fish_add_path --global --move --append "$HOME/.cargo/bin"
fish_add_path --global --move --append "$HOME/.local/share/JetBrains/Toolbox/bin"
fish_add_path --global --move --append "$HOME/.config/emacs/bin"
fish_add_path --global --move --append "/usr/local/bin"
fish_add_path --global --move --append "/nix/var/nix/profiles/default/bin"
fish_add_path --global --move --append "/usr/bin"
fish_add_path --global --move --append "/bin"

if status is-interactive
    # Commands to run in interactive sessions can go here

    # When a command is not found , fish emits a `fish_command_not_found` event passing
    # in the entire `$argv` of the attempted call to the missing command.
    # Enable this flag if you want to automatically try to run the command from nixpkgs
    # See implementation by running `funced fish_command_not_found`
    set -gx FISH_COMMAND_NOT_FOUND_AUTO_TRY_NIXPKGS true

    abbr --add suredo_last_history_item --position command --regex 'suredo' --function _suredo_abbr

    abbr --add vi_and_vim_to_neovim --position command --regex 'vim?' -- nvim
    abbr --add --position command -- edit '"$EDITOR"'
    abbr --add --position command -- ed '"$EDITOR"'

    abbr --add --position command -- ls eza
    abbr --add --position command -- ll 'eza --long'
    abbr --add --position command -- la 'eza --all'
    abbr --add --position command -- lla 'eza --long --all'
    abbr --add --position command -- tree 'eza --tree'

end

