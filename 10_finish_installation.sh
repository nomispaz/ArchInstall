echo "enable services"
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable cups.service
# don'T enable avahi not necessary in my network --> hardening the installation
systemctl disable avahi-daemon.service
systemctl enable libvirtd.service
systemctl enable firewalld.service
systemctl enable acpid.service
systemctl enable sddm.service
systemctl enable apparmor.service
systemctl enable clamav-daemon.service
systemctl enable nvidia-powerd.service
systemctl enable chronyd.service
# enable snapper automatic cleanup
systemctl enable snapper-cleanup.timer

# create freshclam log and change ownership to clamav user. Otherwise the service cannot start
touch /var/log/clamav/freshclam.log
chown clamav:clamav /var/log/clamav/freshclam.log
systemctl enable clamav-freshclam.service

firewall-cmd --set-default-zone block

pacman -Syu --noconfirm --needed linux

echo "install grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi

#echo "add nvidia-drm.modeset=1 and uncomment GRUB_DISABLE_OS_PROBER
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

echo "set kernel parameter"
sed -i 's/quiet/loglevel=3 mitigations=auto security=apparmor amd_pstate=active nvidia_drm.modeset=1 fbdev=1/g' /etc/default/grub

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

echo "Install finished. Restart and run 100_afterinstall.sh. Then restart again.
