pacstrap /mnt \
base \
base-devel \
btrfs-progs \
efibootmgr \
linux \
linux-firmware \
linux-headers \
archlinux-keyring \
pacman-contrib \
sudo \
grub \
dracut \
os-prober \
xf86-input-synaptics \
amd-ucode \
openssh \
iwd \
networkmanager \
wireless_tools \
wpa_supplicant \
smartmontools \
neovim \
emacs \
htop \
git \
grep \
xdg-utils \
xdg-user-dirs \
wget \
blueman \
alacritty \
fish \
snapper \
snap-pac \
firefox \
pipewire \
pipewire-alsa \
pipewire-jack \
pipewire-pulse \
gst-plugin-pipewire \
libpulse \
wireplumber
apparmor \
clamav \
firewalld \
rkhunter \
chrony

genfstab -U /mnt > /mnt/etc/fstab
cp *.sh /mnt

echo "Next steps: Enter chroot. After that, run chmod +x <script>.sh to continue"
