# Migration: GNU Stow → Pure Nix Home Manager

## Context

`~/.dotfiles` is a hybrid: **GNU Stow** symlinks ~6,131 config files into `$HOME`, while a
**Nix Home Manager** flake (living *inside* the stow tree at `stow/dot-config/home-manager/`)
manages packages + a few `programs.*`. The README notes it "originally used home-manager for
everything" before "trying out gnu stow" — this migration reverts to that original intent:
**remove Stow entirely, let Home Manager own every dotfile.** Outcome = one activation path
(`nh home switch`), one source of truth, no `--dotfiles` symlink wrapper.

### Decisions (chosen)

| Decision | Choice |
|---|---|
| Import mechanism | **Out-of-store symlink** (`config.lib.file.mkOutOfStoreSymlink`) — mutable, stow-equivalent, no store bloat. The base mechanism for the whole migration. |
| Native modules | **Maximal native — but DEFERRED.** Get 100% off stow first with pure symlinks (Phases 0–3), then convert tools to `programs.*` as a separate, final Phase 4. This isolates the risky/large rewrites (fish, neovim) from the stow removal so the two never compound. |
| Emacs distros | **Drop both vendored** doomemacs (5.8M) + spacemacs (25M); clone on demand into `~/.local/share/`. Keep chemacs2 + `emacs/` config. |
| Rollout | **Incremental**, `just stow --restow` kept working as rollback through stow removal (end of Phase 3). |

**Why defer native conversion:** native conversion of fish (~8 plugins + 93 functions) and
neovim (kickstart, 33 lazy.nvim plugins) are large, error-prone rewrites. Doing them *after*
stow is gone means: (a) stow removal is a clean, mechanical, fully-reversible change; (b) each
native conversion is then an isolated diff whose rollback is just `git revert` + `nh switch`
(reverts that one tool back to its symlink), with no stow interaction. WM configs, themes,
scripts, and secret-bearing files (`gh/hosts.yml`, `glab-cli`) stay out-of-store symlinks
permanently — no good native module / must stay mutable — and are never part of Phase 4.

---

## Target repo layout

```
~/.dotfiles/
├── flake.nix              # promoted from stow/dot-config/home-manager/flake.nix (paths repointed)
├── flake.lock            # promoted; drop flake.lock.maybe / flake.lock2 / flake.nix.maybe
├── justfile              # stow recipes removed, hm/nh recipes added
├── bootstrap.sh          # nix-only; calls HM switch instead of stow
├── README.md  LICENSE  .pre-commit-config.yaml  .gitignore
├── lib/
│   └── dotfiles.nix      # NEW: undot + mkOutOfStoreTree helpers
├── home/                 # was stow/dot-config/home-manager/*.nix
│   ├── home.nix path.nix shell.nix aliases.nix programs.nix packages.nix user.nix
│   ├── files.nix         # NEW: the dotfile-import module
│   └── hosts/{qweenkpad,ombre}/{chloe.nix,custom.nix}
├── config/               # was stow/dot-config/* (no dot- prefix; → ~/.config/*)
│   ├── fish/ nvim/ hypr/ sway/ waybar/ rofi/ kitty/ tmux/ git/ gh/ emacs/ ...
│   └── (doomemacs/ spacemacs/  → DELETED)
├── home-files/           # was top-level dot-* (→ ~/.foo): bashrc zshrc xonshrc Xresources dunstrc elvish/
├── home-bin/             # was dot-local/bin (8 scripts incl. nixup/nixeh → ~/.local/bin)
├── themes/               # was dot-themes (→ ~/.themes); keeps 188 internal symlinks
└── icons/                # was dot-icons (→ ~/.icons)
```

Drop the stray nested `elvish/dot-elvish/` duplicate and `stow/dot-stowrc` (the `--dotfiles`
rename is now done by the `undot` helper).

---

## The import helper (`lib/dotfiles.nix`)

