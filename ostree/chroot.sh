bootctl install

mkdir -p /ostree/repo
ostree --repo=/ostree/repo init --mode=archive-z2

mkdir /tmp/buildroot
pacstrap -c -G -M /tmp/buildroot base linux linux-firmware systemd ostree

rm -rf /tmp/buildroot/{dev,proc,sys,run,tmp,var/tmp,mnt,media,lost+found}

ostree --repo=/ostree/repo commit \
  --branch=archlinux/stable \
  --subject="Initial Arch Linux base" \
  --body="Base install with pacstrap" \
  /tmp/buildroot

mv /tmp/buildroot/etc /tmp/buildroot/usr/etc

ostree admin init-fs /ostree/deploy
ostree admin os-init archlinux
ostree admin deploy --os=archlinux archlinux/stable
