#!/bin/bash

apk update && apk upgrade
apk add dialog
clear

if [ `id -u` -ne 0 ]
    then echo "Please run this script as root or use sudo!"
    exit
fi

deb_based() {
    su user -c 'distrobox enter $DISTRO -- bash -c "sudo apt update && sudo apt upgrade && sudo apt install lsb-release"'
    deb_based_cmd=(dialog --separate-output --title "Additional Packages" --backtitle "Additional Packages for $DISTRO" --checklist "Select options:" 15 50 5)
    deb_based_options=(1 "Mullvad Browser" off
            2 "Brave" off
            3 "VsCode" off
            4 "Tor Browser" off)
    deb_based_choices=$("${deb_based_cmd[@]}" "${deb_based_options[@]}" 2>&1 >/dev/tty)
    clear

    for deb_based_choice in $deb_based_choices
    do
        case $deb_based_choice in
            1)
                cat > /tmp/mullvad.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc && echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=\$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list && sudo apt update && sudo apt install -y mullvad-browser'
                distrobox enter $DISTRO -- distrobox-export --app mullvad-browser
EOF

                chmod +x /tmp/mullvad.sh
                su user -c /tmp/mullvad.sh
                ;;
            2)
                cat > /tmp/brave.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list && sudo apt update && sudo apt install -y brave-browser'
                distrobox enter $DISTRO -- distrobox-export --app brave-browser
EOF

                chmod +x /tmp/brave.sh
                su user -c /tmp/brave.sh
                ;;
            3)
                cat > /tmp/vscode.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt-get install wget gpg && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null &&rm -f packages.microsoft.gpg && sudo apt install apt-transport-https && sudo apt update && sudo apt install -y code'
                distrobox enter $DISTRO -- distrobox-export --app code
EOF

                chmod +x /tmp/vscode.sh
                su user -c /tmp/vscode.sh
                ;;
            4)
                cat > /tmp/torbrowser.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt-get install torbrowser-launcher'
                distrobox enter $DISTRO -- distrobox-export --app torbrowser-launcher
EOF
                ;;
        esac
    done
}

distbox() {
    distro_cmd=(dialog --separate-output --title "Distrobox OS" --backtitle "Choose your Distrobox OS" --checklist "Select options:" 15 50 5)
    distro_options=(1 "Ubuntu" off
            2 "Debian" off
            3 "Arch Linux" off)
    distro_choices=$("${distro_cmd[@]}" "${distro_options[@]}" 2>&1 >/dev/tty)
    clear

    for distro_choice in $distro_choices
    do
        case $distro_choice in
            1)
                su user -c 'distrobox create --name ubuntu --image ubuntu --home ~/ubuntu'
                export DISTRO="ubuntu"
                deb_based
                ;;
            2)
                su user -c 'distrobox create --name debian --pull -i quay.io/toolbx-images/debian-toolbox:12 --home ~/debian'
                export DISTRO="debian"
                deb_based
                ;;
            3)
                su user -c 'distrobox create --name aur --pull -i quay.io/toolbx/arch-toolbox:latest --home ~/aur'
                su user -c 'distrobox enter aur -- bash -c "sudo -Syu"'
                ;;
        esac
    done
}

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
            if ! [ $(apk list --installed | grep -cE 'distrobox|podman|podman-compose') -eq 3 ] && ! [ -f "/etc/local.d/mount-rshared.start" ]
                then ./Scripts/Distrobox.sh
                reboot
            fi
            distbox
            ;;
    esac
done
