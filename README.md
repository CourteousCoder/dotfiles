# dotfiles

This my little automation of setting up my environment.

Originlly it was using just home-manager for everthing. Trying out a gnu stow for config files instead. I still use my nix home-manager flake for per-user package management.

## Install

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

## Contributing

This is just a fun little tinkering project for myself. There are probably way better ways of handling this, and that's okay with me.

If you _really_ want to contribute or share your opinion, go ahead and create an issue. I always welcome opportunities to improve!

## License
[MIT License](LICENSE)
