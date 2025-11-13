bootctl install

mkdir -p /ostree/repo
ostree --repo=/ostree/repo init --mode=archive-z2

mkdir /tmp/buildroot
pacstrap -c -G -M /tmp/buildroot base linux linux-firmware systemd ostree

rm -rf /tmp/buildroot/{dev,proc,sys,run,tmp,var/tmp,mnt,media,lost+found}
mv /tmp/buildroot/etc /tmp/buildroot/usr/etc

ostree --repo=/ostree/repo commit \
  --branch=archlinux/stable \
  --subject="Initial Arch Linux base" \
  --body="Base install with pacstrap" \
  /tmp/buildroot

mkdir -p /ostree/deploy

ostree admin init-fs /ostree/deploy
ostree admin os-init archlinux
ostree admin deploy --os=archlinux archlinux/stable

bootctl update
