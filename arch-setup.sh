#!/usr/bin/env bash
set -e

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Installing core packages (pacman)..."
sudo pacman -S --noconfirm \
    hyprland \
    hyprpaper hyprshot hyprcursor \
    wofi waybar \
    sddm

echo ">>> Enabling SDDM..."
sudo systemctl enable sddm.service

echo ">>> Installing AUR helper (yay)..."
if ! command -v yay >/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

echo ">>> Installing AUR packages (yay)..."
yay -S --noconfirm \
    sddm-theme-sugar-candy \
    neofetch \
    nerd-fonts-complete

echo ">>> Applying Sugar Candy theme to SDDM..."
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r /usr/share/sddm/themes/Sugar-Candy /usr/share/sddm/themes/
sudo sed -i 's|^Current=.*|Current=Sugar-Candy|' /etc/sddm.conf.d/*.conf 2>/dev/null || true
if [ ! -f /etc/sddm.conf ]; then
  echo "[Theme]" | sudo tee /etc/sddm.conf
  echo "Current=Sugar-Candy" | sudo tee -a /etc/sddm.conf
fi

echo ">>> Installing fonts (Arabic fix + Nerd Fonts)..."
mkdir -p ~/.config/fontconfig
cat > ~/.config/fontconfig/fonts.conf <<'EOF'
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

echo ">>> Done! Reboot and enjoy Hyprland with SDDM + Sugar Candy theme."

