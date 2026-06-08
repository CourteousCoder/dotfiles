# Migration: GNU Stow → Pure Nix Home Manager

## Context

`~/.dotfiles` is a hybrid: **GNU Stow** symlinks ~3,725 config files (+188 internal symlinks)
into `$HOME`, while a **Nix Home Manager** flake (living *inside* the stow tree at
`stow/dot-config/home-manager/`) manages packages + a few `programs.*`. The README notes it
"originally used home-manager for everything" before "trying out gnu stow" — this migration
reverts to that original intent: **remove Stow entirely, let Home Manager own every dotfile.**
Outcome = one activation path (`nh home switch`), one source of truth, no `--dotfiles` symlink
wrapper.

> **Audit corrections (2026-06-08).** This draft was reconciled against the live repo. Key
> changes from the prior version: (1) **Phase 2 deleted** — emacs/doomemacs/spacemacs/chemacs2
> and their launchers are already gone (commits `45e17c0`, `d0fadca`); only stale `.gitignore`
> lines remain, folded into Phase 3. (2) **Phase 1 `git mv`s** the payload and removes `stow/`;
> rollback is the **git tag `pre-hm-migration`** plus re-activation, not a retained `stow/` copy.
> The per-host rule — `stow --delete` *before* pulling P1 — avoids the ordering trap (git rolls
> back the repo, not the live `$HOME` symlinks, so re-activation is always part of rollback).
> (3) `home-files/` entries **keep their `dot-` prefix** (the helper
> only adds the leading dot when one is present). (4) The `$FLAKE`/`NH_FLAKE` repoint covers
> **four** files, not two. (5) Helper now filters hidden + empty entries. (6) The flake
> **evaluates today** (verified: `nix eval …activationPackage.drvPath` succeeds) despite the
> undeclared `misc`/`unstable`/`home` module args — promote modules verbatim.

### Decisions (chosen)

| Decision | Choice |
|---|---|
| Import mechanism | **Out-of-store symlink** (`config.lib.file.mkOutOfStoreSymlink`) — mutable, stow-equivalent, no store bloat. The base mechanism for the whole migration. |
| Native modules | **Maximal native — but DEFERRED.** Get 100% off stow first with pure symlinks (Phases 0–3), then convert tools to `programs.*` as a separate, final Phase 4. This isolates the risky/large rewrites (fish, neovim) from the stow removal so the two never compound. |
| Emacs distros | **Already removed** (`45e17c0` removed all emacs configs, `d0fadca` removed the doom/spacemacs/chemacs2 bins). No action needed beyond pruning dead `.gitignore` lines (Phase 3). |
| Restructure style | **`git mv`, not copy** (Phase 1) — single source of truth, preserves history, no duplicated tree. `stow/` is removed in P1. |
| Rollback anchor | **Git tag `pre-hm-migration`** + HM generations. Git restores the *repo* (brings `stow/` back); re-activation restores the *live `$HOME`* (`nh` prior generation → `just stow --restow`). HM's `-b` backup is the net for the live layer. |
| Rollout | **Incremental, per host.** Each host stays on the pre-P1 commit (stow/ intact, fully working) until it cuts over; no shared stale tree to drift. |

**Why defer native conversion:** native conversion of fish (~8 plugins + 93 functions) and
neovim (kickstart, 33 lazy.nvim plugins) are large, error-prone rewrites. Doing them *after*
stow is gone means: (a) stow removal is a clean, mechanical, fully-reversible change; (b) each
native conversion is then an isolated diff whose rollback is just `git revert` + `nh switch`
(reverts that one tool back to its symlink), with no stow interaction. WM configs, themes,
scripts, and secret-bearing files (`gh/hosts.yml`, `glab-cli`) stay out-of-store symlinks
permanently — no good native module / must stay mutable — and are never part of Phase 4. (Mutable ≠
commit-safe; see **Security invariants** below for the `.gitignore`/gitleaks side of those files.)

---

## Security invariants (secret handling)

