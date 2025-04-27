#!/usr/bin/env -S nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#fish nixpkgs#uutils-coreutils-noprefix nixpkgs#curl nixpkgs#jq nixpkgs#redshift --command fish
curl ipinfo.io | jq .loc | string replace ',' ':' | string trim -c '"' | xargs redshift -l
