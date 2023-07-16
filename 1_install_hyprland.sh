#!/bin/bash
#
# 1_install.sh
#
# Script by nomispaz
# Version 2
# Date 23.04.2023

echo "set keyboard-layout to german"
loadkeys de-latin1

echo "prepare Drives with parted"

echo "show devices"
lsblk -l

echo "set install drive to: "
read installDrive

#echo "if no gpt Partition-Table exists, create it. If it exists, don'e overwrite --> commented"
#parted /dev/$installDrive mklabel gpt

#echo "run parted"
#echo "efi partition"
#parted /dev/$installDrive mkpart primary fat32 3MB 515MB

#echo "root partition"
#parted /dev/$installDrive mkpart primary btrfs 2563MB 100%

echo "show devices after partitioning"
lsblk -l

echo "set EFI drive to: "
read efiDrive

echo "set root drive to: "
read rootDrive

echo "format partitions"
mkfs.vfat -F 32 /dev/$efiDrive
mkfs.btrfs /dev/$rootDrive

echo "mount installDrive to /mnt"
mount -o noatime,compress=zstd /dev/$rootDrive /mnt

echo "create subvolumes"
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/snapshots
btrfs subvolume create /mnt/var_log
btrfs subvolume create /mnt/var_cache

#swapfile
btrfs subvolume create /mnt/swap 

echo "unmount installDrive"
umount /mnt

echo "mount subvolumes"
mount -o noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt
mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/home
mount --mkdir -o noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/data
mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/.snapshots
mount --mkdir -o noatime,compress=zstd,subvol=var_log /dev/$rootDrive /mnt/var/log
mount --mkdir -o noatime,compress=zstd,subvol=var_cache /dev/$rootDrive /mnt/var/cache

#swapfile
mount --mkdir -o noatime,compress=zstd,subvol=swap /dev/$rootDrive /mnt/swap
btrfs filesystem mkswapfile --size 4g --uuid clear /swap/swapfile
swapon /swap/swapfile

mount --mkdir /dev/$efiDrive /mnt/boot/efi

pacstrap /mnt \
base \
base-devel \
btrfs-progs \
efibootmgr \
git \
grep \
grub \
amd-ucode \
nano \
openssh \
htop \
wget \
sudo \
xdg-user-dirs \
xdg-utils \
xf86-input-synaptics \
archlinux-keyring \
pacman-contrib \
iwd \
networkmanager \
wireless_tools \
wpa_supplicant \
smartmontools \
xdg-utils \
pipewire \
pipewire-alsa \
pipewire-jack \
pipewire-pulse \
gst-plugin-pipewire \
libpulse \
wireplumber \
linux \
linux-firmware \
linux-headers \
linux-zen \
linux-zen-headers \
xorg-xwayland \
dolphin \
ffmpegthumbs \
breeze-icons \
ark \
egl-wayland \
acpi \
acpi_call \
acpid \
alsa-firmware \
alsa-plugins \
alsa-utils \
apparmor \
ark \
bluez \
bluez-utils \
clamav \
cups \
polkit \
exfatprogs \
file-roller \
firefox \
firewalld \
ghostscript \
hplip \
hwdetect \
mtpfs \
hwinfo \
man \
nfs-utils \
ntfs-3g \
os-prober \
dkms \
xf86-video-amdgpu  \
rkhunter \
rsync \
unrar \
unzip \
wpa_supplicant \
xdg-desktop-portal \
xdg-desktop-portal-hyprland \
zsh \
zsh-autosuggestions \
zsh-completions \
zsh-history-substring-search \
zsh-syntax-highlighting \
meld \
qt5-wayland \
dolphin \
kate \
gparted \
sddm \
screenfetch \
dracut \
dkms \
cpupower \
snapper \
hyprland \
qt5ct \
libva \
network-manager-applet \
brightnessctl \
nerd-fonts \
otf-font-awesome \
wofi \
waybar \
xdg-desktop-portal \
xdg-desktop-portal-gtk \
xdg-desktop-portal-hyprland \
pamixer \
pavucontrol \
dunst \
swaylock \
libqalculate \
polkit-kde-agent \
libqalculate \
kitty \
swaybg \
ranger \
w3mimgdisplay \
xsel \
snap-pac \
chrony \
arch-audit \
lynis \
blueman


genfstab -U /mnt > /mnt/etc/fstab
cp 2_chroot.sh /mnt

echo "Next steps: Enter chroot. After that, run chmod +x 2_install.sh and then ./2_install.sh"
#arch-chroot /mnt
