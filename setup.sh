#!/bin/sh

root_check() {
    if [ `id -u` -ne 0 ]; then
        echo "Please run this script as root or use sudo!"
        exit
    fi
}

root_check
apk add bash dialog
./Scripts/install_ui.sh