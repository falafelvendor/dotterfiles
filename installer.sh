#!/bin/bash

#Pacman Packages:
PACKAGES="wofi waybar kitty noto-fonts ttf-bitstream-vera git base-devel hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack "

#Yay Packages:
Yay_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-cursor"


#Installing Pacman packages
sudo pacman -Sy  $PACKAGES && echo "Base sucessfully installed, with packages: $PACKAGES"



#Clone Git Repo
read -p "Cloning git repo, what ya say? (y/n): " gitans
if [[ "$gitans" =~ ^[Yy]$ ]]; then
	echo "cloning repo"
	git clone https://github.com/falafelvendor/dotterfiles && "repo cloned"
	cd dotterfiles
	chmod +x dotfinstall.sh
else

	echo "git repo not cloned"
fi 



#Copy Dotfiles
read -p "copy dotfiles? (y/n): " copyans
if [[ "$copyans" =~ ^[Yy]$ ]]; then
	./dotfinstall.sh
else
	echo "config files not copied"
fi


#Install Yay
read -p "Install yay? (y/n): " yayinstallans
if [[ "$yayinstallans" =~ ^[Yy]$ ]]; then
	git clone https://aur.archlinux.org/yay.git && echo 'cloned yay git'
	cd yay
	echo "making yay package"
	makepkg -si && echo "yay sucessfully installed!"


#Install Yay packages
read -p "Do you want to install yay packages? $Yay_PACKAGES (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Installing yay packages."
    yay -S $Yay_PACKAGES && echo "Yay packages installed."
else
    echo "Skipping yay packages installation."
fi

#Restart system?
read -p "Restart System? (Y/N): " restartanswer
if [[ "$restartanswer" =~ ^[Y]$ ]]; then
	reboot
else
	echo "Script has finished installing everthing."
fi
