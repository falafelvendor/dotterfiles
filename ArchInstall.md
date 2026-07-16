# Arch Install — SomeOrdinaryGamers

Needs internet (just use ethernet if you can).

## Wi-Fi (if no ethernet)

`wlan0` is the interface assumed below, find yours with `ip link` first.

```bash
iwctl
```

```bash
station wlan0 scan
```

```bash
station wlan0 get-networks
```


```bash
station wlan0 connect (ssid)
```

```bash
station wlan0 show
```

Should show as connected.

## 1. Confirm UEFI boot mode

```bash
efivar -l
```

If you see random lines of output, you're good to go.

## 2. Identify the disk

```bash
lsblk
```

```bash
gdisk /path/to/disk
```

Inside `gdisk` do:
- `x` — expert mode
- `z` — clear disk

## 3. Partition the disk

```bash
cgdisk /path/to/disk
```

Create these partitions in order:

| Partition | Size | Type code | Name |
|---|---|---|---|
| boot | 1024MiB | EF00 | boot |
| swap | 16GiB (flexible) | 8200 | swap |
| root | 50GiB (20GB+ works) | 8300 | root |
| home | rest of the disk | 8300 | home |

Write changes, then quit `cgdisk`.

## 4. Format the partitions

Format `/boot`:
```bash
mkfs.fat -F32 /path/to/boot
```

Format and enable swap:
```bash
mkswap /path/to/swap
swapon /path/to/swap
```

Format `/root`:
```bash
mkfs.ext4 /path/to/root
```

Format `/home`:
```bash
mkfs.ext4 /path/to/home
```

## 5. Mount the partitions

```bash
mount /path/to/root /mnt
mkdir /mnt/boot
mount /path/to/boot /mnt/boot
mkdir /mnt/home
mount /path/to/home /mnt/home
```

Verify:
```bash
lsblk
```
Should show `/mnt`, `/mnt/boot`, and `/mnt/home` mounted.

## 6. Update the pacman mirrorlist

```bash
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sudo pacman -Sy pacman-contrib
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
```
Ranking mirrors can take a few minutes.

## 7. Install the base system

```bash
pacstrap -K /mnt base linux linux-firmware linux-headers base-devel
```

Generate fstab:
```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

## 8. Chroot in and configure

```bash
arch-chroot /mnt
```

Install nvim, zsh, and networking tools:
```bash
pacman -S sudo nvim zsh dhcpcd networkmanager
```

**Locale** — uncomment `en_US.UTF-8` in `/etc/locale.gen`:
```bash
nvim /etc/locale.gen
```
```bash
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

**Timezone** — find yours, then link it:
```bash
ls /usr/share/zoneinfo
ln -sf /usr/share/zoneinfo/path/to/location /etc/localtime
hwclock --systohc --utc
```

**Hostname:**
```bash
echo (hostname) > /etc/hostname
```

**SSD trim:**
```bash
systemctl enable fstrim.timer
```

**Multilib** — uncomment the `[multilib]` block and the line below it in `/etc/pacman.conf`, then:
```bash
nvim /etc/pacman.conf
sudo pacman -Sy
```

**Root password:**
```bash
passwd
```

**Create user account:**
```bash
useradd -m -g users -G wheel,storage,audio,video,power -s /bin/zsh (username)
passwd (username)
```

**Enable sudo for wheel group** — uncomment `%wheel` in `visudo`, and add `Defaults rootpw` at the bottom:
```bash
EDITOR=nvim visudo
```

## 9. Install the bootloader

```bash
mount -t efivarfs efivarfs /sys/firmware/efi/efivars/
bootctl install
```

Create `/boot/loader/entries/arch.conf`:
```bash
nvim /boot/loader/entries/arch.conf
```
```
title Arch
linux /vmlinuz-linux
initrd /initramfs-linux.img
```

Append the root partition option:
```bash
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /path/to/root) rw" >> /boot/loader/entries/arch.conf
```

Install microcode here if needed (intel-ucode / amd-ucode).

## 10. Network

```bash
ip link
```
Find your interface (anything besides `lo`), then:
```bash
sudo systemctl enable dhcpcd@(interface).service
sudo systemctl enable NetworkManager.service
```

## 11. Nvidia drivers (if you have nvidia-gpu)

```bash
sudo pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings
```

Add `nvidia nvidia_modeset nvidia_uvm nvidia_drm` inside `MODULES=()`:
```bash
sudo nvim /etc/mkinitcpio.conf
```

Add `nvidia-drm.modeset=1` after `rw`:
```bash
sudo nvim /boot/loader/entries/arch.conf
```

Build the mkinitcpio hook:
```bash
sudo mkdir /etc/pacman.d/hooks/
sudo nvim /etc/pacman.d/hooks/nvidia.hook
```
```
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia

[Action]
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P
```

## 12. Boot into your system

```bash
umount -R /mnt
reboot
```
Remove the USB, then log in with your username and password.
