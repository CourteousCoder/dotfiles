DOTFILES := '~/.dotfiles'

default:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash just
    cd {{DOTFILES}}/stow
    just stow -R *

setup: default
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash just pre-commit
    pre-commit autoupdate
    pre-commit install
    git add .pre-commit-config.yaml
    cd {{DOTFILES}}/stow
    just stow -S fish git gnustow home-manager neovim *emacs
    just update

update: default
    #!/usr/bin/env nix-shell
    #!nix-shell -i fish
    #!nix-shell -p fish pre-commit
    set -gx PAGER cat
    set -gx EDITOR cat
    source ~/.bin/nixup

stow +PACKAGES:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash stow
    cd {{DOTFILES}}/stow
    stow --dotfiles --dir {{DOTFILES}}/stow --target ~ --adopt {{PACKAGES}}

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
