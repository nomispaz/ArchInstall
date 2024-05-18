echo "set locales and time"

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
#timedatectl set-timezone Europe/Berlin
#timedatectl set-ntp true

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

echo "clone nomispaz ArchInstall git-repository"
git clone https://github.com/nomispaz/ArchInstall
cd ArchInstall

echo "setup dracut hooks"
cp -r etc/* /etc/
cp -r usr/* /usr/
chmod +x /usr/local/bin/dracut-install.sh
chmod +x /usr/local/bin/dracut-remove.sh

cd /