#!/bin/bash
#
# 2_chroot.sh
#
# Script by nomispaz
# Version 1
# Date 23.04.2023

echo "set locales and time"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
timedatectl set-timezone Europe/Berlin
timedatectl set-ntp true

#parallel usage of opensuse tumbleweed --> don't change hwclock
#hwclock --systohc

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "XMGneo15Arch" >> /etc/hostname
locale-gen

echo "add multilib repository"
echo "[multilib]" | tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf

echo "harden installation"
echo "KRNL-5820 disable coredumps"
mkdir -p /etc/systemd/coredump.conf.d/
echo "[Coredump]" | tee -a /etc/systemd/coredump.conf.d/custom.conf
echo "Storage=none" | tee -a /etc/systemd/coredump.conf.d/custom.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf

echo "Improve password hash quality"
sed -i 's/#SHA_CRYPT_MIN_ROUNDS 5000/SHA_CRYPT_MIN_ROUNDS 500000/g' /etc/login.defs 
sed -i 's/#SHA_CRYPT_MAX_ROUNDS 5000/SHA_CRYPT_MAX_ROUNDS 500000/g' /etc/login.defs

echo "predefine host-file for localhost"
echo "127.0.0.1 localhost" | tee -a /etc/hosts
echo "127.0.0.1 XMGneo15Arch" | tee -a /etc/hosts


echo "Install various programs"
pacman -Syu --noconfirm --needed \
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
testdisk

echo "Install nvidia-open"
pacman -Syu --noconfirm --needed \
nvidia-dkms \
nvidia-utils \
nvidia-settings \
nvidia-prime \
lib32-nvidia-utils

echo "Install gaming-tools"
pacman -Syu --noconfirm --needed \
vulkan-icd-loader \
lib32-vulkan-icd-loader \
gamescope \
gamemode \
steam \
wine \
lib32-gnutls \
libretro-mgba \
wine-mono \
wine-gecko \
winetricks \
mangohud

echo "install qemu and libvirt"
pacman -Syu --noconfirm --needed \
virt-manager \
qemu \
qemu-arch-extra \
edk2-ovmf \
bridge-utils \
dnsmasq

echo "clone nomispaz ArchInstall git-repository"
git clone https://github.com/nomispaz/ArchInstall
cd ArchInstall

echo "setup dracut hooks"
cp -r etc/* /etc/
cp -r usr/* /usr/
chmod +x /usr/local/bin/dracut-install.sh
chmod +x /usr/local/bin/dracut-remove.sh

#echo "reinstall kernels to trigger dracut"
#pacman -Syu linux linux-zen
echo "trigger dracut for kernels"
for kernel in /usr/lib/modules/*
do
v_kernel=$(basename "$kernel")
echo $v_kernel
dracut /boot/initramfs-linux.img --force --kver $v_kernel
dracut /boot/initramfs-linux-zen.img --force --kver $v_kernel
done

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux

#echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
echo 'GRUB_DISABLE_OS_PROBER="false"' >> /etc/default/grub

echo "set kernel parameter"
sed -i 's/quiet/quiet mitigations=auto security=apparmor amd_pstate=passive nvidia_drm.modeset=1/g' /etc/default/grub

echo "generate grub"
grub-mkconfig -o /boot/grub/grub.cfg

echo "enable services"
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service
#hardening --> don't enable sshd
#systemctl enable sshd.service
systemctl enable avahi-daemon.service
systemctl enable libvirtd.service
systemctl enable firewalld.service
systemctl enable acpid.service
systemctl enable sddm.service
systemctl enable apparmor.service
systemctl enable clamav-daemon.service
systemctl enable nvidia-powerd.service
systemctl enable chronyd.service
systemctl enable clamav-freshclam.service

firewall-cmd --set-default-zone block

echo "set root password"
passwd

echo "create user and set password"
echo "Enter username: "
read user
useradd -m --create-home $user
usermod -aG sys,wheel,users,rfkill,$user,libvirt $user
passwd $user

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "remove Archinstall folder from chroot"
cd ..
rm -R ArchInstall



exit
