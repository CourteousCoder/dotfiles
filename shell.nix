{ pkgs, misc, ... }: {
  programs.eza.extraOptions = [
   "--group-directories-first"
   "--header"
  ];
      
  programs.bat.config = {
      theme = "TwoDark";
  };
}
