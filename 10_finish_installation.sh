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

git clone https://github.com/nomispaz/dotfiles /home/$user/dotfiles
cd /home/$user/dotfiles
# loop through all folders and files
for program in $(ls -d  *)
do
  # create softlink to config folder for all folders and files unless it is the README
  if [ ! $program == 'README.md' ]; then
    ln -s ~/dotfiles/$program ~/.config/$program
  fi
done