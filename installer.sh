#!/bin/bash
set -e

# All paths derived from BASE_DIR — never cd, use absolute paths everywhere
BASE_DIR="$HOME/dotterfiles"
DOTFILES="$BASE_DIR/dotfiles"

PACMAN_PACKAGES="hyprlock hypridle wofi waybar kitty mako noto-fonts ttf-bitstream-vera \
    git cliphist hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent \
    xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber \
    pipewire-jack npm wireguard-tools zsh"

YAY_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-hyprcursor \
    mov-cli ani-cli python-mov-cli-youtube"

# ── Pacman packages ───────────────────────────────────────────────────────────
echo ">>> Installing pacman packages..."
sudo pacman -Syu --needed $PACMAN_PACKAGES && echo ">>> Base packages installed."

# ── Clone repo ────────────────────────────────────────────────────────────────
read -rp "Clone dotterfiles repo? (y/n): " gitans
if [[ "$gitans" =~ ^[Yy]$ ]]; then
    if [ -d "$BASE_DIR" ]; then
        echo ">>> $BASE_DIR already exists, pulling instead..."
        git -C "$BASE_DIR" pull
    else
        git clone https://github.com/deccandewan/dotterfiles "$BASE_DIR"
    fi
    chmod +x "$BASE_DIR/dotfinstall.sh"
else
    echo ">>> Skipping repo clone. Steps below may fail if files are missing."
fi

# ── Shell config ──────────────────────────────────────────────────────────────
read -rp "Replace .bashrc? (y/n): " bashrcans
if [[ "$bashrcans" =~ ^[Yy]$ ]]; then
    if [ -f "$BASE_DIR/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
        cp "$BASE_DIR/.bashrc" "$HOME/.bashrc"
        echo ">>> .bashrc replaced (backup at ~/.bashrc.bak)"
    else
        echo ">>> .bashrc not found in repo, skipping."
    fi
else
    read -rp "Replace .zshrc instead? (y/n): " zshrcans
    if [[ "$zshrcans" =~ ^[Yy]$ ]]; then
        if [ -f "$BASE_DIR/dotfiles/.zshrc" ]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
            cp "$BASE_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
            echo ">>> .zshrc replaced (backup at ~/.zshrc.bak)"
        else
            echo ">>> .zshrc not found in repo, skipping."
        fi
    fi
fi

# ── Dotfiles ──────────────────────────────────────────────────────────────────
read -rp "Copy dotfiles? (y/n): " copyans
if [[ "$copyans" =~ ^[Yy]$ ]]; then
    bash "$BASE_DIR/dotfinstall.sh"
fi

# ── Yay ───────────────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    read -rp "Install yay (AUR helper)? (y/n): " yayans
    if [[ "$yayans" =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay.git "$HOME/yay-build"
        (cd "$HOME/yay-build" && makepkg -si)
        rm -rf "$HOME/yay-build"
    fi
fi

read -rp "Install AUR packages? (y/n): " yaypackans
if [[ "$yaypackans" =~ ^[Yy]$ ]]; then
    yay -S $YAY_PACKAGES
fi

# ── Wireguard configs ─────────────────────────────────────────────────────────
read -rp "Install WireGuard configs from repo? (y/n): " wgans
if [[ "$wgans" =~ ^[Yy]$ ]]; then
    if [ -d "$BASE_DIR/wireguard" ]; then
        sudo cp -r "$BASE_DIR/wireguard/"* /etc/wireguard/
        sudo chmod 600 /etc/wireguard/*.conf
        echo ">>> WireGuard configs installed to /etc/wireguard/"
    else
        echo ">>> No wireguard/ folder found in $BASE_DIR, skipping."
    fi
fi


chsh -s /usr/bin/zsh
# ── Done ──────────────────────────────────────────────────────────────────────
read -rp "All done! Reboot now? (y/n): " rebootans
if [[ "$rebootans" =~ ^[Yy]$ ]]; then
    reboot
fi
