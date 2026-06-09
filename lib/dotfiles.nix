# Out-of-store dotfile import helpers.
#
# Reproduces GNU Stow's `dot-foo` -> `.foo` rename and keeps the working tree as
# the symlink target (so internal relative symlinks under themes/waybar resolve
# unchanged). Avoids hand-listing the ~58 config dirs.
#
# Filters:
#   - hidden entries (so `config/.gitignore` never becomes `~/.config/.gitignore`)
#   - empty directories (defensive: empty dirs aren't git-tracked, so they never
#     reach the flake store anyway)
{
  lib,
  config,
}: let
  home = config.home.homeDirectory;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  undot = name:
    if lib.hasPrefix "dot-" name
    then "." + lib.removePrefix "dot-" name
    else name;
  # One mutable symlink per immediate child of `src`, applying the dot- rename.
  # `exclude` = list of dest names natively managed elsewhere (skip them).
  mkOutOfStoreTree = {
    src,
    repoSub,
    destPrefix ? "",
    exclude ? [],
  }:
    lib.mapAttrs'
    (name: _:
      lib.nameValuePair (destPrefix + undot name)
      {source = mkOutOfStoreSymlink "${home}/.dotfiles/${repoSub}/${name}";})
    (lib.filterAttrs (
        name: type:
          !(lib.hasPrefix "." name) # skip .gitignore & hidden
          && !(type == "directory" && builtins.readDir (src + "/${name}") == {}) # skip empty dirs
          && !(lib.elem (destPrefix + undot name) exclude)
      )
      (builtins.readDir src));
in {inherit undot mkOutOfStoreTree mkOutOfStoreSymlink;}
