#!/bin/bash
#
# install.sh
#
# Script by LordPazifist
# Version 1
# Date 20.04.2023

echo "Enter chroot"

arch-chroot /mnt

echo "set locales and time"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
timedatectl set-timezone Europe/Berlin
sudo timedatectl set-ntp true
sudo hwclock --systohc

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de" >> /etc/vconsole.conf
echo "XMGneo15Arch" >> /etc/hostname
locale-gen

#update keyrings to prevent packages failing to install
sudo pacman --noconfirm -S archlinux-keyring

#kde with amd igpu
pacman -Syu --noconfirm acpi acpi_call acpid alsa-firmware alsa-plugins alsa-utils \
apparmor ark bluez bluez-utils clamav cups exfatprogs file-roller firefox firewalld \
ghostscript hplip hwdetect hwinfo iptables-nft ipw2100-fw ipw2200-fw man nfs-utils \
ntfs-3g os-prober pipewire pipewire-alsa dkms xf86-video-amdgpu  \
pipewire-jack pipewire-pulse rkhunter rsync unrar unzip wget wpa_supplicant xdg-desktop-portal \
xorg-server xorg-xdpyinfo xorg-xinput xorg-xkill xorg-xlsclients xorg-xrandr \
zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting \
calibre chromium clipgrab discord keepassxc kompare notepadqq obs-studio qt5-wayland spectacle \
thunderbird veracrypt vlc breeze-gtk dolphin kate kcalc kde-gtk-config khotkeys kinfocenter kinit \
konsole kscreen partitionmanager plasma-desktop plasma-disks plasma-nm plasma-pa plasma-systemmonitor \
plasma-wayland-session powerdevil sddm-kcm screenfetch

#nvidia
pacman -Syu --noconfirm nvidia-open-dkms nvidia-utils nvidia-settings nvidia-prime lib32-nvidia-utils

#gaming
pacman -S --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader \
gamescope gamemode steam lutris wine lib32-gnutls libretro-mgba wine-mono winetricks

#additional qemu
pacman -S --noconfirm virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux

echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
nano /etc/default/grub

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
firewall-cmd --set-default-zone block

useradd -m simonheise
usermod -aG sys,wheel,users,rfkill,simonheise,libvirt simonheise
passwd
passwd simonheise

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
firewall-cmd --set-default-zone block

useradd -m simonheise
usermod -aG sys,wheel,users,rfkill,simonheise,libvirt simonheise

echo "set root password"
passwd

echo "set user password"
passwd simonheise

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
