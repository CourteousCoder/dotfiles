default:
    #!/usr/bin/env sh
    cd stow
    just stow *

update-spacemacs:
	#!/usr/bin/env sh
	dir=spacemacs/dot-config/emacs
	mkdir -p "$dir"
	rm -r spacemacs/dot-config/emacs
	just _run git clone --depth 1 https://github.com/syl20bnr/spacemacs "$dir"
	just _run rm -rf "$dir/.git"

_run +ARGS:
	nix run nixpkgs#comma -- {{ARGS}}

stow +PACKAGES:
	just _run stow --dotfiles --dir ~/.dotfiles/stow --target ~ --stow {{PACKAGES}} --restow {{PACKAGES}}

essentials:
	just stow bash stow git fish home-manager 

