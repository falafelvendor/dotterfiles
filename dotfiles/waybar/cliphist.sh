#!/bin/bash

# Set exact position
WOFI_WIDTH=320
WOFI_HEIGHT=280
PADDING_RIGHT=20  # distance from right edge
WAYBAR_HEIGHT=46   # your waybar height

# Get screen width
SCREEN_WIDTH=$(hyprctl monitors | grep -m1 'width' | awk '{print $2}' | cut -d',' -f1)

# Calculate position
X=$((SCREEN_WIDTH - WOFI_WIDTH - PADDING_RIGHT))
Y=$((WAYBAR_HEIGHT + 8))  # just below Waybar

# Launch Wofi
cliphist list | wofi --dmenu --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT" --x "$X" --y "$Y"

