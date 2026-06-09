# Yazi shell wrapper
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper

if command -v yazi > /dev/null; then
	function __yazi_shell-wrapper() {
		local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd < "$tmp"
		[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
		rm -f -- "$tmp"
	}
fi
alias yazi=__yazi_shell-wrapper
