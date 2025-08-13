#!/usr/bin/env bash

USERNAME=""
PASSWORD=""
ROOT_PASSWORD=""

DRIVE=/dev/nvme0n1

#
# Update System Clock
#
timedatectl

# Create 3 Partitions
# https://wiki.archlinux.org/title/Parted 
#
parted $DRIVE --script mkpart "EFI System Partition" fat32 1MiB 1025MiB
parted $DRIVE --script set 1 esp on
parted $DRIVE --script set 1 boot on

parted $DRIVE --script mkpart "Swap Partition" linux-swap 1025MiB 9217MiB

parted $DRIVE --script mkpart "Root Partition" ext4 9217MiB 100%
parted $DRIVE --script type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709

#
# Create Filesystem
#
mkfs.fat -F 32 "${DRIVE}p1"
mkswap "${DRIVE}p2"
mkfs.ext4 "${DRIVE}p3"

mount "${DRIVE}p3" /mnt
mount --mkdir "${DRIVE}p1" /mnt/boot

swapon "${DRIVE}p2"

#
# Set Up Base Installation
#
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

#
# Initialize System
#
arch-chroot /mnt "pacman -Syy efibootmgr grub linux-headers base-devel"
arch-chroot /mnt "pacman -Syy vim openssh networkmanager"
arch-chroot /mnt "pacman -Syy git rust sudo"

arch-chroot /mnt "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
arch-chroot /mnt "hwclock --systohc"

arch-chroot /mnt "systemd-firstboot --locale='en_US.UTF-8'"
arch-chroot /mnt "locale-gen"

arch-chroot /mnt "echo LANG=en_US.UTF-8 > /etc/locale.conf"

arch-chroot /mnt "echo november > /etc/hostname"

arch-chroot /mnt "systemctl enable networkmanager"

arch-chroot /mnt "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"
arch-chroot /mnt "grub-mkconfig -o /boot/grub/grub.cfg"

#
# User Creation
#
arch-chroot /mnt "useradd -m -G wheel -s /bin/bash ${USERNAME}"
arch-chroot /mnt "usermod -aG audio ${USERNAME}"
arch-chroot /mnt "usermod -aG video ${USERNAME}"
arch-chroot /mnt "echo '${USERNAME}:${PASSWORD}' | chpasswd"

arch-chroot /mnt "echo 'root:${ROOT_PASSWORD}' | chpasswd"

#
# Install Packages
#
arch-chroot /mnt "pacman -Syy nvidia-open"
arch-chroot /mnt "pacman -Syy sway swaybg foot xorg-wayland"
arch-chroot /mnt "pacman -Syy stow"
arch-chroot /mnt "pacman -Syy feh sshpass sshfs fish freerdp unzip nginx"
arch-chroot /mnt "pacman -Syy qbittorrent thunar grimshot mpv leafpad" 
arch-chroot /mnt "pacman -Syy firefox"
arch-chroot /mnt "pacman -Syy pipewire wireplumber pipewire-pulse pavucontrol"

#
# Install AUR Packages
#
arch-chroot /mnt "cd /root/ && git clone https://aur.archlinux.org/paru.git"
arch-chroot /mnt "cd /root/pacman && makepkg -si"

arch-chroot /mnt "paru -S --no-confirm tofi"
