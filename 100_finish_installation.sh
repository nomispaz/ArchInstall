# sddm set theme to breeze
sudo kwriteconfig6 --file /etc/sddm.conf --group Theme --key Current breeze

# change user from root to normal user
su $user

git clone https://github.com/nomispaz/dotfiles /home/$user/dotfiles
cd /home/$user/dotfiles

# create .config dir since it doesn't exist at that point
mkdir /home/$user/.config
# loop through all folders and files
for program in $(ls -d  *)
do
  # create softlink to config folder for all folders and files unless it is the README
  if [ ! $program == 'README.md' ]; then
    ln -s ~/dotfiles/$program ~/.config/$program
  fi
done

# activate numlock during startup
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key NumLock 0
kwriteconfig6 --file /home/$USER/.config/kcminputrc --group Keyboard --key X11LibInputXAccelProfileFlat true

# activate breeze-dark
kwriteconfig6 --file /home/$USER/.config/kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-3.0/settings --group Settings --key gtk-icon-theme-name breeze-dark
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file /home/$USER/.config/gtk-4.0/settings --group Settings --key gtk-icon-theme-name breeze-dark

# disable browserintegration and device-automount
kwriteconfig6 --file /home/$USER/.config/kded5rc --group Module-browserintegrationreminder --key autoload false
kwriteconfig6 --file /home/$USER/.config/kded5rc --group Module-device_automounter --key autoload false

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
