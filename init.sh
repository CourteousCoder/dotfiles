#!/usr/bin/env sh
set -e

# TODO: Do this the nix way.

REMOTE_REPO=github:CourteousCoder/dotfiles
LOCAL_FLAKE=~/.dotfiles

if ! command -v nix; then
  echo installing nix
  wget https://install.lix.systems/lix &&  sh ./lix -- install && rm ./lix
  #curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

test -d "$LOCAL_FLAKE" || nix flake clone "$REMOTE_REPO" --dest "$LOCAL_FLAKE"
cd "$LOCAL_FLAKE"
nix run nixpkgs#git -- pull 
nix run home-manager/master -- switch --flake .
