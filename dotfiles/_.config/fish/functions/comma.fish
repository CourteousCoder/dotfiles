function comma --wraps='nix run nixpkgs#comma --' --description "runs a command if it's in path, otherwise from nixpkgs flake"
  if test ( count $argv ) -lt 1
    return $status
  end

  if command -q nix
     and not command -q $argv[1]

    nix --extra-experimental-features "nix-command flakes" --quiet run nixpkgs#comma -- $argv
  else
      $argv
  end   
end
