#!/bin/bash
WINDOWS_HOME="/mnt/c/Users/nabeliwo"
SRC="$HOME/.config/wezterm"
DST="$WINDOWS_HOME/.config/wezterm"

if [ -d "$WINDOWS_HOME" ]; then
    mkdir -p "$DST"
    cp -r "$SRC/." "$DST/"
fi
