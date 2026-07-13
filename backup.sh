#!/bin/bash
set -e

read -rp "Enter folder to save backup to: " target_dir
target_dir="${target_dir/#\~/$HOME}"
DEST="$target_dir/dotfiles"

backup_config() {
    local name="$1"
    local src="${2:-$HOME/.config/$name}"
    if [ -d "$src" ] || [ -f "$src" ]; then
        mkdir -p "$DEST/$name"
        cp -r "$src"/. "$DEST/$name/"
        echo ">>> Backed up $name"
    else
        echo ">>> Skipping $name (not found at $src)"
    fi
}

mkdir -p "$DEST"

backup_config hypr
backup_config waybar
backup_config kitty
backup_config fontconfig
backup_config wofi
backup_config mako
backup_config neofetch
backup_config fastfetch
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$DEST/.zshrc" && echo ">>> Backed up .zshrc"

# NetworkManager is a file not a dir
NM_CONF="/etc/NetworkManager/conf.d/00-macrandomize.conf"
if [ -f "$NM_CONF" ]; then
    mkdir -p "$DEST/NetworkManager"
    cp "$NM_CONF" "$DEST/NetworkManager/"
    echo ">>> Backed up NetworkManager MAC randomization config"
else
    echo ">>> Skipping NetworkManager config (not found)"
fi

echo ""
echo ">>> Backup complete: $DEST"
