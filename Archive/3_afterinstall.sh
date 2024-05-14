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
sudo sed -i 's/NUMBER_LIMIT="50"/NUMBER_LIMIT="10"/g' /etc/snapper/configs/root
sudo sed -i 's/NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/g' /etc/snapper/configs/root

#nmcli con mod SiSaFS7 connection.autoconnect true
#makepkg -q >> PKGBUILD
#makepkg -sri

#update fstab
# tumbleweed data
#UUID=7eda7945-48f8-4bda-949b-d01460d66b7b  /data                   btrfs  subvol=/@/data                0  0

#UUID=5478d2bc-1d51-467f-b488-87fed42efffb  /mnt/nvme2              btrfs  defaults                      0  0

#UUID=30039aa4-8303-4e90-a82c-4ab549f048f6  /mnt/nvme2_xfs          xfs    defaults,noatime              0  0
