{ pkgs, misc, ... }: {
   # Might be broken

   home.shellAliases = {
    # bat --plain for unformatted cat
    catp = "bat -P";
    ls = "eza";
    # replace cat with bat
    cat = "bat";
    e = "$EDITOR";
  };
}
