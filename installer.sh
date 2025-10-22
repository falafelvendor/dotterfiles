#!/bin/bash

#Pacman Packages:
PACKAGES="hyprlock wofi waybar kitty noto-fonts ttf-bitstream-vera git base-devel cliphist hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack "

#Yay Packages:
Yay_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-cursor"


#Installing Pacman packages
sudo pacman -Sy  $PACKAGES && echo "Base sucessfully installed, with packages: $PACKAGES"



#Clone Git Repo
read -p "Cloning git repo, what ya say? (y/n): " gitans
if [[ "$gitans" =~ ^[Yy]$ ]]; then
	echo "cloning repo"
	git clone https://github.com/falafelvendor/dotterfiles && echo "repo cloned"
	cd dotterfiles
	mkdir .dots
	mv dotfiles/hypr/ .dots/
	mv dotfiles/waybar/ .dots/
	mv dotfiles/kitty/ .dots/
	mv dotfiles/fontconfig/ .dots/
	mv dotfiles/neofetch/ .dots/
	mv dotfiles/wofi/ .dots/
	mv dotfinstall.sh .dots/
	cd .dots/
	chmod +x dotfinstall.sh
else
	echo "git repo not cloned"
fi 

#Copy .bashrc?
read -p "replace .bashrc? (Y/N): " bashrcans
if [[ "$bashrcans" =~ ^[Y]$ ]]; then
	cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
	cd ..
	cp .bashrc $HOME/.bashrc
	echo "your previous bashrc was saved as $HOME/.bashrc.bak"
else
	read -p "replace .zshrc? (Y/n) " zshrcans
	if [[ "$zshrcans" =~ ^[Y]$ ]]; then
	cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
	cp .zshrc $HOME/.zshrc
	echo "your previous zshrc was saved to $HOME/.zshrc.bak"

else
	echo "bashrc/zshrc was not replaced"
fi



#Copy Dotfiles
read -p "copy dotfiles? (y/n): " copyans
if [[ "$copyans" =~ ^[Yy]$ ]]; then
	cd .dots
	./dotfinstall.sh
else
	cd $HOME
	echo "config files not copied"
fi


#Install Yay
read -p "Install yay? (y/n): " yayinstallans
if [[ "$yayinstallans" =~ ^[Yy]$ ]]; then
	cd $HOME/
	git clone https://aur.archlinux.org/yay.git && echo 'cloned yay git'
	cd yay
	echo "making yay package"
	makepkg -si && echo "yay sucessfully installed!"
else
	echo "Yay not installed"
fi
#Install Yay packages
read -p "Do you want to install yay packages? $Yay_PACKAGES (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Installing yay packages."
    yay -S $Yay_PACKAGES && echo "Yay packages installed."
else
    cd $HOME
    echo "Skipping yay packages installation."
fi


#Restart system?
read -p "The script has finished installing everything, Restart System? (Y/N): " restartanswer
if [[ "$restartanswer" =~ ^[Y]$ ]]; then
	reboot
else
	echo "Script has finished installing everthing."
fi
