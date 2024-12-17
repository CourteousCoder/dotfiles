if status is-interactive
    # Commands to run in interactive sessions can go here
end

command -v thefuck
and thefuck --alias | source

command -v uv
and uv generate-shell-completion fish | source
command -v uvx
and uvx --generate-shell-completion fish | source

fish_add_path -gx "$HOME/.local/share/JetBrains/Toolbox/bin"
