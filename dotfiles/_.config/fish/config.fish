set -g SHELL (which fish)
if status is-interactive
	    # Commands to run in interactive sessions can go here
	command -v thefuck > /dev/null
	and thefuck --alias | source

	command -v uv > /dev/null
	and uv generate-shell-completion fish | source
	command -v uvx > /dev/null
	and uvx --generate-shell-completion fish | source

end

fish_add_path -g "$HOME/.local/share/JetBrains/Toolbox/bin"
