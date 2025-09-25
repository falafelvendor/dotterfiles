#!/bin/bash
PACKAGES="wofi waybar kitty noto-fonts ttf-bitstream-vera git base-devel hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack "

#Yay Packages:
Yay_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-cursor"

sudo pacman -Sy  $PACKAGES && echo "Base sucessfully installed, with packages: $PACKAGES"

read -p "Cloning git repo, what ya say? (y/n): " gitans
if [[ "$gitans" =~ ^[Yy]$ ]] then
	echo "cloning repo"
	git clone https://github.com/AkiraRyoK/dotterfiles.git && "repo cloned"
else
	echo "git repo not cloned"
fi 

read -p "Install yay? (y/n): " yayinstallans
if [[ "$yayinstallans" =~ ^[Yy]$ ]] then
	git clone https://aur.archlinux.org/yay.git && echo "cloned yay git"
	cd yay && echo "cd into yay repo"
	echo "making yay package"
	makepkg -si && echo "yay sucessfully installed!"
else
	echo "yay not installed"
fi


read -p "Do you want to install yay packages? $Yay_PACKAGES (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Installing yay packages."
    yay -S $Yay_PACKAGES && echo "Yay packages installed."
else
    echo "Skipping yay packages installation."
fi

