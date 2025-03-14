#!/usr/bin/env fish
set -gx SHELL (which fish)
set -gx EDITOR nvim
#set -gx VISUAL codium
set -gx FLAKE $HOME/.dotfiles
set -gx VIRTUAL_ENV_DISABLE_PROMPT true

if status is-interactive
	# Commands to run in interactive sessions can go here
	abbr -a -- edit '"$EDITOR"'
	abbr -a -- ed '"$EDITOR"'

	if command -q eza
		abbr -a -- ls eza
		abbr -a -- ll 'eza --long'
		abbr -a -- la 'eza --all'
		abbr -a -- lla 'eza --long --all'
		abbr -a -- tree 'eza --tree'
	else
		abbr -a -- ll 'ls --long'
		abbr -a -- la 'ls --all'
		abbr -a -- lla 'ls --long --all'
	end

	if command -q nvim 
		abbr -a -- vim nvim
		abbr -a -- vi nvim
	end

	command -q thefuck 
	and thefuck --alias | source

	command -q uv 
	and uv generate-shell-completion fish | source

	command -q uvx 
	and uvx --generate-shell-completion fish | source
end


fish_add_path --global --move --prepend "/bin"
fish_add_path --global --move --prepend "/usr/bin"
fish_add_path --global --move --prepend "/usr/local/bin"
fish_add_path --global --move --prepend "/nix/var/nix/profiles/default/bin"
fish_add_path --global --move --prepend "$HOME/.cargo/bin"
fish_add_path --global --move --prepend "$HOME/.local/share/JetBrains/Toolbox/bin"
fish_add_path --global --move --prepend "$HOME/.local/bin"
fish_add_path --global --move --prepend "$HOME/.nix-profile/bin"
fish_add_path --global --move --prepend "$HOME/.config/emacs/bin"
fish_add_path --global --move --prepend "$HOME/.bin"