Reusable — avoids hand-listing 56 dirs, reproduces stow's `dot-foo`→`.foo` rename, and keeps
the working tree (so the 188 internal theme/waybar symlinks resolve unchanged).

```nix
{ lib, config }:
let
  home = config.home.homeDirectory;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  undot = name: if lib.hasPrefix "dot-" name
    then "." + lib.removePrefix "dot-" name else name;
  # One mutable symlink per immediate child of `src`, applying the dot- rename.
  # `exclude` = list of dest names natively managed elsewhere (skip them).
  mkOutOfStoreTree = { src, repoSub, destPrefix ? "", exclude ? [] }:
    lib.mapAttrs'
      (name: _: lib.nameValuePair (destPrefix + undot name)
        { source = mkOutOfStoreSymlink "${home}/.dotfiles/${repoSub}/${name}"; })
      (lib.filterAttrs (name: _: !(lib.elem (destPrefix + undot name) exclude))
        (builtins.readDir src));
in { inherit undot mkOutOfStoreTree mkOutOfStoreSymlink; }
```

`home/files.nix` consumes it. `nativelyManaged` starts **empty** through Phases 0–3 (pure
symlink mirror of stow). It only grows in Phase 4, where converting a tool adds its name here
(removing its symlink) the same commit the `programs.*` module is enabled — so symlink and
module never collide:

```nix
{ config, lib, ... }:
let
  dots = import ../lib/dotfiles.nix { inherit lib config; };
  nativelyManaged = [ ];   # Phase 4 only: add "git" "fish" "nvim" ... as converted
in {
  xdg.configFile = dots.mkOutOfStoreTree {
    src = ../config; repoSub = "config"; exclude = nativelyManaged;
  };
  home.file =
    dots.mkOutOfStoreTree { src = ../home-files; repoSub = "home-files"; }      # → ~/.foo
    // dots.mkOutOfStoreTree { src = ../home-bin;  repoSub = "home-bin";
                               destPrefix = ".local/bin/"; };
  home.file.".themes".source = dots.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/themes";
  home.file.".icons".source  = dots.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/icons";
}
```

---

## Phases

> Phases 0–3 take you completely off Stow using pure out-of-store symlinks. Native `programs.*`
> conversion is deferred to Phase 4, after Stow is gone, to keep that risk isolated.

### Phase 0 — Restructure (no behavior change)
- Promote `stow/dot-config/home-manager/{flake.nix,flake.lock,*.nix,hosts/}` → repo root `flake.nix` + `home/`.
- Add `lib/dotfiles.nix` and an **empty** `home/files.nix` (`xdg.configFile = {}`), wire it into both `modules = [ ... ]` lists in `flake.nix`.
- `home/home.nix`: uncomment `myHomeManagerFlake = "${homeDirectory}/.dotfiles"`, delete the `~/.config/home-manager` line and the "using gnu stow instead" comment.
- Point `$FLAKE` default to `~/.dotfiles` in `home-bin/nixup` and `home-bin/nixeh` (still stow-managed this phase; edit in `stow/dot-local/bin/`).
- Keep `stow/` intact and still active. **Gate:** `home-manager build --flake ~/.dotfiles#chloe@qweenkpad` succeeds. Commit.

### Phase 1 — Bring up HM out-of-store import (the cutover)
- Move payload out of stow: `stow/dot-config/*`→`config/`, `dot-themes`→`themes/`, `dot-icons`→`icons/`, `dot-local/bin`→`home-bin/`, top-level `dot-*`→`home-files/`. (`config/home-manager/` is gone — already promoted in P0.)
- Fill `home/files.nix` using the helper (above), `nativelyManaged = []` (pure symlink mirror of stow).
- **Cutover** (per host, see sequence below): `stow --delete` then `nh home switch`. Because it's a single stow package, removing the old links is one step — this is the one unavoidable all-at-once moment.
- **Gate:** symlink diff shows targets moving `~/.dotfiles/stow/...` → `~/.dotfiles/config/...`; no broken links (`find ~ -xtype l` empty); fish/nvim/waybar/gh all still resolve. Commit.

