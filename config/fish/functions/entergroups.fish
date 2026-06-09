# Defined via `source`
function entergroups --description 'Add the current use to the given groups, creating any that are missing, and activate them in this shell'
	argparse --name entergroups -N 1 'h/help' 'n/dry-run' -- $argv

	if set -q _flag_help
		printf 'Usage:%n%t%s [-n | --dry-run ] GROUPS[ GROUPS[ ...]]%n' (status current-command) >&2
		return 1
	end

	function _ifwet --no-scope-shadowing -d "When it's a dry run, set alias _ifwet to write commands to stderr instead of running them."
		set -q _flag_dry_run
		and echo '[DRYRUN]: ' $argv
		or $argv
	end

	# $new_groups is $argv, but without the groups that $USER is already a member of
	set -l new_groups (comm -23 (string split ' ' $argv | sort -u | psub) (id -Gn | string split ' ' | sort -u | psub))
	
	# Add any of the $new_groups that dont already exist
	for group in $new_groups
		_ifwet sudo groupadd $group
		and echo "Created group:" $group
	end

	# Assign the user to the new_groups, if any.
	if set -q new_groups[1]
		set -l new_groups (string join ',' $new_groups)
		_ifwet sudo usermod -aG $new_groups $USER
		and _ifwet sudo su -ls $SHELL $USER && exit
	end

end
