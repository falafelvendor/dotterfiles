# dotterfiles

Personal Arch Linux setup: a from-scratch installer, a Hyprland dotfiles installer, and backup tooling, kept together so a fresh machine can go from bare ISO to a fully configured desktop with as few manual steps as possible.

## TemuArchInstaller.sh

The reason this installer exists even after archinstall(official) is because archinstall always introduced some sort of latency on the system, which made it feel horrendous to use.

Run from the Arch ISO live environment:

```bash
curl -o TemuArchInstaller.sh https://raw.githubusercontent.com/deccandewan/dotterfiles/main/TemuArchInstaller.sh
chmod +x TemuArchInstaller.sh
```

Before running, open the script and edit the config block at the top (disk, hostname, username, timezone, locale, partition sizes, whether to install Nvidia drivers). The script will show you the current values and ask if you want to change them interactively before doing anything destructive.

```bash
./TemuArchInstaller.sh
```

It partitions and formats the target disk, mounts everything, pacstraps the base system, generates fstab, then copies itself into the new install and `arch-chroot`s in to finish the rest: locale, timezone, hostname, base packages, microcode, root and user accounts, sudoers, systemd-boot, NetworkManager, and Nvidia drivers if requested.

**This will completely wipe the target disk.** The script asks for an explicit `YES` confirmation before partitioning, and only runs in UEFI mode (it checks `efivar -l` before doing anything).



To force a completely clean run, run 'rm *.conf':


## installer.sh (only use if you want hyprland setup)

Run this after rebooting into the freshly installed system and connecting to the internet (NetworkManager is installed), as your normal user:

```bash
curl -o arch-setup.sh https://raw.githubusercontent.com/deccandewan/dotterfiles/main/installer.sh
chmod +x installer.sh
./installer.sh
```

It runs a full `pacman -Syu`, installs yay if it isn't already present, installs fonts (including the Arabic fontconfig setup)

`installer.sh` looks for a `dotterfiles` folder under `$HOME`; if it's not there yet, it clones this repo to `~/dotterfiles` and continues from there, prompting you through the rest (dotfiles, shell config, AUR packages, WireGuard). If you'd rather clone the whole repo upfront instead of letting the scripts fetch pieces on their own, that works too:

```bash
git clone https://github.com/deccandewan/dotterfiles ~/dotterfiles
cd ~/dotterfiles
chmod +x arch-setup.sh installer.sh
./arch-setup.sh
```

## Contents

| File | Purpose |
|---|---|
| `TemuArchInstaller.sh` | Automates the base Arch Linux install (partitioning through bootloader) from the live ISO. |
| `ArchInstall.md` | The manual, step-by-step install notes that `TemuArchInstaller.sh` is based on. Kept as a reference for what the script is actually doing, or as a fallback if you'd rather do it by hand. |
| `installer.sh` | Installs Hyprland and related packages via pacman, clones this repo, and walks through applying dotfiles, shell config, yay/AUR packages, and WireGuard configs. |
| `dotfinstall.sh` | Copies the contents of `dotfiles/` into `~/.config/` (and `.zshrc` into `$HOME`). Can be run standalone if you just want the configs applied again. |
| `backup.sh` | Reverse of `dotfinstall.sh` — copies your current configs out of `~/.config/` into a folder of your choosing, for backing up before changes or before wiping a machine. |
| `dotfiles/` | The actual configs: Hyprland, waybar, kitty, wofi, mako, fontconfig, fastfetch, neofetch, NetworkManager. |
| `default.xml` | A libvirt NAT network definition, for anyone running VMs on this machine. |

## Fresh install order

1. Boot the Arch ISO, then run `TemuArchInstaller.sh` (see below). This gets you a bootable, minimal Arch system.

2. Reboot into the new system,log in as your user,connect using NetworkManager, and run `installer.sh`. This updates the system,Installs yay if not found, installs all required packages (pacman and yay), and then calls `dotfinstall.sh' for final install.

Each script can also be run on its own if you only need part of this; for example, running `dotfinstall.sh` by itself just re-applies the dotfiles without touching packages.

## Notes

- `dotfinstall.sh` expects the `dotfiles/` folder to sit next to it, and installs pacman packages before copying configs is recommended — `fontconfig` in particular depends on packages being present first.
