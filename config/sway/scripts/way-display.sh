#!/usr/bin/env bash
PATH="$PATH:/usr/local/bin" exec way-displays > /tmp/way-displays.${XDG_VTNR}.${USER}.log 2>&1
