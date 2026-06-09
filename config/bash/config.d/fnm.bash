command -v fnm > /dev/null  && \
  eval "$(fnm env --use-on-cd --version-file-strategy recursive --corepack-enabled --resolve-engines)" && \
  eval "$(fnm completions)"
