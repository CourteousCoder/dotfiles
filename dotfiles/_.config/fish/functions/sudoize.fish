#!/usr/bin/env fish
function sudoize
	for command_name in $argv
		if alias | grep -q $command_name
			echo "WARNING: Skipping because alias already exists: $command_name"
			continue
		end
		set -l target sudo (which $command_name | xargs realpath -L)
		alias $command_name "$target"
	end
end
