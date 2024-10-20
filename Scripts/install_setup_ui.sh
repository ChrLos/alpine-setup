#!/bin/bash

export alpineversion=$(cat /etc/alpine-release | cut -d "." -f 1-2 | awk '{print "v"$1}')

check_parent_process() {
    # Get the parent process ID
    parent_pid=$(cat /proc/$$/status | grep -w PPid | awk '{print $2}'    )

    # Get the parent process name
    parent_process=$(cat /proc/$PPID/comm)

    # Check if the parent process is by 'setup.sh'
    if [ "$parent_process" != "setup.sh" ]; then
        echo "Exiting: Parent process is not from setup.sh."
        exit 1
    fi
}

get_user() {
    # The auto guess_name will need work if there's 2 users, make a dialog to select which user
    if [[ $(grep -cE /home/ /etc/passwd) -gt 1 ]]; then
        echo "Feature Coming Soon" #Continue pls
    else
        export user=$(grep /home/ /etc/passwd | awk -F':' '{print $1}')
    fi
}

# Move alpine-setup folder to /home
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

# Turn on the edge release of alpine linux
edge_releases() {
    if ! [[ $(cat /etc/apk/repositories | grep -cE "^http.*/edge/") -ge 1 ]]; then
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
    fi
}

programchoices() {
    ((i = 0))
    choices=()
    command_execute=()
    
    command_execute+="case \${selected_choice[c]} in\n"

    for ((p = 0; p < ${#checkboxes[@]}; p+=2))
    do
        ((i+=1))
        choices+=("${i}" "${checkboxes[p]}" "OFF")
        command_execute+="${i})\n${checkboxes[p+1]}\n;;\n"
    done

    command_execute+="esac"
}

mainui() {
    cmd=(dialog --separate-output --title "$title" --backtitle "$backtitle" --checklist "Select options:" 15 65 5)
    array=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)

    readarray -t selected_choice <<< "$array"
}

command() {
    for ((c = 0; c < ${#selected_choice[@]}; c+=1))
    do  
        eval "$(echo -e "$command_execute")"
    done
}

homepage_script() {
    source ./Scripts/homepage_script.sh
    
    apk update && apk upgrade

    title="Alpine Setup"
    backtitle="Alpine Linux Interactive Installer"

    local -a checkboxes
    checkboxes+=("Initial Setup (run if u just did setup-alpine)" "initial_setup")
    checkboxes+=("Pipewire Setup" "pipewire")
    checkboxes+=("LxQt DE" "lxqt")
    checkboxes+=("Distrobox (Select for More App Support)" "distrobox")

    programchoices && mainui

    for item in "${selected_choice[@]}"
    do
        case "$item" in
            1) initial_setup ;;
            2) pipewire ;;
            3) lxqt ;;
            4) distrobox;;
        esac
    done
}

distbox_os() {
    source ./Scripts/Distrobox/distbox_os.sh

    title="Distrobox OS"
    backtitle="Choose your Distrobox OS"

    local -a checkboxes
    checkboxes+=("Ubuntu (Recommended)" "os_ubuntu")
    checkboxes+=("Debian" "os_debian")
    checkboxes+=("Arch Linux" "os_arch")

    programchoices && mainui

    for item in "${selected_choice[@]}"
    do
        case "$item" in
            1) os_ubuntu ;;
            2) os_debian ;;
            3) os_arch ;;
        esac
    done
}

deb_based() {
    source ./Scripts/Distrobox/deb_based.sh

    export DISTRO_NAME=$(echo "$DISTRO" | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt update -y && sudo apt upgrade -y && sudo apt install lsb-release pipewire wireplumber pipewire-pulse -y"'

    title="Additional Packages"
    backtitle="Additional Packages for $DISTRO_NAME"

    local -a checkboxes
    checkboxes+=("Browser" "browser")
    checkboxes+=("Communication" "communication")
    checkboxes+=("Utilities" "utilities")
    checkboxes+=("VsCode" "vs_code")

    programchoices && mainui

    for item in "${selected_choice[@]}"
    do
        case "$item" in
            1) browser ;;
            2) communication ;;
            3) utilities ;;
            4) vs_code ;;
        esac
    done

    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo dpkg --configure -a"'
}

browser() {
    title="Browser"
    backtitle="Browser to Install"

    local -a checkboxes
    checkboxes+=("Brave" "brow_brave")
    checkboxes+=("Opera" "brow_opera")
    checkboxes+=("Chrome Browser" "brow_chrome")
    checkboxes+=("Mullvad Browser" "brow_mullvad_browser")
    checkboxes+=("Tor Browser" "brow_tor_browser")

    programchoices && mainui && command
}

communication() {
    title="Communication"
    backtitle="Apps to Communicate"

    local -a checkboxes
    checkboxes+=("Discord" "com_discord")
    checkboxes+=("SimpleX Chat" "com_simplex")

    programchoices && mainui && command
}

utilities() {
    title="Utilities"
    backtitle="Utilities to Install"

    local -a checkboxes
    checkboxes+=("PeaZip" "util_peazip")
    checkboxes+=("Master PDF Editor 5" "util_master_pdf_editor5")

    programchoices && mainui && command
}

vs_code() {
    source ./Scripts/Distrobox/vs_code.sh

    vscode

    title="Programming Languange"
    backtitle="Choose Your Programming Languange"

    local -a checkboxes
    checkboxes+=("C/C++" "c_or_cpp-lang")
    checkboxes+=("Python" "python-lang")
    checkboxes+=("HTML/CSS/JS" "html_css_js-lang")

    programchoices && mainui && command
}

# For reboot and moving folder to /home
final_check() {
    if [[ $move_loc -eq 1 ]]; then
        rm -rf ../alpine-setup
    fi

    if [[ $reboot_value -eq 1 ]]; then
        reboot
    fi
}

check_parent_process
edge_releases
get_user
move_location
homepage_script
final_check