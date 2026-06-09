# dotfiles

My little automation for setting up my environment.

Everything is managed by a [Nix Home Manager](https://nix-community.github.io/home-manager/)
flake. Home Manager owns every dotfile: each config is an _out-of-store_ symlink from `~`
(or `~/.config`) into this repo, so files stay editable in place and edits are picked up
live — no copy into the Nix store, and no GNU Stow.

> This repo previously used GNU Stow for the dotfiles while keeping Home Manager for
> packages. It has since migrated back to pure Home Manager — see
> [`STOW-TO-HOME-MANAGER-MIGRATION.md`](STOW-TO-HOME-MANAGER-MIGRATION.md).

## Layout

- `flake.nix` / `flake.lock` — the Home Manager flake (per-host `homeConfigurations`).
- `home/` — the Home Manager modules (`home.nix`, `packages.nix`, …) plus `home/files.nix`,
  which imports every dotfile as an out-of-store symlink.
- `home/hosts/<host>/` — per-host config.
- `lib/dotfiles.nix` — the import helper (`dot-foo` → `.foo`, like Stow's `--dotfiles`).
- `config/` → `~/.config`, `home-files/` → `~/`, `home-bin/` → `~/.local/bin`,
  `themes/` → `~/.themes`, `icons/` → `~/.icons`.

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

`bootstrap.sh` installs Nix, then runs `just setup_dotfiles`, which installs the gitleaks
pre-commit hook and activates Home Manager.

## Day-to-day

- `just switch` — activate (`nh home switch ~/.dotfiles`).
- `just build` — build without activating.
- `just update` — update flake inputs and switch (runs `nixup`).

## Contributing

This is just a fun little tinkering project for myself. There are probably way better ways
of handling this, and that's okay with me.

If you _really_ want to contribute or share your opinion, go ahead and create an issue. I
always welcome opportunities to improve!

## License

[MIT License](LICENSE)
