default:
    cd stow
    just stow -R --adopt * 

setup: default chemacs update

update: 
    just stow -R --adoot home-manager fish git neovim
    fish -c 'pkgup'

stow +PACKAGES:
    echo {{PACKAGES}}
    just _run stow --dotfiles --dir ~/.dotfiles/stow --target ~ {{PACKAGES}}


chemacs:
    #!/usr/bin/env sh
    # If we don't have a self-managed emacs config, then just get chemacs from git
    if ! [ -f stow/emacs/dot-config/emacs/init.el ]; then
        url='https://github.com/plexus/chemacs2.git'
        pkg=chemacs
        dir="dot-config/emacs"
        just get_contents_from_git "$url" "$pkg" "$dir"    \
            stow -R *emacs                                \
        ;
    fi

    # makes sure the shims work as expected
    # These shims are responsible for fetching the emacs profiles 
    # from git directly if not present so that we don't have
    # to deal with submodules in this repo yet still keep it an external
    # dependency the contents into this files. The downside is it impure
    emacs_version="$(just _run emacs --version)"
    [ "$(doom-emacs --version)" -eq "$emacs_version" ]
    [ $(spacemacs --version) -eq (emacs --version) ]


# Download just the contents of a git repo without keeping a clone of the version-controlled repo itself
get_contents_from_git URL PKG DIR:
    url={{URL}}
    pkg={{PKG}}
    dir={{DIR}}
    _path="$pkg/$dir"

    cd stow
    mkdir -p "$_path"

    just    (stow -D "$pkg")                        \
            (rm -r "$_path")                        \
            (git clone --depth 1 "$url" "$_path")   \
            (rm -rf "$_path/.git")                  \
            (stow "$pkg")

# Avoids any impure shell issues
rm +ARGS:
    just _run rm {{ARGS}}

git +ARGS:
    just _run git {{ARGS}}

# Run a command from nixpkgs even if not installed
_run +ARGS:
	nix run nixpkgs#comma -- {{ARGS}}
