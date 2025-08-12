#!/usr/bin/env fish
set -gx SHELL (which fish)

load_dotenv -I ~/.config/env/common.env

set -gx VISUAL $EDITOR
set -gx VIRTUAL_ENV_DISABLE_PROMPT true

for p in (cat ~/.config/env/path.list)
  set -l p (eval echo "$p")
  fish_add_path --global --prepend --path $p
end

if status is-interactive
    # Commands to run in interactive sessions can go here

    

    # When a command is not found , fish emits a `fish_command_not_found` event passing
    # in the entire `$argv` of the attempted call to the missing command.
    # Enable this flag if you want to automatically try to run the command from nixpkgs
    # See implementafish_user_pathstion by running `funced fish_command_not_found`
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
function remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -e fish_user_paths[$index]
    echo "Removed $argv from the path"
  end
end
