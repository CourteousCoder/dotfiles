DOTFILES := '~/.dotfiles'

set unstable := true

# Build the Home Manager generation without activating (verification, zero side effects).
build:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash home-manager
    home-manager build --flake {{ DOTFILES }}#chloe@$(hostname)

# Activate the Home Manager generation. The one and only activation path.
switch:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash nh
    nh home switch {{ DOTFILES }}

# First-time setup on a host: install the gitleaks pre-commit hook, then activate.
setup_dotfiles: setup_precommit switch

setup_precommit:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash pre-commit git
    pre-commit autoupdate
    pre-commit install
    git add .pre-commit-config.yaml

# Update flake inputs and switch (nixup does: flake update + nh switch + commit).
update:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash
    #!nix-shell -p bash uutils-coreutils-noprefix
    PAGER=cat EDITOR=cat ~/.local/bin/nixup
