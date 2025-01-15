#!/usr/bin/env sh
set -e
set -v

if ! command -v nix; then
	echo installing nix
	export NIX_INSTALLER_ENABLE_FLAKES=true
	wget https://install.lix.systems/lix &&  sh ./lix -- install && rm ./lix
	#curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

git pull  --all
nix run home-manager/master -- switch --flake .

