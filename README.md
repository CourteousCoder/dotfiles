# dotfiles

This my little automation of setting up my environment, using gnu stow for symlinking config files and nix home-manager for installing per-user packages.

Originlly it was using just home-manager, which I had configured to setup symlinks similarly to how gnu stow does, but I found more flexibility having home-manager depend on stow than the other way around.

This is just a fun little tinkering project for myself. There are probably way better ways of handling this, and that's okay with me. If you _really_ want to contribute or share your opinion, go ahead and create an issue. I always welcome opportunities to improve!

## Intall

### Recklessly

```sh
curl -L https://codeberg.org/CourteousCoder/dotfiles/raw/branch/main/bootstrap.sh | sh -s
```

### Sanely

First:

```sh
SOURCE="git@codeberg.org:CourteousCoder/dotfiles.git"
DEST="$HOME/.dotfiles"
git clone "$SOURCE" "$DEST"

"$PAGER" "$DEST/bootstrap.sh"
```

Then inspect the script before you run it:


```sh
"$DEST/bootstrap.sh"
```

