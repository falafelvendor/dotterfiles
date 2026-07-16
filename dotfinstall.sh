#!/bin/bash
set -e

# Run from anywhere — paths are always absolute
# Expected layout: dotfiles/{hypr,waybar,kitty,...} next to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SCRIPT_DIR/dotfiles"

copy_config() {
    local src="$DOTFILES/$1"
    local dst="$HOME/.config/$1"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -r "$src"/. "$dst/"
        echo ">>> Copied $1"
    else
        echo ">>> Skipping $1 (not found in $DOTFILES)"
    fi
}

copy_config fastfetch
copy_config hypr
copy_config fontconfig
copy_config kitty
copy_config neofetch
copy_config waybar
copy_config wofi
copy_config mako
[ -f "$DOTFILES/.zshrc" ] && cp "$DOTFILES/.zshrc" "$HOME/.zshrc" && echo ">>> Copied .zshrc"

# NetworkManager needs sudo
NM_SRC="$DOTFILES/NetworkManager/00-macrandomize.conf"
if [ -f "$NM_SRC" ]; then
    sudo cp "$NM_SRC" /etc/NetworkManager/conf.d/
    echo ">>> Copied NetworkManager MAC randomization config"
else
    echo ">>> Skipping NetworkManager config (not found)"
fi
