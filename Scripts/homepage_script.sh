#!/bin/bash

initial_setup() {
    sed -i -e "/\/$alpineversion\// s/^#//" /etc/apk/repositories
    apk add doas sudo nano vim neovim btop gedit
    adduser $user wheel
    passwd -l root
    apk update
}

pipewire() {
    addgroup $user audio
    apk add pipewire wireplumber pipewire-pulse
}

lxqt() {
    setup-xorg-base
    apk add lxqt-desktop lximage-qt obconf-qt pavucontrol-qt arandr screengrab sddm elogind polkit-elogind gvfs udisks2 papirus-icon-theme font-cantarell
    rc-service dbus start
    rc-update add dbus
    setup-devd udev
    rc-update add sddm
    rc-update add elogind
    rc-service elogind start

    # Changing Screen Resolution
    #DISPLAYID=$(xrandr | grep " connected" | cut -d' ' -f1)
    #su $user -c 'xrandr --output $DISPLAYID --mode 1920x1080'

    # Changing icons and themes
    su $user -c 'mkdir -p /home/$user/.config/lxqt/'
    cat > /home/$user/.config/lxqt/lxqt.conf << EOF
    [General]
    __userfile__=true
    icon_theme=Papirus
    theme=KDE-Plasma
    [Qt]
    font=\"Cantarell,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"
EOF
    chown $user:$user /home/$user/.config/lxqt/lxqt.conf
}

distrobox() {
    if [ $(apk list --installed | grep -cE 'distrobox|podman|podman-compose') -lt 3 ] && ! [ -f "/etc/local.d/mount-rshared.start" ]; then
        
        apk add distrobox podman podman-compose
        rc-update add cgroups
        rc-service cgroups start
        modprobe tun
        echo tun >>/etc/modules
        echo $user:100000:65536 >/etc/subuid
        echo $user:100000:65536 >/etc/subgid

        cat > /etc/local.d/mount-rshared.start << EOF
        #!/bin/sh
        mount --make-rshared /
EOF

        chmod +x /etc/local.d/mount-rshared.start
        rc-update add local default
        rc-service local start

        export reboot_value=1
        final_check
    else
        distbox_os
    fi
}