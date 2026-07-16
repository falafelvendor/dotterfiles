# dotterfiles

Personal Arch Linux setup: a from-scratch installer, a Hyprland dotfiles installer, and backup tooling, kept together so a fresh machine can go from bare ISO to a fully configured desktop with as few manual steps as possible.

## TemuArchInstaller.sh

The reason this installer exists even after archinstall(official) is because archinstall always introduced some sort of latency on the system, which made it feel horrendous to use.

Run from the Arch ISO live environment as root:

```bash
curl -o TemuArchInstaller.sh https://raw.githubusercontent.com/deccandewan/dotterfiles/main/TemuArchInstaller.sh
chmod +x TemuArchInstaller.sh
./TemuArchInstaller.sh
```

Before running, open the script and edit the config block at the top (disk, hostname, username, timezone, locale, partition sizes, whether to install Nvidia drivers). The script will show you the current values and ask if you want to change them interactively before doing anything destructive.

It partitions and formats the target disk, mounts everything, pacstraps the base system, generates fstab, then copies itself into the new install and `arch-chroot`s in to finish the rest: locale, timezone, hostname, base packages, microcode, root and user accounts, sudoers, systemd-boot, NetworkManager, and Nvidia drivers if requested.

**This will completely wipe the target disk.** The script asks for an explicit `YES` confirmation before partitioning, and only runs in UEFI mode (it checks `efivar -l` before doing anything).



To force a completely clean run, run 'rm *.conf':


## arch-setup.sh (only use if you want hyprland setup)

Run this after rebooting into the freshly installed system and connecting to the internet (NetworkManager is installed), as your normal user (not root — the script refuses to run as root and calls `sudo` itself when needed):

```bash
curl -o arch-setup.sh https://raw.githubusercontent.com/deccandewan/dotterfiles/main/arch-setup.sh
chmod +x arch-setup.sh
./arch-setup.sh
```

It runs a full `pacman -Syu`, installs yay if it isn't already present, installs fonts (including the Arabic fontconfig setup), then fetches `installer.sh` from this repo into the same directory and hands off to it automatically.

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
| `arch-setup.sh` | Post-install system setup: full system update, yay, fonts (including Arabic fontconfig), then hands off to `installer.sh`. |
| `installer.sh` | Installs Hyprland and related packages via pacman, clones this repo, and walks through applying dotfiles, shell config, yay/AUR packages, and WireGuard configs. |
| `dotfinstall.sh` | Copies the contents of `dotfiles/` into `~/.config/` (and `.zshrc` into `$HOME`). Can be run standalone if you just want the configs applied again. |
| `backup.sh` | Reverse of `dotfinstall.sh` — copies your current configs out of `~/.config/` into a folder of your choosing, for backing up before changes or before wiping a machine. |
| `dotfiles/` | The actual configs: Hyprland, waybar, kitty, wofi, mako, fontconfig, fastfetch, neofetch, NetworkManager. |
| `default.xml` | A libvirt NAT network definition, for anyone running VMs on this machine. |

## Fresh install order

1. Boot the Arch ISO, then run `TemuArchInstaller.sh` (see below). This gets you a bootable, minimal Arch system.
2. Reboot into the new system,log in as your user, and run `arch-setup.sh`. This updates the system, installs fonts, and then calls `installer.sh` after downloading it.
3. `installer.sh` installs Hyprland and its dependencies, clones this repo if it isn't already present, and prompts you through applying dotfiles, replacing your shell config, installing yay and AUR packages, and installing WireGuard configs.

Each script can also be run on its own if you only need part of this; for example, running `dotfinstall.sh` by itself just re-applies the dotfiles without touching packages.

## Notes

- `dotfinstall.sh` expects the `dotfiles/` folder to sit next to it, and installs pacman packages before copying configs is recommended — `fontconfig` in particular depends on packages being present first.
- `installer.sh` currently clones from `deccandewan/dotterfiles`; if you've forked or renamed this repo, update that URL before relying on the clone step.
- `backup.sh` mirrors the same set of configs that `dotfinstall.sh` installs, so the two stay in sync — if you add a new dotfile folder to one, add it to the other.
