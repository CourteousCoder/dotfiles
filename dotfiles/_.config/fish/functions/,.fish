#!/usr/bin/env fish

function , --wraps='nix run nixpkgs#comma --' --description "runs a command if it's in path, otherwise from nixpkgs flake"
  if command -v $argv[1] > /dev/null
    $argv
  else 
    nix --quiet run nixpkgs#comma -- $argv
  end   
end
