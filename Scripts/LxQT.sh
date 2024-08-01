#!/bin/sh

setup-xorg-base
apk add lxqt-desktop lximage-qt obconf-qt pavucontrol-qt arandr screengrab sddm elogind polkit-elogind gvfs udisks2 papirus-icon-theme font-cantarell
rc-service dbus start
rc-update add dbus
setup-devd udev
rc-update add sddm
rc-update add elogind
rc-service elogind start
reboot