> **A symlink is not commit-safe.** Every dotfile here is an *out-of-store* symlink: the live file
> under `$HOME` and the file in the git working tree are the **same inode**. Keeping a
> secret-bearing file "symlinked, never natively managed" protects it from being *clobbered* by a
> `programs.*` module — it does **nothing** to stop the secret from being **committed**. Runtime
> writes (a `gh` token, fish universal vars, shell history) land directly in the tracked tree.
> Commit-safety comes only from `.gitignore` + the gitleaks pre-commit hook, both of which must
> survive the restructure intact.

Audited 2026-06-08 — three exposures the bare plan left open, each closed in the phase noted:

1. **`config/gh/hosts.yml` and `config/glab-cli/aliases.yml` are *tracked* and *not ignored*.**
   Today `hosts.yml` uses `git_protocol: ssh` and carries **no** `oauth_token`, so nothing leaks
   *now* — but the file is tracked: the next `gh auth login` over https (or a token refresh) writes
   an `oauth_token`/`gho_…` straight into it and the following commit ships it. gitleaks may not
   match every config-embedded token, so do not rely on it alone. **Fix (Phase 1 commit):**
   `git rm --cached config/gh/hosts.yml config/glab-cli/aliases.yml` and add both to `.gitignore`.
   The on-disk files remain (they are symlink targets); gh/glab keep working; future token writes
   are now ignored; a fresh clone simply re-auths.

2. **Six nested, path-relative `.gitignore` files must move *intact* with their dirs** — they are
   the only guard on runtime secrets written into the tree:
   - `config/fish/.gitignore` → `fish_history`, `fish_variables`, `config.local.fish`
     (**history and universal vars routinely contain tokens**), `fishd.*`
   - `config/fish/completions/.gitignore` → `gitleaks.fish`
   - `config/nvim/.gitignore`, `config/ml4w/.gitignore` (`**/cache/`),
     `config/qtile/.gitignore`, `config/home-manager/.gitignore`
   `git mv` of each parent dir carries its `.gitignore` automatically. **Do NOT** consolidate these
   into the root `.gitignore` (the patterns are dir-relative and would stop matching) and **do NOT**
   delete them. The helper's hidden-entry filter keeps a top-level `.gitignore` from becoming a
   `~/.config/.gitignore` symlink; the nested ones sit under already-symlinked dirs and are
   unaffected.

3. **The gitleaks pre-commit hook is *not* version-controlled.** It lives in local
   `.git/hooks/pre-commit`, installed by `just setup_precommit` (`pre-commit install`). qweenkpad
   has it; **a fresh host (ombre) has no hook, hence no secret scanning at all.** The Phase 3
   `bootstrap.sh` rewrite must still run `pre-commit install` (keep the `setup_precommit` dependency
   or call it directly) — replacing the `just … setup` path with a bare `home-manager switch`
   silently removes the only automated guard on a new host.

