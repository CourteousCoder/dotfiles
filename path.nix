{ pkgs, misc, ... }: {
# Untested
 
 home.sessionPath = [ 
    "$HOME/bin"
    "$HOME/.bin"
    "$HOME/.local/bin"
 ];
}
