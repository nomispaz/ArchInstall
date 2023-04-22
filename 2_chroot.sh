#!/bin/bash
#
# 2_chroot.sh
#
# Script by nomispaz
# Version 1
# Date 22.04.2023

echo "set locales and time"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
timedatectl set-timezone Europe/Berlin
timedatectl set-ntp true
hwclock --systohc

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "XMGneo15Arch" >> /etc/hostname
locale-gen

echo "[multilib]" | tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf

echo "Install various programs"
pacman -Syu --noconfirm \
calibre \
chromium \
clipgrab \
discord \
keepassxc \
obs-studio \
thunderbird \
veracrypt \
vlc \
flatpak \
firelight \
testdisk \
freeplane

echo "Install nvidia-open"
pacman -Syu --noconfirm \
nvidia-open-dkms \
nvidia-utils \
nvidia-settings \
nvidia-prime \
lib32-nvidia-utils

echo "Install gaming-tools"
pacman -Syu --noconfirm \
vulkan-icd-loader \
lib32-vulkan-icd-loader \
gamescope \
gamemode \
steam \
lutris \
wine \
lib32-gnutls \
libretro-mgba \
wine-mono \
wine-gecko \
winetricks

echo "install qemu and libvirt"
pacman -Syu --noconfirm \
virt-manager \
qemu \
qemu-arch-extra \
edk2-ovmf \
bridge-utils \
dnsmasq

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux

#echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
echo 'GRUB_DISABLE_OS_PROBER="false"' >> /etc/default/grub

echo "generate grub"
grub-mkconfig -o /boot/grub/grub.cfg

echo "enable services"
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service.service
systemctl enable sshd.service
systemctl enable avahi-daemon.service
systemctl enable libvirtd.service
systemctl enable firewalld.service
systemctl enable acpid.service
systemctl enable sddm.service
systemctl enable apparmor.service
systemctl enable dmks.service
firewall-cmd --set-default-zone block

echo "set root password"
passwd

echo "create user and set password"
echo "Enter username: "
read user
useradd -m $user
usermod -aG sys,wheel,users,rfkill,$user,libvirt $user
passwd $user

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers