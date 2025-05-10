DOTFILES := '~/.dotfiles'

default:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash stow
    stow -t ~ --dotfiles -R{{DOTFILES}}/stow

setup_precommit:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash pre-commit git
    pre-commit autoupdate
    pre-commit install
    git add .pre-commit-config.yaml

update:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash cat
    PAGER=cat EDITOR=cat ~/.bin/nixup

