#!/usr/bin/env bash
#
# arch-install.sh
# Self-relaunching Arch Linux install script.
# Run from the Arch ISO live environment as root:
#   ./arch-install.sh
#
# The script partitions/formats/mounts the disk, pacstraps the base system,
# copies itself into the new install, then arch-chroots in and re-runs
# itself with --chroot to finish setup (locale, users, bootloader, etc).
#
# EDIT THE CONFIG SECTION BELOW BEFORE RUNNING.

set -euo pipefail

# ============================================================
# CONFIG — edit these before running
# ============================================================
DISK="/dev/sda"          # target disk, e.g. /dev/sda or /dev/nvme0n1 — THIS WILL BE WIPED
HOSTNAME="archbox"
USERNAME="user"
TIMEZONE="America/New_York"   # must match a path under /usr/share/zoneinfo
LOCALE="en_US.UTF-8"

BOOT_SIZE="1024M"
SWAP_SIZE="16G"
ROOT_SIZE="50G"           # home partition takes the rest of the disk

INSTALL_NVIDIA="false"    # "true" to install nvidia-dkms + hooks

# ============================================================
# Internal helpers
# ============================================================
log() { echo -e "\n\033[1;32m==>\033[0m $*"; }
die() { echo -e "\n\033[1;31mERROR:\033[0m $*" >&2; exit 1; }

part_suffix() {
    # nvme/mmcblk devices need a "p" before the partition number
    if [[ "$DISK" == *nvme* || "$DISK" == *mmcblk* ]]; then
        echo "p$1"
    else
        echo "$1"
    fi
}

CHROOT_FLAG="${1:-}"

# Literal defaults, used only to detect whether the config block above
# was left untouched. Keep these in sync with the CONFIG section.
DEFAULT_DISK="/dev/sda"
DEFAULT_HOSTNAME="archbox"
DEFAULT_USERNAME="user"
DEFAULT_TIMEZONE="America/New_York"
DEFAULT_LOCALE="en_US.UTF-8"
DEFAULT_BOOT_SIZE="1024M"
DEFAULT_SWAP_SIZE="16G"
DEFAULT_ROOT_SIZE="50G"
DEFAULT_INSTALL_NVIDIA="false"

# Config gets persisted here so the chroot re-exec sees the same values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/arch-install.conf"

# If a config file already exists (we're in the chroot re-exec, or a
# previous run saved one), load it and skip the interactive prompt.
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi

save_config() {
    cat > "$CONFIG_FILE" <<EOF
DISK="${DISK}"
HOSTNAME="${HOSTNAME}"
USERNAME="${USERNAME}"
TIMEZONE="${TIMEZONE}"
LOCALE="${LOCALE}"
BOOT_SIZE="${BOOT_SIZE}"
SWAP_SIZE="${SWAP_SIZE}"
ROOT_SIZE="${ROOT_SIZE}"
INSTALL_NVIDIA="${INSTALL_NVIDIA}"
EOF
}

prompt_value() {
    # prompt_value "Label" "current value" -> echoes new value (or old if blank)
    local label="$1" current="$2" input
    read -rp "  ${label} [${current}]: " input
    echo "${input:-$current}"
}

