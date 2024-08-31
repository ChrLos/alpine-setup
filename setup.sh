#!/bin/bash

apk add dialog
export alpineversion=$(cat /etc/alpine-release | cut -d "." -f 1-2 | awk '{print "v"$1}')

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
                chown -R $user:$user /home/$user/alpine-setup
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
            sed -i -e "/\/$alpineversion\// s/^#//" /etc/apk/repositories
            sed -i -e "s/http:/https:/g" /etc/apk/repositories
            sed -i -e "s/$alpineversion/edge/g" /etc/apk/repositories
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

programchoices() {
    choices=()
    dynamic_choice=()
    ((i = 0))
    dynamic_choice+="case \$pickings in\n"

    for ((p = 0; p < ${#checkboxes[@]}; p+=2))
    do
        ((i+=1))
        choices+=("${i}" "${checkboxes[p]}" "OFF")
        dynamic_choice+="${i})\n${checkboxes[p+1]}\n;;\n"
    done

    dynamic_choice+="esac"
}

mainui() {
    cmd=(dialog --separate-output --title "$title" --backtitle "$backtitle" --checklist "Select options:" 15 65 5)
    picking=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)
}

command() {
    for pickings in $picking
    do
        eval "$(echo -e "$dynamic_choice")"
    done
}

deb_based() {
    source ./Scripts/Distrobox/deb_based.sh

    DISTRO_NAME=$(echo "$DISTRO" | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt update && sudo apt upgrade && sudo apt install lsb-release"'

    title="Additional Packages"
    backtitle="Additional Packages for $DISTRO_NAME"

    local -a checkboxes
    checkboxes+=("Mullvad Browser" "mullvad_browser")
    checkboxes+=("Brave" "brave")
    checkboxes+=("VsCode" "vscode")
    checkboxes+=("Tor Browser" "tor_browser")

    programchoices && mainui && command
}

distbox() {
    source ./Scripts/Distrobox/distbox_os.sh

    title="Distrobox OS"
    backtitle="Choose your Distrobox OS"

    local -a checkboxes
    checkboxes+=("Ubuntu" "os_ubuntu")
    checkboxes+=("Debian" "os_debian")
    checkboxes+=("Arch Linux" "os_arch")

    programchoices && mainui && command
}

homepage() {
    source ./Scripts/homepage.sh
    
    apk update && apk upgrade

    title="Alpine Setup"
    backtitle="Alpine Linux Interactive Installer"

    local -a checkboxes
    checkboxes+=("Initial Setup" "initial_setup")
    checkboxes+=("Pipewire Setup" "pipewire")
    checkboxes+=("LxQt DE" "lxqt")
    checkboxes+=("Distrobox" "distrobox")

    programchoices && mainui && command
}

root_check
if ! [[ $(cat /etc/apk/repositories | grep -cE "^http.*/edge/") -ge 1 ]]; then
    edge_releases
fi
get_user
move_location
homepage
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
