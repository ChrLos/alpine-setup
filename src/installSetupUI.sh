#!/bin/bash

source ./lib/checkStart.sh
source ./lib/dynamicOption.sh

homepage_script() {
    source ./src/Scripts/homepageScript.sh

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
    source ./src/Scripts/Distrobox/distboxOS.sh

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
    source ./src/Scripts/Distrobox/debBased.sh

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
    source ./src/Scripts/Distrobox/vsCode.sh

    vscode

    title="Programming Languange"
    backtitle="Choose Your Programming Languange"

    local -a checkboxes
    checkboxes+=("C/C++" "c_or_cpp-lang")
    checkboxes+=("Python" "python-lang")
    checkboxes+=("HTML/CSS/JS" "html_css_js-lang")

    programchoices && mainui && command
}

check_parent_process
edge_releases
get_user
move_location
homepage_script
final_check