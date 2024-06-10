echo "renew clamav database"
sudo freshclam

echo "add flatpak-repo"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "run rkhunter"
sudo rkhunter --update
sudo rkhunter --propupd
#c for check q for skip keypress
sudo rkhunter -c -sk

# Function to configure snapper
function configure_snapper
    sudo umount /.snapshots
    sudo rm -r /.snapshots
    sudo snapper -c root create-config /

    # Define the path to fstab
    set FSTAB_FILE "/etc/fstab"

    # Check if running in Fish shell
    if test -n "$fish_version"
        echo "Running in Fish shell"
        # Grep for the Btrfs root subvolume line and extract the UUID, ensuring it contains 'subvol=root' or 'subvol=/root'
        set rootUUID (grep -E '^[^#].*\s/\s.*btrfs.*subvol=(/)?root' $FSTAB_FILE | awk '{print $1}' | sed 's/^UUID=//')
    else
        echo "Not running in Fish shell"
        # Use Bash syntax for setting rootUUID
        rootUUID=$(grep -E '^[^#].*\s/\s.*btrfs.*subvol=(/)?root' /etc/fstab | awk '{print $1}' | sed 's/^UUID=//')
    end

    # Ensure the UUID is fetched correctly
    if test -z "$rootUUID"
        echo "Failed to find the UUID of the Btrfs root subvolume"
        return 1
    end

    # Mount the snapshots subvolume
    sudo mount -o subvol=snapshots UUID=$rootUUID /.snapshots
end

# Run the function to configure snapper
configure_snapper

# set firewall zone
sudo firewall-cmd --set-default-zone block

# activate emacs daemon
systemctl --user enable --now emacs
systemctl --user start --now emacs
