arted /dev/vda mklabel gpt
parted /dev/vda mkpart ESP fat32 1MiB 513MiB
parted /dev/vda set 1 esp on
parted /dev/vda mkpart primary ext4 513MiB 100%

mkfs.fat -F32 /dev/vda1
mkfs.ext4 /dev/vda2

mount /dev/vda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi

pacstrap /mnt base base-devel git ostree arch-install-scripts
mkdir -p /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt

arch-chroot /mnt

