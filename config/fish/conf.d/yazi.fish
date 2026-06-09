if command -q yazi
	function __yazi-shell-wrapper
		set tmp (mktemp -t "yazi-cwd.XXXXXX")
		command yazi $argv --cwd-file="$tmp"
		if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
			builtin cd -- "$cwd"
		end
		rm -f -- "$tmp"
	end
	alias yazi=__yazi-shell-wrapper
end
