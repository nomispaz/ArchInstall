bootctl install

mkdir -p /ostree/repo
ostree --repo=/ostree/repo init --mode=archive-z2

mkdir /tmp/buildroot
pacstrap -c -G -M /tmp/buildroot base linux linux-firmware systemd ostree

rm -rf /tmp/buildroot/{dev,proc,sys,run,tmp,var/tmp,mnt,media,lost+found}
mv /tmp/buildroot/etc /tmp/buildroot/usr/etc

ROOT=/tmp/buildroot
if compgen -G "$ROOT/lib/modules/*" >/dev/null; then
  KVER=$(basename "$ROOT"/lib/modules/* | head -n1)
else
  echo "ERROR: no /lib/modules found in buildroot"
  exit 1
fi

mkdir -p "$ROOT/usr/lib/modules/$KVER"

# copy kernel image(s) and initramfs - robust matching
# prefer vmlinuz-* and initrd.img-* or initramfs-*
set +e
KERNEL_SRC=$(ls "$ROOT"/boot/vmlinuz-* 2>/dev/null | head -n1)
INITRD_SRC=$(ls "$ROOT"/boot/initrd.img-* 2>/dev/null | head -n1)
if [[ -z "$INITRD_SRC" ]]; then
  INITRD_SRC=$(ls "$ROOT"/boot/initramfs-* 2>/dev/null | head -n1)
fi
set -e

if [[ -n "$KERNEL_SRC" && -f "$KERNEL_SRC" ]]; then
  cp -a "$KERNEL_SRC" "$ROOT/usr/lib/modules/$KVER/vmlinuz"
else
  echo "ERROR: kernel not found under $ROOT/boot"
  exit 1
fi

if [[ -n "$INITRD_SRC" && -f "$INITRD_SRC" ]]; then
  cp -a "$INITRD_SRC" "$ROOT/usr/lib/modules/$KVER/initramfs.img"
else
  echo "WARNING: initramfs not found under $ROOT/boot; continuing (you may need to generate it)"
fi

# remove boot artifacts to avoid confusion (but keep /boot directory)
rm -f "$ROOT"/boot/vmlinuz-* "$ROOT"/boot/initrd.img-* "$ROOT"/boot/initramfs-*

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