**Invariant to verify after every cutover:** `git status --porcelain` immediately after first
launching fish / gh / nvim shows **no** `fish_history`, `fish_variables`, `hosts.yml`, or other
runtime secret as newly-tracked. Gate the P1 commit on `pre-commit run gitleaks --all-files` over
the moved tree.

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
├── config/               # was stow/dot-config/* (NO dot- prefix; xdg.configFile prepends ~/.config)
│   ├── fish/ nvim/ hypr/ sway/ waybar/ rofi/ kitty/ tmux/ git/ gh/ ...
│   └── (home-manager/  → promoted to home/ in P0; not present here)
├── home-files/           # KEEP dot- prefix (home.file needs the leading dot):
│   │                     #   dot-bashrc dot-zshrc dot-xonshrc dot-Xresources dot-dunstrc dot-elvish/
├── home-bin/             # was dot-local/bin (6 scripts: mkcd nixeh nixup pkgsup ptouch redshift.fish → ~/.local/bin)
├── themes/               # was dot-themes (→ ~/.themes); keeps 186 internal symlinks
└── icons/                # was dot-icons (→ ~/.icons)
```

> **Naming asymmetry (intentional).** `config/` children have **no** `dot-` prefix because
> `xdg.configFile.<name>` already targets `~/.config/<name>` — a leading dot would give
> `~/.config/.fish`. `home-files/` children **keep** the `dot-` prefix because `home.file` maps
> to `~/<name>` and the helper's `undot` turns `dot-bashrc` → `.bashrc` → `~/.bashrc`. Stripping
> the prefix in `home-files/` would land files at `~/bashrc`.

Drop the stray nested `stow/elvish/dot-elvish/` duplicate, `stow/dot-stowrc`, and the
non-dotfile cruft `stow/hooks_base.bash` + `stow/xed.dconf` (stow currently links the latter two
to `~/hooks_base.bash`, `~/xed.dconf`). The `--dotfiles` rename is now done by the `undot` helper.

---

## The import helper (`lib/dotfiles.nix`)

Reusable — avoids hand-listing the ~58 config dirs, reproduces stow's `dot-foo`→`.foo` rename,
and keeps the working tree (so the 186 internal theme + 2 waybar symlinks resolve unchanged).
It filters hidden entries (so `config/.gitignore` does not become `~/.config/.gitignore`) and
empty directories (defensive — empty dirs are not git-tracked, so they normally never reach the
flake store anyway).

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
      (lib.filterAttrs (name: type:
          !(lib.hasPrefix "." name)                                          # skip .gitignore & hidden
          && !(type == "directory" && builtins.readDir (src + "/${name}") == {})  # skip empty dirs
          && !(lib.elem (destPrefix + undot name) exclude))
        (builtins.readDir src));
in { inherit undot mkOutOfStoreTree mkOutOfStoreSymlink; }
```

> **Eval-time note.** `builtins.readDir src` reads the **flake store copy** of the tree, which
> contains only git-**tracked** files (no empty dirs, no untracked files). Adding a new
> top-level `config/<x>` therefore requires `git add` + a re-switch before its symlink appears —
> a behavior change from stow, which stowed untracked files too. (Files added *inside* an
> already-symlinked dir appear live, since the symlink points at the working tree.)

`home/files.nix` consumes it. `nativelyManaged` starts **empty** through Phases 0–3 (pure
symlink mirror of stow) and only grows in Phase 4. **Audit rule:** any `config/<x>` that a
currently-enabled `programs.*` *also* writes must be added to `nativelyManaged` (or its dir
removed) in the same commit, or the two collide. Audited 2026-06-08: the enabled modules
(`eza bat atuin zoxide direnv starship dircolors`) are clean — `config/bat` is empty (untracked,
never reaches the flake), `programs.starship.settings = {}` writes no file, and none of the
others have a matching `config/<x>`. So `nativelyManaged = []` is correct for now.

```nix
{ config, lib, ... }:
let
  dots = import ../lib/dotfiles.nix { inherit lib config; };
  nativelyManaged = [ ];   # Phase 4 only: add "git" "fish" "nvim" ... as converted (see audit rule above)
in {
  xdg.configFile = dots.mkOutOfStoreTree {
    src = ../config; repoSub = "config"; exclude = nativelyManaged;
  };
  home.file =
    dots.mkOutOfStoreTree { src = ../home-files; repoSub = "home-files"; }      # dot-bashrc → ~/.bashrc
    // dots.mkOutOfStoreTree { src = ../home-bin;  repoSub = "home-bin";
                               destPrefix = ".local/bin/"; };                   # → ~/.local/bin/<script>
  home.file.".themes".source = dots.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/themes";
  home.file.".icons".source  = dots.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/icons";
}
```

---

## Phases

> Phases 0–3 take you completely off Stow using pure out-of-store symlinks. Native `programs.*`
> conversion is deferred to Phase 4, after Stow is gone, to keep that risk isolated.

