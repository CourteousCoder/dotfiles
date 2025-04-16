#!/usr/bin/env fish 
command -q fnm
and fnm env                         \
  --use-on-cd                       \
  --version-file-strategy recursive \
  --corepack-enabled                \
  --resolve-engines                 \
  --shell fish                      \
  | source

