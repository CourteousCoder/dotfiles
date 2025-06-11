#!/usr/bin/env fish
function sudoize
	for command_name in $argv
		if alias | grep -q $command_name
			echo "WARNING: Skipping because alias already exists: $command_name"
		else if command -q $command_name
			set -l target sudo (which $command_name | xargs realpath -L)
			alias $command_name "$target"
		else
			echo "WARNING: Skipping because command not found: $command_name"
		end
	end
end
