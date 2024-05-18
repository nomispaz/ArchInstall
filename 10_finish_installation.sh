echo "enable services"
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service
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

pacman -Syu --noconfirm --needed linux

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi

#echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

echo "set kernel parameter"
sed -i 's/quiet/quiet loglevel=3 mitigations=auto security=apparmor amd_pstate=passive nvidia_drm.modeset=1/g' /etc/default/grub

echo "generate grub"
grub-mkconfig -o /boot/grub/grub.cfg

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


# sddm set theme to breeze
kwriteconfig6 --file /etc/sddm.conf --group Theme --key Current breeze

# change user from root to normal user
su $user

git clone https://github.com/nomispaz/dotfiles /home/$user/dotfiles
cd /home/$user/dotfiles

# create .config dir since it doesn't exist at that point
mkdir /home/$user/.config
# loop through all folders and files
for program in $(ls -d  *)
do
  # create softlink to config folder for all folders and files unless it is the README
  if [ ! $program == 'README.md' ]; then
    ln -s ~/dotfiles/$program ~/.config/$program
  fi
done

# activate numlock during startup
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key Numlock 0
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key X11LibInputXAccelProfileFlat true

# activate breeze-dark
kwriteconfig6 --file /home/$USER/.config/kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-icon-theme-name breeze-dark
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-icon-theme-name breeze-dark

# disable browserintegration and device-automount
kwriteconfig6 --file /home/$USER/.config/kded5rc --group Module-browserintegrationreminder --key autoload false
kwriteconfig6 --file /home/$USER/.config/kded5rc --group Module-device_automounter --key autoload false

# virtual desktops
kwriteconfig6 --file /home/$USER/.config/kwinrc --group Desktops --key Number 4
kwriteconfig6 --file /home/$USER/.config/kwinrc --group Desktops --key Rows 2

# night color
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key Active true
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key DayTemperature 5400
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key EveningBeginFixed 2130
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key Mode Times
kwriteconfig6 --file /home/$USER/.config/kwinrc --group TabBox --key ActivitesMode 0
kwriteconfig6 --file /home/$USER/.config/kwinrc --group TabBox --key LayoutName sidebar

# dolphin
kwriteconfig6 --file ~/.config/dolphinrc --group General --key ShowFullPath true

echo "Install finished. Restart and run 100_afterinstall.sh