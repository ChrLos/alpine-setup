#!/bin/bash

source ./lib/checkStart.sh
source ./lib/dynamicOption.sh

homepage_script() {
    title="Alpine Setup"
    backtitle="Alpine Linux Interactive Installer"

    local -a checkboxes
    checkboxes+=("Desktop Environtment" "de_ui_options")
    checkboxes+=("Minimal" "exit")

    programchoices && mainui && command
}

de_ui_options() {
    source ./src/Scripts/homepageScript.sh

    de_initial_setup

    title="Desktop Environtment"
    backtitle="Desktop Environtment Options"

    local -a checkboxes
    checkboxes+=("LXQT" "lxqt")

    programchoices && mainui && command

    distrobox
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
    checkboxes+=("Zen Browser" "brow_zen")
    checkboxes+=("Mullvad Browser" "brow_mullvad_browser")
    checkboxes+=("Vivaldi" "brow_vivaldi")
    checkboxes+=("Opera" "brow_opera")
    checkboxes+=("Chrome Browser" "brow_chrome")
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
    vscode
    vs_code_theme_choices_ui
    
    source ./src/Scripts/Distrobox/vsCode.sh

    title="Programming Languange"
    backtitle="Choose Your Programming Languange"

    local -a checkboxes
    checkboxes+=("C/C++" "c_or_cpp-lang")
    checkboxes+=("Python" "python-lang")
    checkboxes+=("HTML/CSS/JS" "html_css_js-lang")

    programchoices && mainui && command
}

vs_code_theme_choices_ui() {
    source ./src/Scripts/Distrobox/vsCode.sh

    title="VS Code Themes"
    backtitle="Options for VS Code Themes"

    local -a checkboxes
    checkboxes+=("Catppuccin" "vs_code_theme_choices "catppuccin.catppuccin-vsc"")
    checkboxes+=("Dracula" "vs_code_theme_choices "dracula-theme.theme-dracula"")
    checkboxes+=("One Dark Pro" "vs_code_theme_choices "zhuangtongfa.material-theme"")
    checkboxes+=("Tokyo Night" "vs_code_theme_choices "enkia.tokyo-night"")

    programchoices && mainui && command
}

check_parent_process
get_user
initial_setup
edge_releases
move_location
homepage_script
final_check