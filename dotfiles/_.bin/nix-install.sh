#!/bin/bash

PACKAGE=$1
CONFIG_FILE=~/.config/nixpkgs/flake.nix

if [ -z "$PACKAGE" ]; then
  echo "Usage: $0 <package>"
  exit 1
fi

# Check if package is already in the config file
if grep -q "$PACKAGE" "$CONFIG_FILE"; then
  echo "Package $PACKAGE is already in the configuration."
  exit 0
fi

# Add the package to the home.packages list
sed -i "/home.packages = with pkgs; \[/ a\ \ \ \ $PACKAGE" "$CONFIG_FILE"

# Apply the Home Manager configuration
home-manager switch

