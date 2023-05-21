#!/bin/bash
#
# 3_afterinstal.sh
#
# Script by nomispaz
# Version 1
# Date 22.04.2023

#echo "install yay and tuxedo-packages"
#pacman -Syu --noconfirm --needed git base-devel go
#git clone https://aur.archlinux.org/yay.git
#cd yay
#makepkg -si

#cd ..

#yay tuxedo-keyboard-dkms
#yay tuxedo-keyboard-ite-dkms
#yay tuxedo-control-center

echo "copy config files to new user"
mkdir -p /home/$USER/.config/
cp -r .config/* /home/$USER/.config/
cp home/.zshrc /home/$USER/
cp home/.gtkrc-2.0 /home/$USER/

#enable wayland in different programs
mkdir -p /home/$USER/.config/environment.d/
echo "MOZ_ENABLE_WAYLAND=1" >> /home/$USER/.config/environment.d/envvars.conf

echo "renew clamav database"
sudo freshclam

echo "add flatpak-repo"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "activate zsh shell"
#to be able to chsh
echo "enter user password"
chsh -s /bin/zsh
echo "enter root password"
sudo chsh -s /bin/zsh

echo "run rkhunter"
sudo rkhunter --update
sudo rkhunter --propupd
#c for check q for skip keypress
sudo rkhunter -c -sk

# configure snapper
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
#read UUID of rootpartition and write into variable
rootUUID=$(cat /etc/fstab | sed -nE 's/.*UUID=(.*)+ \/.*+root.*$/\1/p')
sudo mount -o subvol=snapshots UUID=$rootUUID /.snapshots
sudo chmod 750 /.snapshots/
