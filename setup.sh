#!/bin/bash

apk add dialog

root_check() {
    if [ `id -u` -ne 0 ]; then
        echo "Please run this script as root or use sudo!"
        exit
    fi
}

get_user() {
    # The auto guess_name will need work if there's 2 users, make a dialog to select which user
    if [[ $(grep -cE /home/ /etc/passwd) -gt 1 ]]; then
        echo "Finish this later" #Continue pls
    else
        export user=$(grep /home/ /etc/passwd | awk -F':' '{print $1}')
    fi
}

move_location() {
    if ! [[ $(ls /home/$user/ | grep -cE "alpine-setup") -eq 1 ]]; then
        dialog --title "Do you want to move it?" --yesno "Your alpine-setup is not in /home/$user, do you want to move it?" 9 60
        response=$?
        case $response in
            0)
                cp -r ../alpine-setup /home/$user/alpine-setup
                chown $user:$user /home/$user/alpine-setup
                move_loc=1
                ;;
            255)
                exit
                ;;
        esac
    fi
}

edge_releases() {
    dialog --title "Edge Releases" --yesno "Do you want Edge releases?\n\nWARNING:PROCEED WITH CAUTION\nThis will turn the lastest release. bugs, errors, or security vulnerabilities can frequently occur" 9 60
    response=$?
    case $response in
        0)
            # Make a more dynamic version
            alpineversion=$(cat /etc/alpine-release | cut -d "." -f 1-2 | awk '{print "v"$1}')
            sed -i -e '/\/\$alpineversion\// s/^#//' /etc/apk/repositories
            sed -i -e 's/http/https/g' /etc/apk/repositories
            sed -i -e 's/$alpineversion/edge/g' /etc/apk/repositories
            ;;
        255)
            exit
            ;;
    esac
}

final_check() {
    if [[ $move_loc -eq 1 ]]; then
        rm -rf ../alpine-setup
    fi

    if [[ $reboot_value -eq 1 ]]; then
        reboot
    fi
}

deb_based() {
    DISTRO_NAME=$(echo "$DISTRO" | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')

    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt update && sudo apt upgrade && sudo apt install lsb-release"'
    deb_based_cmd=(dialog --separate-output --title "Additional Packages" --backtitle "Additional Packages for $DISTRO_NAME" --checklist "Select options:" 15 50 5)
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
                su $user -c /tmp/mullvad.sh
                ;;
            2)
                cat > /tmp/brave.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list && sudo apt update && sudo apt install -y brave-browser'
                distrobox enter $DISTRO -- distrobox-export --app brave-browser
EOF

                chmod +x /tmp/brave.sh
                su $user -c /tmp/brave.sh
                ;;
            3)
                cat > /tmp/vscode.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt-get install wget gpg && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null &&rm -f packages.microsoft.gpg && sudo apt install apt-transport-https && sudo apt update && sudo apt install -y code'
                distrobox enter $DISTRO -- distrobox-export --app code
EOF

                chmod +x /tmp/vscode.sh
                su $user -c /tmp/vscode.sh
                ;;
            4)
                cat > /tmp/torbrowser.sh << EOF
                #!/bin/bash
                distrobox enter $DISTRO -- bash -c 'sudo apt-get install -y torbrowser-launcher'
                distrobox enter $DISTRO -- distrobox-export --app torbrowser-launcher
EOF

                chmod +x /tmp/torbrowser.sh
                su $user -c /tmp/torbrowser.sh
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
                export DISTRO="ubuntu"
                su $user -c 'distrobox create --name $DISTRO --image ubuntu --home ~/$DISTRO'
                deb_based
                ;;
            2)
                export DISTRO="debian"
                su $user -c 'distrobox create --name $DISTRO --pull -i quay.io/toolbx-images/debian-toolbox:12 --home ~/$DISTRO'
                deb_based
                ;;
            3)
                su $user -c 'distrobox create --name aur --pull -i quay.io/toolbx/arch-toolbox:latest --home ~/aur'
                su $user -c 'distrobox enter aur -- bash -c "sudo -Syu"'
                ;;
        esac
    done
}

mainpage() {
    apk update && apk upgrade

    cmd=(dialog --separate-output --title "Alpine Setup" --backtitle "Alpine Linux Interactive Installer" --checklist "Select options:" 15 65 5)
    options=(1 "Initial Setup (run if u just did setup-alpine)" off
            2 "Pipewire Setup" off    # any option can be set to default to "on"
            3 "LxQt DE" off
            4 "Distrobox" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear

    for choice in $choices
    do
        case $choice in
            1)
                sed -i -e '/\/\v3.20\// s/^#//' /etc/apk/repositories
                apk add doas nano vim sudo
                adduser $user wheel
                doas passwd -l root
                apk update
                ;;
            2)
                ./Scripts/pipewire-setup.sh
                ;;
            3)
                ./Scripts/LxQT.sh
                ;;
            4)
                if ! [ $(apk list --installed | grep -cE 'distrobox|podman|podman-compose') -eq 3 ] && ! [ -f "/etc/local.d/mount-rshared.start" ]; then
                    ./Scripts/Distrobox.sh
                    reboot_value=1
                    final_check
                else
                    distbox
                fi
                ;;
        esac
    done
}

root_check
if ! [[ $(cat /etc/apk/repositories | grep -cE "^http.*/edge/") -ge 1 ]]; then
    edge_releases
fi
get_user
move_location
mainpage
final_check


# Archived Code
# get_user() {
#     # The auto guess_name will need work if there's 2 users, make a dialog to select which user
#     readarray -t lines < .variables
#     export user=${lines[0]#\$USER=}

#     if [[ ${lines[0]} != "\$USER="* ]]; then
#         export user=$(dialog --title "Your user name" --inputbox "Enter your user name:" 10 50 "user" 3>&1 1>&2 2>&3)
#         if [[ $user != "" ]]; then
#             echo -e "\$USER=$user" >> .variables
#         fi
#     fi
# }