### Phase 0 — Restructure the flake (no behavior change)
- Promote `stow/dot-config/home-manager/{flake.nix,flake.lock,*.nix,hosts/}` → repo root `flake.nix` + `home/`.
  - **Repoint** the relative module paths in `flake.nix` (`./home.nix` → `./home/home.nix`, etc.) in **both** `modules = [ ... ]` lists.
  - Promote the modules **verbatim** — do NOT "tidy" the unused `misc`/`unstable`/`home` function args. They are declared but never used in the bodies; the flake nonetheless evaluates today (verified), and changing the signatures risks an eval change. They can be removed later as a separate, individually-verified step.
- Add `lib/dotfiles.nix` and an **empty** `home/files.nix` (`xdg.configFile = {}`), wire `./home/files.nix` into both `modules` lists.
- `home/home.nix`: delete the stale "but I'm using gnu stow instead" comment. (Note: the `myHomeManagerFlake` let-binding is dead — defined, never referenced — so editing it is cosmetic; the real flake-path control is `NH_FLAKE`, handled in Phase 1.)
- **Gate:** `home-manager build --flake ~/.dotfiles#chloe@qweenkpad` succeeds (matches the verified baseline). Commit. `stow/` is untouched, so `just stow --restow` is the rollback for this phase.

### Phase 1 — Bring up HM out-of-store import (the cutover)
- **Tag first:** `git tag pre-hm-migration` (the rollback anchor).
- **`git mv`** payload (single source of truth, keeps history): `stow/dot-config/*`→`config/`
  (minus `home-manager/`, promoted in P0), `dot-themes`→`themes/`, `dot-icons`→`icons/`,
  `dot-local/bin`→`home-bin/`, top-level `dot-*` (`dot-bashrc dot-zshrc dot-xonshrc
  dot-Xresources dot-dunstrc dot-elvish/`) → `home-files/` **keeping their `dot-` prefix**.
  Then `git rm` the cruft (`stow/dot-stowrc`, `stow/hooks_base.bash`, `stow/xed.dconf`, nested
  `stow/elvish/dot-elvish/`); `stow/` is now empty → `git rm -r stow/`. (Empty dirs like
  `config/bat` vanish on their own — git doesn't track them.)
- **Repoint `$FLAKE`/`NH_FLAKE`** from `~/.config/home-manager` → `~/.dotfiles` in **all four** sources (these are what `nh`/`nixup` actually read — the prior draft listed only two):
  - `config/env/common.env` — `NH_FLAKE` (the var `nh` reads) and `FLAKE`
  - `config/fish/conf.d/home-manager.fish` — `set -gx FLAKE`
  - `home-bin/nixeh` — the `$FLAKE` default
  - `home-bin/nixup` — uses `$FLAKE` (no default; relies on the above)
- Fill `home/files.nix` using the helper (above), `nativelyManaged = []`.
- **Close the secret-commit gaps** (see **Security invariants**), in this same commit:
  `git rm --cached config/gh/hosts.yml config/glab-cli/aliases.yml` and add both to `.gitignore`;
  confirm the six nested per-tool `.gitignore` files rode along with their `git mv`'d dirs (they are
  what keep `fish_history`/`fish_variables`/`config.local.fish` out of the tree). **Gate the commit**
  on `pre-commit run gitleaks --all-files` over the moved tree.
- **Cutover** (per host, see sequence below). Operational rule: each host runs `just stow --delete` **while still on the pre-P1 commit** (so `stow/` exists), *then* pulls P1, *then* `nh home switch`. If a host pulls P1 first, the stow links dangle — `nh home switch -b` sweeps them aside (no data loss, just `.bak` clutter to clean).
- **Gate:** symlink diff shows targets moving `~/.dotfiles/stow/...` → `~/.dotfiles/config/...`; no broken links (`find ~ -xtype l` empty); fish/nvim/waybar/gh all still resolve. Commit.

