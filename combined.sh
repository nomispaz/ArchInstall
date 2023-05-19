#!/bin/bash
#
# 
#
# Script by nomispaz
# Version 1
# Date 19.05.2023

echo "set keyboard-layout to german"
loadkeys de-latin1

echo "prepare Drives with parted"

echo "show devices"
lsblk -l

echo "set install drive to: "
read installDrive

echo "if no gpt Partition-Table exists, create it. If it exists, don'e overwrite --> commented"
#parted /dev/$installDrive mklabel gpt

echo "run parted"
echo "efi partition"
parted /dev/$installDrive mkpart primary fat32 3MB 515MB

echo "swap partition"
parted /dev/$installDrive mkpart primary linux-swap 515MB 2563MB

echo "root partition"
parted /dev/$installDrive mkpart primary btrfs 2563MB 100%

echo "show devices after partitioning"
lsblk -l

echo "set EFI drive to: "
read efiDrive

echo "set swap drive: "
read swapDrive

echo "set root drive to: "
read rootDrive

echo "format partitions"
mkfs.vfat -F 32 /dev/$efiDrive
mkswap /dev/$swapDrive
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

echo "unmount installDrive"
umount /mnt

echo "mount subvolumes"
mount -o noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt
mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/home
mount --mkdir -o noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/data
mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/.snapshots
mount --mkdir -o noatime,compress=zstd,subvol=var_log /dev/$rootDrive /mnt/var/log
mount --mkdir -o noatime,compress=zstd,subvol=var_cache /dev/$rootDrive /mnt/var/cache

mount --mkdir /dev/$efiDrive /mnt/boot/efi
swapon /dev/$swapDrive

pacstrap /mnt \
base \
base-devel \
btrfs-progs \
efibootmgr \
git \
grep \
grub \
intel-ucode \
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
plasma-meta \
kwrite \
dolphin \
ark \
plasma-wayland-session \
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
exfatprogs \
file-roller \
firefox \
firewalld \
ghostscript \
hplip \
hwdetect \
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
xorg-server \
xorg-xdpyinfo \
xorg-xinput \
xorg-xkill \
xorg-xlsclients \
xorg-xrandr \
xorg-xinit \
zsh \
zsh-autosuggestions \
zsh-completions \
zsh-history-substring-search \
zsh-syntax-highlighting \
kompare \
qt5-wayland \
spectacle \
breeze-gtk \
dolphin \
kate \
kcalc \
kde-gtk-config \
khotkeys \
kinfocenter \
kinit \
konsole \
kscreen \
partitionmanager \
plasma-desktop \
plasma-disks \
plasma-nm \
plasma-pa \
plasma-systemmonitor \
plasma-wayland-session \
powerdevil \
sddm-kcm \
screenfetch \
dracut \
dkms \
cpupower \
snapper \
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
testdisk \
freeplane \
nvidia-open-dkms \
nvidia-utils \
nvidia-settings \
nvidia-prime \
lib32-nvidia-utils \
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
winetricks \
virt-manager \
qemu \
qemu-arch-extra \
edk2-ovmf \
bridge-utils \
dnsmasq \
--noconfirm

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<END

echo "set locales and time"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
timedatectl set-timezone Europe/Berlin
timedatectl set-ntp true
hwclock --systohc

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "XMGneo15Arch" >> /etc/hostname
locale-gen

echo "add multilib repository"
echo "[multilib]" | tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf

echo "clone nomispaz ArchInstall git-repository"
git clone https://github.com/nomispaz/ArchInstall
cd ArchInstall/

echo "setup dracut hooks"
cp -r etc/* /etc/
cp -r usr/* /usr/
chmod +x /usr/local/bin/dracut-install.sh
chmod +x /usr/local/bin/dracut-remove.sh

cd ..

echo "install yay and tuxedo-packages"
pacman -Syu --noconfirm --needed git base-devel go
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si

cd ..

yay tuxedo-keyboard-dkms
yay tuxedo-keyboard-ite-dkms
yay tuxedo-control-center

echo "trigger dracut for kernels"
for kernel in /usr/lib/modules/*
do
v_kernel = $(basename "$kernel")
dracut /boot/initramfs-linux.img --force --kver $v_kernel
dracut /boot/initramfs-linux-zen.img --force --kver $v_kernel

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux

#echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
echo 'GRUB_DISABLE_OS_PROBER="false"' >> /etc/default/grub

echo "set kernel parameter"
sed -i 's/quiet/quiet mitigations=auto security=apparmor amd_pstate=passive/g' /etc/default/grub

echo "generate grub"
grub-mkconfig -o /boot/grub/grub.cfg

echo "enable services"
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service
systemctl enable sshd.service
systemctl enable avahi-daemon.service
systemctl enable libvirtd.service
systemctl enable firewalld.service
systemctl enable acpid.service
systemctl enable sddm.service
systemctl enable apparmor.service
systemctl enable clamav-daemon.service

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

echo "remove Archinstall and yay folder from chroot"
cd ..
rm -R ArchInstall
rm -R yay

#end chroot
END
