# activate numlock during startup
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key Numlock 0
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key X11LibInputXAccelProfileFlat true

# activate breeze-dark
kwriteconfig6 --file /home/$USER/.config/kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-icon-theme-name breeze-dark
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-icon-theme-name breeze-dark




# virtual desktops
kwriteconfig6 --file /home/$USER/.config/kwinrc --group Desktops --key Number 4
kwriteconfig6 --file /home/$USER/.config/kwinrc --group Desktops --key Rows 2

# night color
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key Active true
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key DayTemperature 5400
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key EveningBeginFixed 2130
kwriteconfig6 --file /home/$USER/.config/kwinrc --group NightColor --key Mode Times
kwriteconfig6 --file /home/$USER/.config/kwinrc --group TabBox --key ActivitesMode 0
kwriteconfig6 --file /home/$USER/.config/kwinrc --group TabBox --key LayoutName sidebar

# dolphin
kwriteconfig6 --file ~/.config/dolphinrc --group General --key ShowFullPath true

