#!/bin/bash
# Bash script
read -rp "Enter folder to save to:" target_dir
target_dir="${target_dir/#\~/$HOME}"

mkdir 	"$target_dir/dotfiles/" \
	"$target_dir/dotfiles/hypr" \
	"$target_dir/dotfiles/waybar" \
	"$target_dir/dotfiles/neofetch" \
	"$target_dir/dotfiles/kitty" \
	"$target_dir/dotfiles/fontconfig" \
	"$target_dir/dotfiles/wofi"
cp -r $HOME/.config/hypr/* $target_dir/dotfiles/hypr/ && echo "Copied Hypr!"
cp -r $HOME/.config/waybar/* $target_dir/dotfiles/waybar/ && echo "Copied Waybar!"
cp -r $HOME/.config/neofetch/* $target_dir/dotfiles/neofetch/ && echo "Copied Neofetch!"
cp -r $HOME/.config/kitty/* $target_dir/dotfiles/kitty/ && echo "Copied Kitty!"
cp -r $HOME/.config/fontconfig/* $target_dir/dotfiles/fontconfig/ && echo "Copied FontConfig!"
cp -r $HOME/.config/wofi/* $target_dir/dotfiles/wofi/ && echo "Copied Wofi!"
