{
  pkgs,
  misc,
  ...
}: {
  # Untested

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.bin"
    "$HOME/.local/bin"
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/games"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/games"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  ];
}
