#!/usr/bin/env bash
set -e

# ── Must not run as root ──────────────────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
    echo ">>> Don't run this as root. Run as your normal user (sudo will be called when needed)."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm git


# ── Yay ───────────────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    echo ">>> Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay-build
    (cd /tmp/yay-build && makepkg -si --noconfirm)
    rm -rf /tmp/yay-build
else
    echo ">>> yay already installed, skipping."
fi


# ── Fonts ─────────────────────────────────────────────────────────────────────
echo ">>> Installing fonts..."
sudo pacman -S --needed --noconfirm noto-fonts noto-fonts-arabic ttf-bitstream-vera
yay -S --noconfirm ttf-nerd-fonts-symbols

echo ">>> Configuring fontconfig for Arabic..."
mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Prefer modern simple Arabic -->
  <match>
    <test name="lang" compare="contains"><string>ar</string></test>
    <edit name="family" mode="prepend"><string>Noto Sans Arabic</string></edit>
  </match>

  <!-- Generic fallback -->
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Noto Sans Arabic</family>
      <family>Nerd Fonts Symbols Mono</family>
    </prefer>
  </alias>
</fontconfig>
EOF
fc-cache -fv

# ── Hand off to installer.sh ──────────────────────────────────────────────────
curl -o "$SCRIPT_DIR/installer.sh" https://raw.githubusercontent.com/deccandewan/dotterfiles/main/installer.sh
echo ""
echo ">>> System setup done. Handing off to installer.sh..."
echo ""

if [ -f "$SCRIPT_DIR/installer.sh" ]; then
    chmod +x "$SCRIPT_DIR/installer.sh"
    bash "$SCRIPT_DIR/installer.sh"
else
    echo ">>> WARNING: installer.sh not found in $SCRIPT_DIR"
    echo ">>> Run it manually once you have the repo cloned."
fi
