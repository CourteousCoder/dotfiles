function loadenv --description "Load and export variables from the given .env file(s)"
	set -l thisfunc (status function)
	argparse 'h/help' -- $argv
	or return
	if set -q _flag_help
		printf 'usage: %s [-h | --help] FILE [...FILES]\n' "$thisfunc"
		return
	else if test (count $argv) = 0
		echo "$thisfunc: at least one FILE must be given" > /dev/stderr
		return 1
	end

	sed -Ee '/^(export|[ \t]*#)/! s/^[^=]+=/export &/' $argv | source
end
