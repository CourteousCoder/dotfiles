#!/usr/bin/env fish 
command -q fnm
and fnm env                         \
  --use-on-cd                       \
  --version-file-strategy recursive \
  --corepack-enabled                \
  --resolve-engines                 \
  --shell fish                      \
  | source
and test -d ~/.cargo/bin
and fish_add_path -mgx ~/.cargo.bin

