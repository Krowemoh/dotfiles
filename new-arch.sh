#!/usr/bin/env bash

set -euo pipefail

USERNAME=""
PASSWORD=""
ROOT_PASSWORD=""
NVIDIA=1

DRIVE=""

P1="${DRIVE}p1"
P2="${DRIVE}p2"
P3="${DRIVE}p3"

#
# Update System Clock
#
timedatectl

# Create 3 Partitions
# https://wiki.archlinux.org/title/Parted 
#
parted $DRIVE --script mklabel gpt \
  mkpart "" fat32 1MiB 1025MiB \
  mkpart "" linux-swap 1025MiB 9217MiB \
  mkpart "" ext4 9217MiB 100% \
  set 1 esp on \
  type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709

#
# Create Filesystem
#
mkfs.fat -F 32 "${P1}"
mkswap "${P2}"
mkfs.ext4 "${P3}"

mount "${P3}" /mnt
mount --mkdir "${P1}" /mnt/boot
swapon "${P2}"

#
# Set Up Base Installation
#
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

#
# Initialize System
#
arch-chroot /mnt pacman -Syy --noconfirm efibootmgr grub linux-headers base-devel
arch-chroot /mnt pacman -Syy --noconfirm vim openssh networkmanager
arch-chroot /mnt pacman -Syy --noconfirm git rust sudo

arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
arch-chroot /mnt hwclock --systohc

arch-chroot /mnt systemd-firstboot --locale='en_US.UTF-8'
arch-chroot /mnt locale-gen

arch-chroot /mnt bash -c "echo LANG=en_US.UTF-8 > /etc/locale.conf"

arch-chroot /mnt bash -c "echo november > /etc/hostname"

arch-chroot /mnt systemctl enable networkmanager

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

#
# User Creation
#
arch-chroot /mnt useradd -m -G wheel -s /bin/bash ${USERNAME}
arch-chroot /mnt usermod -aG audio ${USERNAME}
arch-chroot /mnt usermod -aG video ${USERNAME}

arch-chroot /mnt bash -c "echo ${USERNAME}:${PASSWORD} | chpasswd"
arch-chroot /mnt bash -c "echo root:${ROOT_PASSWORD} | chpasswd"

#
# Install Packages
#
arch-chroot /mnt pacman -Syy --noconfirm nvidia-open
arch-chroot /mnt pacman -Syy --noconfirm sway swaybg foot xorg-wayland
arch-chroot /mnt pacman -Syy --noconfirm stow
arch-chroot /mnt pacman -Syy --noconfirm feh sshpass sshfs fish freerdp unzip nginx
arch-chroot /mnt pacman -Syy --noconfirm qbittorrent thunar grimshot mpv leafpad
arch-chroot /mnt pacman -Syy --noconfirm firefox
arch-chroot /mnt pacman -Syy --noconfirm pipewire wireplumber pipewire-pulse pavucontrol

#
# Install AUR Packages
#
arch-chroot /mnt bash -c 'cd /root/ && git clone https://aur.archlinux.org/paru.git'
arch-chroot /mnt bash -c 'cd /root/paru && makepkg -si'

arch-chroot /mnt paru -S --no-confirm tofi