### Phase 2 — Drop emacs distros, clone-on-demand
- `git rm -r config/doomemacs config/spacemacs`.
- Keep `config/emacs/` (chemacs2) and the `home-bin/{doomemacs,spacemacs}` launchers (they already exec with `~/.local/share/{doomemacs,spacemacs}` profiles).
- Add an idempotent `home.activation` script (or bootstrap step) that, only if absent, `git clone`s doomemacs into `~/.local/share/doomemacs` (+ optional spacemacs) and notes that `doom sync` is run by the user. **Verify chemacs2 `profiles.el` actually points at `~/.local/share/<x>`** — reconcile if the live path differs.
- Repoint stale `.gitignore` entries (`stow/emacs/dot-config/spacemacs/...`, `stow/pianobar/...`) to real paths or drop. Commit.

### Phase 3 — Cleanup & remove Stow
- `justfile`: delete `stow`, `default`, `clean`, and the `just stow` line in `setup_dotfiles`. Add `switch` (`nh home switch ~/.dotfiles`) and `build`. Keep `setup_precommit`, `update`.
- `bootstrap.sh`: replace the `nix run … -- setup` → stow path with `home-manager switch --flake "$DOTFILES#chloe@$(hostname)"` (or a flake `apps.setup`).
- Delete: `flake.nix.maybe`, `flake.lock.maybe`, `flake.lock2`, `nh-home-switch.log`, `TMPDIR/`, `nix-installer.plan.json*`, empty `modules/common.nix` (or repurpose as the shared module).
- Remove the remaining `stow/` scaffolding **last** — keep `just stow --restow` working as the rollback until both hosts are verified on HM, then delete.
- **Milestone:** fully off Stow. Everything is HM-managed out-of-store symlinks; activation is `nh home switch` only. This is a safe stopping point — Phase 4 is optional/independent.

### Phase 4 — Native module conversion (deferred; after Stow is gone)
Now that Stow is removed, convert tools to `programs.*` one at a time. Each conversion is an
isolated commit: add the tool to `nativelyManaged` (drops its symlink) **and** enable its module
in the same change. Rollback for any tool = `git revert` that commit + `nh switch` (returns it to
the symlink). No stow interaction.
1. **git** — finish `programs.git` (already half-built per-host in `hosts/*/chloe.nix`; ombre enabled w/ SSH signing, qweenkpad disabled). Delete `config/git/`.
2. **Small static**: `tmux`, `kitty`, `bat` (already partly), `starship` (port `starship.toml`→`programs.starship.settings` or keep file). Low risk.
3. **fish** (large): `programs.fish` — move `config.fish` init → `interactiveShellInit`, abbreviations → `shellAbbrs`, plugins → `programs.fish.plugins` mapped to `pkgs.fishPlugins.*` / `fetchFromGitHub` (tide, abbr_tips, autopair, sponge, puffer-fish, halostatue-fish-haskell, dotenv, sdkman-for-fish). Drop fisher + `fish_plugins`. Port user functions (subset of the 93; the `_tide_*` ones are plugin-provided). Do on its own branch — fisher/tide parity is the risk; the live symlinked config keeps working until merged.
4. **neovim** (largest): `programs.neovim` with plugins from `pkgs.vimPlugins`, `extraLuaConfig` sourcing the existing kickstart lua. Drop lazy.nvim + `lazy-lock.json`. Map the 33 plugins. Highest-effort, highest-risk — do last, on its own branch.

Stay-symlinked permanently (never converted): WM configs (hypr/sway/i3/waybar/rofi/dunst/wlogout),
themes, icons, scripts, and **secret-bearing** `gh`/`glab-cli` (`programs.gh` would clobber the
OAuth `hosts.yml`).

