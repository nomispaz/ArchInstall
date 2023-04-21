#!/bin/bash
#
# preinstall.sh
#
# Script by LordPazifist
# Version 2
# Date 20.04.2023

echo "set keyboard-layout to german"
loadkeys de-latin1

echo "prepare Drives with gparted"

echo "show devices"
lsblk -l

echo "set install drive to: "
read installDrive

echo "run parted"
echo "efi partition"
parted /dev/$installDrive mkpart primary fat32 3MB 515MB
echo "swap partition"
parted /dev/$installDrive mkpart primary linux-swap 515MB 2563MB
echo "root partition"
parted /dev/$installDrive mkpart primary btrfs 2563MB 100%

echo "show devices after partitioning"
lsblk -l

echo "set swap drive: "
read swapDrive

echo "set EFI drive to: "
read efiDrive

# mounte install Drive to /mnt
mount -o noatime,compress=zstd /dev/$installDrive /mnt

#create Subvolumes
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/snapshots
btrfs subvolume create /mnt/var_log

#unmount drive
umount /mnt

#mount subvolumes
#mount -o noatime,compress=zstd,subvol=root /dev/$installDrive /mnt
#mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$installDrive /mnt/home
#mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$installDrive /mnt/.snapshots
#mount --mkdir -o noatime,compress=zstd,subvol=var_logs /dev/$installDrive /mnt/var/log
#mount --mkdir -o noatime,compress=zstd,subvol=data /dev/$installDrive /mnt/data
mount -o noatime,subvol=root /dev/$installDrive /mnt
mount --mkdir -o noatime,subvol=home /dev/$installDrive /mnt/home
mount --mkdir -o noatime,subvol=snapshots /dev/$installDrive /mnt/.snapshots
mount --mkdir -o noatime,subvol=var_logs /dev/$installDrive /mnt/var/log
mount --mkdir -o noatime,subvol=data /dev/$installDrive /mnt/data
mount --mkdir /dev/$efiDrive /mnt/boot/efi
swapon /dev/$swapDrive

#update keyrings to prevent packages failing to install
sudo pacman --noconfirm -S archlinux-keyring

#Base install (with standard and zen-kernel)
pacstrap /mnt base base-devel btrfs-progs efibootmgr git grep grub \
intel-ucode amd-ucode iwd linux-firmware linux linux-zen linux-headers \
linux-zen-headers nano networkmanager sudo xdg-user-dirs \
xdg-utils xf86-input-synaptics archlinux-keyring pacman-contrib \
--noconfirm

genfstab -U /mnt > /mnt/etc/fstab
#remark: genfstab includes subvolid into fstab. Might create problems during rollback with snapper.

#preinstall finished. Continue with arch-chroot
