{
  pkgs,
  misc,
  ...
}: let
  username = "chloe";
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.git = {
    enable = true;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
      ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
    };
    userName = "Chloe Shetreet";
    userEmail = "CourteousCoder@gmail.com";
    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      gpg.format = "ssh";
    };

    signing = {
      key = "~/.ssh/id_ed25519";
      signByDefault = builtins.stringLength "~/.ssh/id_ed25519" > 0;
    };

    lfs.enable = true;
    ignores = [".direnv" "result"];
  };
}
