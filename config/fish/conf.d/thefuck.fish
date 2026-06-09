#!/usr/bin/env fish

status is-interactive
and command -q thefuck
and thefuck --alias | source
