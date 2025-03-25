#!/usr/bin/env bash

this_script="$0"
this_hostname="${HOSTNAME:-common}"
this_user="$USER"

dotfiles_repo="$(dirname $this_script)"
nix_installer_base_plan='linux'

export FLAKE="${dotfiles_repo:-$HOME/.dotfiles}"
export NIX_INSTALLER_PLAN="$FLAKE/hosts/$this_hostname/nix-installer.plan.json"
export NIX_INSTALER_NO_CONFIRM=true
export NIX_INSTALLER_ENABLE_FLAKES=true
export NIX_INSTALLER_EXTRA_CONF='extra-trusted-users = "@wheel"'

main() {
	pushd "$FLAKE"

	if ! check_cmd nix; then

		# If installation exists but is broken, uninstall to perform a fresh reinstall
		if ! [ -x /nix/nix-installer ] && /nix/nix-installer repair && /nix/nix-installer self-check; then
			/nix/nix-installer uninstall
		fi

		# If no installation is present, make sure it gets installed
		if ! [ -x /nix/nix-installer ]; then
			ensure install_nix
		fi

		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi

	# Exit with an error if nix is still an unavailable command.
	need_cmd nix git

	git pull --all

	build_home_manager

	popd
}

build_home_manager() {
	#	rm -r $HOME/.local/state/home-manager/gcroots/current-home $HOME/.local/state/nix/profiles/home-manager*
	nix --quiet run nixpkgs#comma -- home-manager switch -b 'backup' --flake "${FLAKE}"
}

install_nix() {
	say Installing nix
	ensure download --check

	local _installer=$(mktemp nix-installer_tmp-XXXX.sh)
	say "	Fetching nix installer"

	if download 'https://install.lix.systems/lix' "$_installer"; then
		say "	Downloaded Lyx installer"
	elif download 'https://install.determinate.systems/nix' "$_installer"; then
		say "	Downloaded Determinate Systems installer"
	else
		rm "$_installer"
		err "	Could not download nix installer"
		return 1
	fi

	say "	Using installer plan: ${NIX_INSTALLER_PLAN}"
	_installer="$(realpath $_installer)"

	ensure chmod +x "$_installer"

	if [ ! -f "$NIX_INSTALLER_PLAN" ]; then
		warn "Installer plan not found. Creating new installer plan for $nix_installer_base_plan-based systems: $NIX_INSTALLER_PLAN"

		mkdir -p "$(dirname $NIX_INSTALLER_PLAN)"

		# TODO: Figure out why the Lyx installer didn't pick up the environment variable NIX_INSTALLER_EXTRA_CONF automatically
		ensure "$_installer" plan "$nix_installer_base_plan" | grep --perl-regexp '^(\s*[\{\[\]\}\,\:"0-9tnf])' | tee "$NIX_INSTALLER_PLAN"

		# Reclaim ownership of the directory ecause $_installer needs to run with root priviledges
		chown -R $this_user:$this_user "$FLAKE/hosts"
	fi

	ensure "$_installer" install "$NIX_INSTALLER_PLAN"
	rm "$_installer"
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
	if ! "$@"; then
		err "command failed: $*"
	fi
}

err() {
	say "$1" >&2
	exit 1
}

warn() {
	say "[warn]: $1" >&2
}

say() {
	printf "$0: %s\n" "$1"
}

main "$@"
