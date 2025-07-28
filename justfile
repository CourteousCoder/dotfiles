DOTFILES := '~/.dotfiles'

default:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash just
    just stow --restow

setup_dotfiles: setup_precommit
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash just
    just stow --stow --adopt

setup_precommit:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash pre-commit git
    pre-commit autoupdate
    pre-commit install
    git add .pre-commit-config.yaml

update: default
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash uutils-coreutils-noprefix
    PAGER=cat EDITOR=cat ~/.bin/nixup

clean:
    #!/usr/bin/env nix-shell
    #!nix-shell -i zsh -p zsh just
    just stow --delete .
    pushd ~ > /dev/null
    rm -- **/*(-@D) || echo "And that's fine. You can safely ignore that."
    popd > /dev/null

stow *OPTS:
    #!/usr/bin/env nix-shell 
    #!nix-shell -i bash -p bash stow
    pushd {{DOTFILES}}/stow > /dev/null
    stow --target ~ --dir {{DOTFILES}} --dotfiles {{OPTS}} stow
    popd > /dev/null