---

## Cutover sequence & collision handling (Phase 1, per host)

HM `home.file`/`xdg.configFile` abort rather than clobber an existing non-HM file; Stow owns those
paths today. Remove stow links first; HM's backup (`-b`/`-ub <ext>`) is the safety net for stray
real files.

```sh
# 0. pre-flight (read-only)
just stow --no --verbose=2                                   # dry-run: list links stow owns
home-manager build --flake ~/.dotfiles#chloe@$(hostname)    # evaluate, no activation
find ~ -maxdepth 4 -type l -printf '%p -> %l\n' | sort > /tmp/before.txt

# 1. drop stow's links, then activate HM (backup catches leftovers)
just stow --delete                                          # removes only links stow owns
nh home switch -ub ".pre-hm.bak" ~/.dotfiles               # = home-manager switch --flake .#chloe@$(hostname) -b pre-hm.bak

# 2. verify
find ~ -maxdepth 4 -type l -printf '%p -> %l\n' | sort > /tmp/after.txt
diff /tmp/before.txt /tmp/after.txt                        # targets: stow/... → config/...
find ~ -maxdepth 4 -xtype l                                # broken links → must be empty

# rollback at any point: home-manager generations; <prev>/activate ; just stow --restow
```

Do **qweenkpad first** (richer host, has nix-index module), then **ombre**. Neither host's stow
scaffolding is deleted until both reach a clean HM generation.

---

## Verification

- After every phase: `home-manager build --flake ~/.dotfiles#chloe@<host>` (zero side effects) + `nh home switch --dry`.
- Symlink diff before/after (above); `find ~ -xtype l` empty.
- App smoke tests: fish (plugins/abbrs/tide prompt intact), nvim (`:Lazy`/plugins load), `gh auth status` (token survived), waybar (config symlink resolves), GTK theme switch (themes assets resolve), `doom sync` after clone-on-demand.
- Rollback drill before trusting (through Phase 3): activate previous generation → `just stow --restow` → confirm old world restored. In Phase 4: `git revert` the conversion commit → `nh switch` restores that tool's symlink.

---

## Critical files to modify / create

- **Create** `/home/chloe/.dotfiles/lib/dotfiles.nix` (undot + mkOutOfStoreTree helper)
- **Create** `/home/chloe/.dotfiles/home/files.nix` (import module)
- **Promote + repoint** `stow/dot-config/home-manager/flake.nix` → `/home/chloe/.dotfiles/flake.nix` (module paths; keep flox/snowfall — `packages.nix` uses `snowfallorg.flakes`)
- **Edit** `home/home.nix` (`myHomeManagerFlake = ~/.dotfiles`; drop stow comment) and add `./files.nix` to both `modules` lists in `flake.nix`
- **Edit** `/home/chloe/.dotfiles/justfile` (remove stow recipes; add hm/nh)
- **Edit** `/home/chloe/.dotfiles/bootstrap.sh` (HM switch instead of stow)
- **Edit** `stow/dot-local/bin/{nixup,nixeh}` (`$FLAKE` default → `~/.dotfiles`)
- **Move** payload trees; **delete** `config/{doomemacs,spacemacs}`, `flake*.maybe`, stray `elvish/dot-elvish/`, stow scaffolding (last)
- **Phase 4 only** (one commit per tool): `home/programs.nix` / new `programs.*` modules + add tool to `nativelyManaged` in `home/files.nix`; delete the converted tool's `config/<tool>/`

## Open edge items to confirm during execution
- chemacs2 `profiles.el` actual load paths vs the `~/.local/share/<x>` launchers (Phase 2).
- fish native parity for tide + the 8 plugins is the main risk — Phase 4, on a branch; live symlinked config stays until merged.
- `home.file` does not preserve internal relative symlinks under store-copy — non-issue here since everything is out-of-store, but do not switch themes/waybar to store-copy.
