#!/bin/bash
PACKAGES="wofi waybar kitty noto-fonts ttf-bitstream-vera hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack"

#Yay Packages:
Yay_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-cursor"
sudo pacman -Sy  $PACKAGES && echo "Base sucessfully installed, with packages: $PACKAGES"

read -p "Do you want to install yay packages as well? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Installing yay packages..."
    yay -S $Yay_PACKAGES
    echo "Yay packages installed."
else
    echo "Skipping yay packages installation."
fi

