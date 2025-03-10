#!/usr/bin/env bash
set -e

this_script="$0"
export FLAKE="$(dirname "$this_script")"
export NIX_INSTALER_NO_CONFIRM="true"
export NIX_INSTALLER_ENABLE_FLAKES="true"
export NIX_INSTALLER_EXTRA_CONF='extra-trusted-users = "@wheel"'
main() {
	pushd "$FLAKE"

	if ! check_cmd nix; then
		install_nix
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi
	need_cmd nix git

	git pull --all
	nix --quiet run nixpkgs#comma -- home-manager switch --flake "${FLAKE}"
	popd
}


install_nix() {
	say Installing nix
	ensure download --check

	local _installer=$(mktemp nix-installer_tmp-XXXX.sh)
	say "	Fetching nix installer"

	if download 'https://install.lix.systems/lix' "$_installer"
	then 
		say "	Running Lyx installer"
	elif download 'https://install.determinate.systems/nix' "$_installer"
	then 
		say "	Running Determinate Systems installer"
	else 
		rm "$_installer"
		err "	Could not download nix installer"
		return 1
	fi

	chmod +x "$_installer"
	$(realpath $_installer) install
	rm $_installer
}



download() {
	local _url="$1"
	local _file="$2"
	local _downloader=""/
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
