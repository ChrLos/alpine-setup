root_check() {
    if [ `id -u` -ne 0 ]; then
        echo "Please run this script as root or use sudo!"
        exit
    fi
}

get_user() {
    # The auto guess_name will need work if there's 2 users, make a dialog to select which user
    readarray -t lines < .variables
    export user=${lines[0]#\$USER=}

    if [[ ${lines[0]} != "\$USER="* ]]; then
        export user=$(dialog --title "Your user name" --inputbox "Enter your user name:" 10 50 "user" 3>&1 1>&2 2>&3)
        if [[ $user != "" ]]; then
            echo -e "\$USER=$user" >> .variables
        fi
    fi
}