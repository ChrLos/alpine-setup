os_ubuntu() {
    export DISTRO="ubuntu"
    su $user -c 'yes | distrobox create --name $DISTRO --image ubuntu --home ~/$DISTRO'
    deb_based
}

os_debian() {
    export DISTRO="debian"
    su $user -c 'yes | distrobox create --name $DISTRO --pull -i quay.io/toolbx-images/debian-toolbox:latest --home ~/$DISTRO'
    deb_based
}

os_arch() {
    su $user -c 'yes | distrobox create --name aur --pull -i quay.io/toolbx/arch-toolbox:latest --home ~/aur'
    su $user -c 'distrobox enter aur -- bash -c "sudo -Syu"'
}