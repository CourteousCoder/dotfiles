DOTFILES := '~/.dotfiles'

default: update
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash just
    cd {{DOTFILES}}/stow
    just stow -R *

setup: update chemacs default 

update: 
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash fish git home-manager just neovim nh
    cd {{DOTFILES}}/stow
    just stow -R  bash fish git gnustow home-manager neovim
    fish -c 'nixup'

stow +PACKAGES:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash stow
    cd {{DOTFILES}}/stow
    stow --dotfiles --dir {{DOTFILES}}/stow --target ~ --adopt {{PACKAGES}}


chemacs: update
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash emacs just
    # If we don't have a self-managed emacs config, then just get chemacs from git
    if ! [ -f stow/emacs/dot-config/emacs/init.el ]; then
        url='https://github.com/plexus/chemacs2.git'
        pkg=chemacs
        dir="dot-config/emacs"
        just get_contents_from_git "$url" "$pkg" "$dir"
        cd {{DOTFILES}}/stow
        just stow -R *emacs
    fi

    # makes sure the shims work as expected
    # These shims are responsible for fetching the emacs profiles 
    # from git directly if not present so that we don't have
    # to deal with submodules in this repo yet still keep it an external
    # dependency the contents into this files. The downside is it impure
    emacs_version="$(emacs --version)"
    [ "$(doom-emacs --version)" -eq "$emacs_version" ]
    [ $(spacemacs --version) -eq (emacs --version) ]


# Download just the contents of a git repo without keeping a clone of the version-controlled repo itself
get_contents_from_git URL PKG DIR:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash git just
    url={{URL}}
    pkg={{PKG}}
    dir={{DIR}}
    _path="$pkg/$dir"

    cd {{DOTFILES}}/stow
    mkdir -p "$_path"
    just stow -D "$pkg"                        
    rm -r "$_path"                       
    git clone --depth 1 "$url" "$_path"
    rm -rf "$_path/.git"                
    just stow "$pkg"
