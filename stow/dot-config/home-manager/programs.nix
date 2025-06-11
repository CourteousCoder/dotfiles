{
  pkgs,
  misc,
  ...
}: {
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.atuin.enable = true;
  programs.zoxide.enable = true;
  programs.direnv.enable = true;
  #  programs.starship.enable = true;
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };
  programs.dircolors.enable = true;
}
