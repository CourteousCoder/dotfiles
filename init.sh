#!/usr/bin/env sh

# Provides: check_cmd, ensure, err, need_cmd, runn, say
. ./dotfiles/_.local/lib/script-utils/common.sh

main() {
	if ! check_cmd nix; then
		say Installing nix

		# export NIX_INSTALLER_NO_CONFIRM=true
		export NIX_INSTALLER_ENABLE_FLAKES=true
		export NIX_INSTALLER_EXTRA_CONF='extra-trusted-users = "@wheel"'

		install_nix_from 'https://install.lix.systems/lix' || install_nix_from 'https://install.determinate.systems/nix' || err "Coult not install nix"

		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi

	need_cmd nix

	runn git pull --all
	runn home-manager switch --flake .
}

install_nix_from() {
	local _retval=true
	local _installer=$(mktemp tmp_nix-installer_XXXX.sh)
	ensure downloader --check

	say "\t trying installer from $1"
	downloader "$1" "$_installer" || _retval=false
	chmod +x "$_installer"
	"$_installer" install || _retval=false
	rm "$_installer"
	return "$_retval"
}

main "$@"