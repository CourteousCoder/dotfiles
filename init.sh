#!/usr/bin/env bash

if which nix; then
  echo nix detected
else
  echo installing nix
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  source ~/.bashrc
fi


# clone repo
#nix run nixpkgs#git -- clone git@codeberg.org:CourteousCoder/dotfiles.git ~/dotfiles
echo running home-manager
nix run home-manager/master -- init --switch ~/dotfiles
