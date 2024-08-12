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
DISPLAYID=$(xrandr | grep " connected" | cut -d' ' -f1)
su user -c 'xrandr --output $DISPLAYID --mode 1920x1080'

# Changing icons
su user -c 'echo "icon_theme=Papirus\ntheme=KDE-Plasma\n[Qt]\nfont=\"Cantarell,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"" >> ~/.config/lxqt/lxqt.conf'
