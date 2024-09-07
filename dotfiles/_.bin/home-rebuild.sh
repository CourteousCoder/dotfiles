#!/usr/bin/env bash

set -e

export EDITOR=${EDITOR:-lvim}
dotfiles=~/.dotfiles

pushd "$dotfiles"

home-manager edit
git diff -U0 *.nix

echo "Rebuilding Nix home manager..."
nh home switch "$dotfiles" &>nh-home-switch.log || (
  cat nh-home-switch.log | grep --color error && false)

gen="$(home-manager generations | head -n 1)"
git commit -am "$gen"

popd
