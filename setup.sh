#!/bin/bash

apk update && apk upgrade
apk add dialog bash
clear

if [ `id -u` -ne 0 ]
    then echo "Please run this script as root or use sudo!"
    exit
fi

cmd=(dialog --separate-output --title "Alpine Setup" --backtitle "Alpine Linux Interactive Installer" --checklist "Select options:" 15 50 5)
options=(1 "Pipewire Setup" off    # any option can be set to default to "on"
         2 "LxQt DE" off
         3 "Distrobox" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices
do
    case $choice in
        1)
            ./Scripts/pipewire-setup.sh
            ;;
        2)
            ./Scripts/LxQT.sh
            ;;
        3)
            ./Scripts/Distrobox.sh
            ;;
    esac
done
