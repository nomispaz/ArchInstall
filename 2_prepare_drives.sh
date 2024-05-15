lsblk -l

echo "set install drive to: "
read installDrive

#echo "Create partition table (only do this if no partition table exists!)"
#parted /dev/$installDrive mklabel gpt

#echo "Create partitions"
#parted /dev/$installDrive mkpart primary fat32 3MB 515MB
#parted /dev/$installDrive mkpart primary btrfs 2563MB 100%

lsblk -l

echo "set EFI drive to: "
read efiDrive

echo "set root drive to: "
read rootDrive

#echo "format partitions"
#mkfs.vfat -F 32 /dev/$efiDrive
#mkfs.btrfs /dev/$rootDrive

echo "mount installDrive to /mnt"
mount -o noatime,compress=zstd /dev/$rootDrive /mnt

#echo "create subvolumes"
#btrfs subvolume create /mnt/root
#btrfs subvolume create /mnt/home
#btrfs subvolume create /mnt/data
#btrfs subvolume create /mnt/snapshots
#btrfs subvolume create /mnt/var_log
#btrfs subvolume create /mnt/var_cache

#echo "subolume for swap-file"
#btrfs subvolume create /mnt/swap

echo "unmount installDrive"
umount /mnt

echo "mount subvolumes"
mount -o noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt
mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/home
mount --mkdir -o noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/data
mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/.snapshots
mount --mkdir -o noatime,compress=zstd,subvol=var_log /dev/$rootDrive /mnt/var/log
mount --mkdir -o noatime,compress=zstd,subvol=var_cache /dev/$rootDrive /mnt/var/cache

echo "mount and create swap-partition and file"
mount --mkdir -o noatime,compress=zstd,subvol=swap /dev/$rootDrive /mnt/swap
btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

mount --mkdir /dev/$efiDrive /mnt/boot/efi