#!/bin/sh

# Doing a root/sudo check
if [ `id -u` -ne 0 ]; then
    echo "Please run this script as root or use sudo!"
    exit
fi

apk add bash dialog
./src/installSetupUI.sh