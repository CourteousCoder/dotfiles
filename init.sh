#!/usr/bin/env bash

this_script="$0"
export FLAKE="$(dirname "$this_script")"

main() {
	pushd "$FLAKE"

	if ! check_cmd nix; then
		say Installing nix

		# export NIX_INSTALLER_NO_CONFIRM=true
		export NIX_INSTALLER_ENABLE_FLAKES="true"
		export NIX_INSTALLER_EXTRA_CONF='extra-trusted-users = "@wheel"'

		install_nix_from 'https://install.lix.systems/lix' ||
			install_nix_from 'https://install.determinate.systems/nix' ||
			err "Coult not install nix"

		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi
	need_cmd nix

	run git pull --all
	run home-manager switch --flake
	popd
}

#runs a command if it's in path, otherwise run it from nixpkgs without installing it
run() {
	if [ check_cmd "$1" -o !check_cmd "nix" ]; then
		# If the command exists in path,  or if we don't even have nix as a fallback, then just run it as-is
		"$@"
	else
		# as a fallback, run the command from nixpkgs (via the comma flake) without installing it
		nix --extra-experimental-features "nix-command flakes" --quiet run nixpkgs#comma -- "$@"
	fi
}


install_nix_from() {
	local _url="$1"
	local _retval=true
	local _installer=$(mktemp tmp_nix-installer_XXXX.sh)
	ensure download --check

	say "\t trying installer from ${_url}"
	downloader "$1" "$_installer" || _retval=false
	chmod +x "$_installer"
	"$_installer" install || _retval=false
	rm "$_installer"
	return "$_retval"
}



download() {
	local _url="$1"
	local _file="$2"
	local _downloader=""
	if check_cmd curl; then
		_downloader=curl
	elif check_cmd wget; then
		_downloader=wget
	else
		_downloader='curl or wget' # to be used in error message of need_cmd
	fi

	if [ "$1" = --check ]; then
		need_cmd "$_downloader"
	elif [ "$_downloader" = 'curl' ]; then
		ensure curl --silent --show-error --fail --location "${_url}" --output "${_file}"
	elif [ "$_dld" = 'wget' ]; then
		ensure wget --https-only --secure-protocol=auto "$1" --output-document "$2"
	else
		need_cmd "$_downloader"
	fi
}

need_cmd() {
	if ! check_cmd "$1"; then
		err "need '$1' (command not found)"
	fi
}

check_cmd() {
	command -v "$1" >/dev/null 2>&1
}

# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure() {
	if ! "$@"; then err "command failed: $*"; fi
}

err() {
	say "$1" >&2
	exit 1
}

say() {
	printf "$0: %s\n" "$1"
}





main "$@"