configure_interactive() {
    # Only runs in the live-ISO phase, and only if no config was already
    # loaded from a previous save.
    if [[ -f "$CONFIG_FILE" ]]; then
        return
    fi

    local unchanged=false
    if [[ "$DISK" == "$DEFAULT_DISK" && "$HOSTNAME" == "$DEFAULT_HOSTNAME" && \
          "$USERNAME" == "$DEFAULT_USERNAME" && "$TIMEZONE" == "$DEFAULT_TIMEZONE" && \
          "$LOCALE" == "$DEFAULT_LOCALE" && "$BOOT_SIZE" == "$DEFAULT_BOOT_SIZE" && \
          "$SWAP_SIZE" == "$DEFAULT_SWAP_SIZE" && "$ROOT_SIZE" == "$DEFAULT_ROOT_SIZE" && \
          "$INSTALL_NVIDIA" == "$DEFAULT_INSTALL_NVIDIA" ]]; then
        unchanged=true
    fi

    echo
    echo "Current settings:"
    echo "  DISK           = ${DISK}"
    echo "  HOSTNAME       = ${HOSTNAME}"
    echo "  USERNAME       = ${USERNAME}"
    echo "  TIMEZONE       = ${TIMEZONE}"
    echo "  LOCALE         = ${LOCALE}"
    echo "  BOOT_SIZE      = ${BOOT_SIZE}"
    echo "  SWAP_SIZE      = ${SWAP_SIZE}"
    echo "  ROOT_SIZE      = ${ROOT_SIZE}"
    echo "  INSTALL_NVIDIA = ${INSTALL_NVIDIA}"
    echo

    local reply
    if [[ "$unchanged" == true ]]; then
        read -rp "You haven't changed the default values above — would you like to change them? [y/N] " reply
    else
        read -rp "Review/change any of these values before continuing? [y/N] " reply
    fi

    if [[ "$reply" =~ ^[Yy]$ ]]; then
        echo
        echo "Available block devices:"
        lsblk -d -o NAME,SIZE,MODEL
        echo
        DISK=$(prompt_value "Disk (e.g. /dev/sda or /dev/nvme0n1)" "$DISK")
        HOSTNAME=$(prompt_value "Hostname" "$HOSTNAME")
        USERNAME=$(prompt_value "Username" "$USERNAME")
        TIMEZONE=$(prompt_value "Timezone (path under /usr/share/zoneinfo)" "$TIMEZONE")
        LOCALE=$(prompt_value "Locale" "$LOCALE")
        BOOT_SIZE=$(prompt_value "Boot partition size" "$BOOT_SIZE")
        SWAP_SIZE=$(prompt_value "Swap partition size" "$SWAP_SIZE")
        ROOT_SIZE=$(prompt_value "Root partition size (home gets the rest)" "$ROOT_SIZE")

        local nv
        read -rp "  Install Nvidia drivers? [y/N] (current: ${INSTALL_NVIDIA}): " nv
        if [[ "$nv" =~ ^[Yy]$ ]]; then
            INSTALL_NVIDIA="true"
        elif [[ -n "$nv" ]]; then
            INSTALL_NVIDIA="false"
        fi

        echo
        echo "Final settings:"
        echo "  DISK           = ${DISK}"
        echo "  HOSTNAME       = ${HOSTNAME}"
        echo "  USERNAME       = ${USERNAME}"
        echo "  TIMEZONE       = ${TIMEZONE}"
        echo "  LOCALE         = ${LOCALE}"
        echo "  BOOT_SIZE      = ${BOOT_SIZE}"
        echo "  SWAP_SIZE      = ${SWAP_SIZE}"
        echo "  ROOT_SIZE      = ${ROOT_SIZE}"
        echo "  INSTALL_NVIDIA = ${INSTALL_NVIDIA}"
        echo
    fi

    save_config
}

# ============================================================
# PHASE 2: runs inside arch-chroot
# ============================================================
run_chroot_phase() {
    log "Setting locale"
    sed -i "s/^#\(${LOCALE}\)/\1/" /etc/locale.gen
    locale-gen
    echo "LANG=${LOCALE}" > /etc/locale.conf
    export LANG="${LOCALE}"

    log "Setting timezone to ${TIMEZONE}"
    [ -e "/usr/share/zoneinfo/${TIMEZONE}" ] || die "Timezone ${TIMEZONE} not found under /usr/share/zoneinfo"
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    hwclock --systohc --utc

    log "Setting hostname to ${HOSTNAME}"
    echo "${HOSTNAME}" > /etc/hostname
    cat >> /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

    log "Installing base packages"
    pacman -Sy --noconfirm sudo nvim zsh networkmanager pacman-contrib

    log "Enabling multilib"
    sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    pacman -Sy --noconfirm

    log "Enabling fstrim timer (SSD trim)"
    systemctl enable fstrim.timer

    log "Installing CPU microcode"
    CPU_VENDOR=$(grep -m1 -o -E 'GenuineIntel|AuthenticAMD' /proc/cpuinfo)
    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        pacman -S --noconfirm intel-ucode
        UCODE_IMG="intel-ucode.img"
    else
        pacman -S --noconfirm amd-ucode
        UCODE_IMG="amd-ucode.img"
    fi

    log "Setting root password (you will be prompted)"
    passwd

    log "Creating user ${USERNAME} (you will be prompted for their password)"
    useradd -m -g users -G wheel,storage,audio,video,power -s /bin/zsh "${USERNAME}"
    passwd "${USERNAME}"

    log "Enabling wheel group in sudoers"
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

    log "Installing systemd-boot"
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars/ 2>/dev/null || true
    bootctl install

    ROOT_PART="${DISK}$(part_suffix 3)"
    ROOT_PARTUUID=$(blkid -s PARTUUID -o value "${ROOT_PART}")

    mkdir -p /boot/loader/entries
    {
        echo "title   Arch Linux"
        echo "linux   /vmlinuz-linux"
        echo "initrd  /${UCODE_IMG}"
        echo "initrd  /initramfs-linux.img"
        echo -n "options root=PARTUUID=${ROOT_PARTUUID} rw"
        [[ "$INSTALL_NVIDIA" == "true" ]] && echo -n " nvidia-drm.modeset=1"
        echo
    } > /boot/loader/entries/arch.conf

    cat > /boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

    log "Enabling NetworkManager"
    systemctl enable NetworkManager.service

    if [[ "$INSTALL_NVIDIA" == "true" ]]; then
        log "Installing Nvidia drivers"
        pacman -S --noconfirm nvidia-dkms libglvnd nvidia-utils opencl-nvidia \
            lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings

        sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

        mkdir -p /etc/pacman.d/hooks
        cat > /etc/pacman.d/hooks/nvidia.hook <<'EOF'
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
EOF
        mkinitcpio -P
    fi

    log "Chroot phase complete"
}

