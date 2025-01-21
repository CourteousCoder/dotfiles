set -u SHELL (which fish)
if status is-interactive
	set -gx EDITOR nvim
	    # Commands to run in interactive sessions can go here
	command -q thefuck 
	and thefuck --alias | source
	command -q uv 
	and uv generate-shell-completion fish | source
	command -q uvx 
	and uvx --generate-shell-completion fish | source

end

fish_add_path -g "$HOME/.local/share/JetBrains/Toolbox/bin"
