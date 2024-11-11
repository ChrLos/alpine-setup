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
    if [[ $(grep -cE /home/ /etc/passwd) -gt 1 ]]; then
        echo "Feature Coming Soon" #Continue pls
    else
        export user=$(grep /home/ /etc/passwd | awk -F':' '{print $1}')
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

# For reboot and moving folder to /home
final_check() {
    if [[ $move_loc -eq 1 ]]; then
        rm -rf ../alpine-setup
    fi

    if [[ $reboot_value -eq 1 ]]; then
        reboot
    fi
}