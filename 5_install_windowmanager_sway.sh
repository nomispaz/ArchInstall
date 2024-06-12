pacman -Syu --noconfirm \
sway \
python-i3ipc \
waybar \
swaybg \
gammastep

echo "Update sway.desktop file"
sed -i 's/Exec=sway/Exec=/usr/local/bin/sway-nvidia.sh/g' /usr/share/wayland-sessions/sway.desktop
