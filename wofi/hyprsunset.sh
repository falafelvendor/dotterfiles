#!/usr/bin/env bash

CHOICE=$(wofi --dmenu \
              --lines 0 \
              --width 300 \
              --height 10 \
              --prompt "Gamma (0–200 or reset):")

[ -z "$CHOICE" ] && exit 0

if [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
    hyprctl hyprsunset gamma "$CHOICE"
elif [[ "$CHOICE" =~ ^[Rr]eset$ ]]; then
    hyprctl hyprsunset identity
fi