### Phase 2 — *(removed — already done)*
Emacs (doomemacs 5.8M + spacemacs 25M), chemacs2, the `emacs/` config, and the
`doomemacs`/`spacemacs` launcher scripts were all removed before this plan (commits `45e17c0`,
`d0fadca`). Nothing to drop or clone-on-demand. The only residue is dead `.gitignore` lines and
an empty `fish/conf.d/emacs.fish`, cleaned up in Phase 3.

### Phase 3 — Cleanup & remove Stow
- `justfile`: delete `stow`, `default`, `clean`, and the `just stow` line in `setup_dotfiles`. Add `switch` (`nh home switch ~/.dotfiles`) and `build`. Keep `setup_precommit`, `update`.
- `bootstrap.sh`: replace the `nix run … -- setup` → stow path with `home-manager switch --flake "$DOTFILES#chloe@$(hostname)"` (or a flake `apps.setup`). **Keep `pre-commit install` in this path** (call `just setup_precommit`, or run `pre-commit install` directly) — otherwise a fresh host gets no gitleaks hook (**Security invariants #3**).
- `README.md`: rewrite the now-false "trying out gnu stow" narrative to describe the HM-only setup.
- **Prune dead `.gitignore` lines** (root): `stow/emacs/dot-config/spacemacs/CHANGELOG*`, `stow/emacs/.../pianobar/README.org`, `stow/pianobar/dot-config/pianobar/config` (none of these paths exist), and the duplicate `**/*.ignored.*`. Move the `zoom.conf`/`zoomus.conf` rules from `config/.gitignore` to the root `.gitignore` and delete `config/.gitignore` (the helper skips it anyway). **Confirm the `gh`/`glab-cli` ignores from Phase 1 are present** (Security invariants #1). **Leave the six nested per-tool `.gitignore` files untouched** (Security invariants #2 — they are dir-relative; consolidating or deleting them re-exposes `fish_history`/`fish_variables`).
- **Delete files** (corrected locations): `flake.nix.maybe` + `flake.lock.maybe` (repo root); `flake.lock2` + `nh-home-switch.log` (in `stow/dot-config/home-manager/`); `nix-installer.plan.json` + `nix-installer.plan.json12` (in `hosts/qweenkpad/` — do not carry into `home/hosts/`); empty `TMPDIR/` and root `nh-home-switch.log` (regenerated by `nixup`'s `tee`, and gitignored via `**/*.log` — cosmetic); empty `fish/conf.d/emacs.fish`. Decide on `modules/common.nix` (currently 0 bytes, imported nowhere): delete, or repurpose as the shared module for Phase 4.
- `stow/` is already gone (removed in P1). Until both hosts are verified on HM, the rollback is `git checkout pre-hm-migration` + re-activation (see cutover). Drop the `pre-hm-migration` tag once both hosts are stable.
- **Milestone:** fully off Stow. Everything is HM-managed out-of-store symlinks; activation is `nh home switch` only. This is a safe stopping point — Phase 4 is optional/independent.

### Phase 4 — Native module conversion (deferred; after Stow is gone)
Now that Stow is removed, convert tools to `programs.*` one at a time. Each conversion is an
isolated commit: add the tool to `nativelyManaged` (drops its symlink) **and** enable its module
in the same change. Rollback for any tool = `git revert` that commit + `nh switch` (returns it to
the symlink). No stow interaction.
1. **git** — finish `programs.git` (already half-built per-host: `hosts/ombre/chloe.nix` has `enable = true` w/ SSH signing, `hosts/qweenkpad/chloe.nix` has `enable = false`; the block is **duplicated** across both hosts — hoist the shared config into `modules/common.nix`, leave only `enable`/host-specific bits per host). Delete `config/git/`.
2. **Small static**: `tmux`, `kitty`, `bat` (already `programs.bat`), `starship` (already `programs.starship.enable`; either port `config/starship.toml` → `programs.starship.settings` **or** keep the file — but not both, or they collide). Low risk.
3. **fish** (large): `programs.fish` — move `config.fish` init → `interactiveShellInit`, abbreviations → `shellAbbrs`, plugins → `programs.fish.plugins` mapped to `pkgs.fishPlugins.*` / `fetchFromGitHub` (tide, abbr_tips, autopair, sponge, puffer-fish, halostatue-fish-haskell, dotenv, sdkman-for-fish). Drop fisher + `fish_plugins`. Port user functions (subset of the 93; the `_tide_*` ones are plugin-provided). Do on its own branch — fisher/tide parity is the risk; the live symlinked config keeps working until merged.
4. **neovim** (largest): `programs.neovim` with plugins from `pkgs.vimPlugins`, `extraLuaConfig` sourcing the existing kickstart lua. Drop lazy.nvim + `lazy-lock.json`. Map the 33 plugins. Highest-effort, highest-risk — do last, on its own branch.

Stay-symlinked permanently (never converted): WM configs (hypr/sway/i3/waybar/rofi/dunst/wlogout),
themes, icons, scripts, and **secret-bearing** `gh`/`glab-cli` (`programs.gh` would clobber the
OAuth `hosts.yml`). **Symlinking keeps these *mutable*; it does NOT make them commit-safe** — the
symlink target is the tracked repo file, so a runtime token write commits unless ignored. See
**Security invariants**.

---

## Cutover sequence & collision handling (Phase 1, per host)

HM `home.file`/`xdg.configFile` abort rather than clobber an existing non-HM file; Stow owns those
paths today. The order matters: unlink while `stow/` still exists (on the pre-P1 commit), *then*
switch to the P1 tree, *then* activate HM. Do **qweenkpad first** (richer host, has the nix-index
module), then **ombre**.

```sh
# Per host. Run steps 0–1 WHILE STILL ON THE PRE-P1 COMMIT (stow/ present, links live).

# 0. pre-flight (read-only)
just stow --no --verbose=2                                   # dry-run: list links stow owns
find ~ -maxdepth 4 -type l -printf '%p -> %l\n' | sort > /tmp/before.txt

# 1. clean unlink while stow/ still exists, THEN move to the P1 tree
just stow --delete                                          # removes only links stow owns
git checkout to-hm   # (or: git pull) — brings in P1: config/ etc., stow/ gone, files.nix filled

# 2. evaluate, then activate HM
home-manager build --flake ~/.dotfiles#chloe@$(hostname)    # eval new tree, no activation
nh home switch -ub ".pre-hm.bak" ~/.dotfiles               # -b is the net for stray real files / stray links

# 3. verify
find ~ -maxdepth 4 -type l -printf '%p -> %l\n' | sort > /tmp/after.txt
diff /tmp/before.txt /tmp/after.txt                        # targets: stow/... → config/...
find ~ -maxdepth 4 -xtype l                                # broken links → must be empty

# rollback (git restores the repo; re-activation restores the live $HOME):
#   home-manager generations             # find the pre-migration generation id
#   <that-gen>/activate                  # remove the HM out-of-store links from $HOME
#   git checkout pre-hm-migration        # restore stow/ in the repo
#   just stow --restow                   # recreate the stow links
```

> A host stays on the pre-P1 commit (stow/ intact, fully working) until it is ready to cut over —
> there is no shared stale tree to drift. Keep the `pre-hm-migration` tag until **both** hosts are
> stable. A rollback to the tag after cutover re-creates `stow/`, but does not include later edits
> to `config/` — commit those first (a normal git concern, not a silent stale-copy footgun).

---

## Verification

- After every phase: `home-manager build --flake ~/.dotfiles#chloe@<host>` (zero side effects) + `nh home switch --dry`.
- Symlink diff before/after (above); `find ~ -xtype l` empty.
- App smoke tests: fish (plugins/abbrs/tide prompt intact), nvim (`:Lazy`/plugins load), `gh auth status` (token survived), waybar (config symlink resolves), GTK theme switch (theme assets resolve).
- Confirm `nh`/`nixup` target `~/.dotfiles` after the `$FLAKE`/`NH_FLAKE` repoint (`echo $NH_FLAKE`; run `nixup` and check it switches the right flake).
- **Secret-commit gate (Security invariants):** `pre-commit run gitleaks --all-files` clean on the moved tree before the P1 commit; `git status --porcelain` after first launching fish/gh/nvim shows no `fish_history`/`fish_variables`/`hosts.yml` newly tracked; `git ls-files | grep -E 'gh/hosts\.yml|glab-cli'` returns nothing (untracked per #1); and `.git/hooks/pre-commit` exists on **every** host (#3).
- Rollback drill before trusting: from a cut-over host run the full rollback (activate prior generation → `git checkout pre-hm-migration` → `just stow --restow`), confirm the old world is restored, then redo the cutover. In Phase 4: `git revert` the conversion commit → `nh switch` restores that tool's symlink.

---

## Critical files to modify / create

- **Create** `/home/chloe/.dotfiles/lib/dotfiles.nix` (undot + mkOutOfStoreTree helper, with hidden/empty filters)
- **Create** `/home/chloe/.dotfiles/home/files.nix` (import module)
- **Promote + repoint** `stow/dot-config/home-manager/flake.nix` → `/home/chloe/.dotfiles/flake.nix` (repoint `./*.nix` → `./home/*.nix` in both module lists; keep flox/snowfall — `packages.nix` uses `snowfallorg.flakes`; promote modules verbatim incl. the unused `misc`/`unstable`/`home` args)
- **Edit** `home/home.nix` (drop stow comment) and add `./home/files.nix` to both `modules` lists in `flake.nix`
- **Edit** `/home/chloe/.dotfiles/justfile` (remove stow recipes; add hm/nh)
- **Edit** `/home/chloe/.dotfiles/bootstrap.sh` (HM switch instead of stow)
- **Edit** `$FLAKE`/`NH_FLAKE` in **four** files → `~/.dotfiles`: `config/env/common.env`, `config/fish/conf.d/home-manager.fish`, `home-bin/nixeh`, `home-bin/nixup`
- **Edit** `README.md` (drop the "gnu stow" narrative)
- **`git mv`** payload trees + `git rm -r stow/` (incl. nested `elvish/dot-elvish/`, `dot-stowrc`, `hooks_base.bash`, `xed.dconf`) — all in Phase 1, after `git tag pre-hm-migration`. **Delete** (Phase 3) `flake*.maybe`, `flake.lock2`, `nh-home-switch.log` (×2), `nix-installer.plan.json*`, `TMPDIR/`, empty `fish/conf.d/emacs.fish`, `config/.gitignore`, dead `.gitignore` lines
- **Security (Phase 1 commit):** `git rm --cached config/gh/hosts.yml config/glab-cli/aliases.yml` + add to `.gitignore`; gate commit on `pre-commit run gitleaks --all-files`; keep the six nested per-tool `.gitignore` files intact (do not consolidate/delete). **(Phase 3)** keep `pre-commit install` in `bootstrap.sh`.
- **Phase 4 only** (one commit per tool): `home/programs.nix` / new `programs.*` modules + add tool to `nativelyManaged` in `home/files.nix`; delete the converted tool's `config/<tool>/`; hoist the duplicated `programs.git` block into `modules/common.nix`

## Open edge items to confirm during execution
- `programs.starship`: keep `config/starship.toml` as the symlinked source **or** move it into `programs.starship.settings` — not both (currently `settings = {}`, so no collision, but it is fragile).
- `misc`/`unstable`/`home` module args: undeclared in `extraSpecialArgs` yet the flake evaluates — preserve the exact module wiring on promotion; investigate the provider before any signature cleanup.
- fish native parity for tide + the 8 plugins is the main risk — Phase 4, on a branch; live symlinked config stays until merged.
- `home.file` does not preserve internal relative symlinks under store-copy — non-issue here since everything is out-of-store, but do not switch themes/waybar to store-copy.