# ============================================================
# PHASE 1: runs from the live ISO
# ============================================================
run_live_phase() {
    log "Checking UEFI boot mode"
    efivar -l >/dev/null 2>&1 || die "Not booted in UEFI mode (efivar -l returned nothing)"

    configure_interactive

    echo -e "\n\033[1;33mThis will COMPLETELY WIPE ${DISK}\033[0m"
    lsblk "${DISK}"
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || die "Aborted by user"

    log "Partitioning ${DISK}"
    sgdisk --zap-all "${DISK}"
    sgdisk -n 1:0:+"${BOOT_SIZE}" -t 1:ef00 -c 1:boot "${DISK}"
    sgdisk -n 2:0:+"${SWAP_SIZE}" -t 2:8200 -c 2:swap "${DISK}"
    sgdisk -n 3:0:+"${ROOT_SIZE}" -t 3:8300 -c 3:root "${DISK}"
    sgdisk -n 4:0:0    -t 4:8300 -c 4:home "${DISK}"
    partprobe "${DISK}"
    udevadm settle

    BOOT_PART="${DISK}$(part_suffix 1)"
    SWAP_PART="${DISK}$(part_suffix 2)"
    ROOT_PART="${DISK}$(part_suffix 3)"
    HOME_PART="${DISK}$(part_suffix 4)"

    log "Formatting partitions"
    mkfs.fat -F32 "${BOOT_PART}"
    mkswap "${SWAP_PART}"
    swapon "${SWAP_PART}"
    mkfs.ext4 -F "${ROOT_PART}"
    mkfs.ext4 -F "${HOME_PART}"

    log "Mounting partitions"
    mount "${ROOT_PART}" /mnt
    mkdir -p /mnt/boot /mnt/home
    mount "${BOOT_PART}" /mnt/boot
    mount "${HOME_PART}" /mnt/home
    lsblk "${DISK}"

    log "Ranking mirrors (this can take a few minutes)"
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    pacman -Sy --noconfirm pacman-contrib
    rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

    log "Pacstrapping base system"
    pacstrap -K /mnt base linux linux-firmware linux-headers base-devel

    log "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab

    log "Copying installer into new system and chrooting in"
    cp "$0" /mnt/root/arch-install.sh
    chmod +x /mnt/root/arch-install.sh
    cp "$CONFIG_FILE" /mnt/root/arch-install.conf
    arch-chroot /mnt /root/arch-install.sh --chroot

    log "Cleaning up installer script from installed system"
    rm -f /mnt/root/arch-install.sh /mnt/root/arch-install.conf

    log "Unmounting"
    umount -R /mnt

    log "Install complete. Remove the USB and reboot when ready."
    read -rp "Reboot now? [y/N] " DOREBOOT
    [[ "$DOREBOOT" =~ ^[Yy]$ ]] && reboot
}

# ============================================================
# Entry point
# ============================================================
if [[ "$CHROOT_FLAG" == "--chroot" ]]; then
    run_chroot_phase
else
    run_live_phase
fi
