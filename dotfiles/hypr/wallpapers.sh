#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
STATE_FILE="$HOME/.cache/hypr/wallpaper-index"
mkdir -p "$(dirname "$STATE_FILE")"

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

COUNT=${#WALLPAPERS[@]}
if [ "$COUNT" -eq 0 ]; then
    notify-send "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

INDEX=0
[ -f "$STATE_FILE" ] && INDEX=$(cat "$STATE_FILE")
NEXT=$(( (INDEX + 1) % COUNT ))
echo "$NEXT" > "$STATE_FILE"

awww img "${WALLPAPERS[$NEXT]}" --transition-type fade --transition-duration 1
