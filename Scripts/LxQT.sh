#!/bin/sh

setup-xorg-base
apk add lxqt-desktop lximage-qt obconf-qt pavucontrol-qt arandr screengrab sddm elogind polkit-elogind gvfs udisks2 papirus-icon-theme font-cantarell
rc-service dbus start
rc-update add dbus
setup-devd udev
rc-update add sddm
rc-update add elogind
rc-service elogind start

# Changing Screen Resolution
#DISPLAYID=$(xrandr | grep " connected" | cut -d' ' -f1)
#su user -c 'xrandr --output $DISPLAYID --mode 1920x1080'

# Changing icons and themes
su user -c 'mkdir -p /home/user/.config/lxqt/'
cat > /home/user/.config/lxqt/lxqt.conf <<EOF
[General]
__userfile__=true
icon_theme=Papirus
theme=KDE-Plasma
[Qt]
font=\"Cantarell,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"
EOF
chown $user:$user /home/user/.config/lxqt/lxqt.conf
