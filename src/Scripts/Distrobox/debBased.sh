#=======================================================================                                                                      
#   Initial Setup                                                                                            
#=======================================================================

export DISTRO_NAME=$(echo "$DISTRO" | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
su $user -c "distrobox enter $DISTRO -- bash -c 'sudo apt update -y && sudo apt upgrade -y && sudo apt install lsb-release pipewire wireplumber pipewire-pulse -y'"

#=======================================================================                                                                      
#   Browser                                                                                            
#=======================================================================

brow_brave() {
    cat > /tmp/brave.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list && sudo apt update && sudo apt install -y brave-browser'
    distrobox enter $DISTRO -- distrobox-export --app brave-browser
EOF

    chmod +x /tmp/brave.sh
    su $user -c /tmp/brave.sh
}

brow_zen() {
    cat > /tmp/zenbrowser.sh << EOF
    mkdir -p /home/$user/App/Zen
    chown -R $user:$user /home/$user/App/

    distrobox enter $DISTRO -- bash -c 'sudo curl -s https://api.github.com/repos/zen-browser/desktop/releases/latest | grep "x86_64.*tar" | cut -d : -f 2,3 | tr -d \" | wget -i - -O /tmp/zenbrowser.tar.xz'

    distrobox enter $DISTRO -- bash -c 'tar -xvf /tmp/zenbrowser.tar.xz -C /home/$user/App/Zen --strip-components 1'
EOF

    chmod +x /tmp/zenbrowser.sh
    su $user -c /tmp/zenbrowser.sh

    cp /home/$user/App/Zen/browser/chrome/icons/default/default64.png /home/$user/.local/share/icons/zen-browser.png

    cat > /home/$user/.local/share/applications/ubuntu-zen-browser.desktop << EOF
    [Desktop Entry]
    Encoding=UTF-8
    Name=Zen Browser
    Type=Application
    Categories=Network;WebBrowser;
    Terminal=false
    Exec=bash -c "distrobox enter ubuntu -- /home/$user/App/Zen/zen"
    Icon=zen-browser.png
EOF
}

brow_mullvad_browser() {
    cat > /tmp/mullvad.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc && echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=\$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list && sudo apt update && sudo apt install -y mullvad-browser'
    distrobox enter $DISTRO -- distrobox-export --app mullvad-browser
EOF

    chmod +x /tmp/mullvad.sh
    su $user -c /tmp/mullvad.sh
}

brow_vivaldi() {
    cat > /tmp/vivaldi.sh << EOF
    distrobox enter $DISTRO -- bash -c 'sudo curl -s https://vivaldi.com/download/ | grep -o "https://[^\"]*amd64.deb" | wget -i - -O /tmp/vivaldi_install.deb'
    distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/vivaldi_install.deb'
    distrobox enter $DISTRO -- distrobox-export --app vivaldi
EOF

    chmod +x /tmp/vivaldi.sh
    su $user -c /tmp/vivaldi.sh
}

brow_opera() {
    cat > /tmp/opera.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo dd of=/usr/share/keyrings/opera-browser.gpg'
    distrobox enter $DISTRO -- bash -c 'echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo dd of=/etc/apt/sources.list.d/opera-archive.list'
    distrobox enter $DISTRO -- bash -c 'sudo apt-get update'
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install opera-stable -y'
    distrobox enter $DISTRO -- distrobox-export --app opera
EOF

    chmod +x /tmp/opera.sh
    su $user -c /tmp/opera.sh
}

brow_chrome() {
    wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O /tmp/google_chrome-install.deb
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/google_chrome-install.deb'"
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo apt install -f -y'"
    su $user -c "distrobox enter $DISTRO -- distrobox-export --app chrome"
}

brow_tor_browser() {
    cat > /tmp/torbrowser.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install -y torbrowser-launcher'
    distrobox enter $DISTRO -- distrobox-export --app torbrowser-launcher
EOF

    chmod +x /tmp/torbrowser.sh
    su $user -c /tmp/torbrowser.sh
}


#=======================================================================                                                                      
#   Communication                                                                                            
#=======================================================================

com_discord() {
    wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord_install.deb
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/discord_install.deb'"
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo apt install -f -y'"
    su $user -c "distrobox enter $DISTRO -- distrobox-export --app discord"
}

com_simplex() {
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo mkdir /usr/share/desktop-directories/'"
    wget https://github.com/simplex-chat/simplex-chat/releases/latest/download/simplex-desktop-ubuntu-22_04-x86_64.deb -O /tmp/simplex-chat_install.deb
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/simplex-chat_install.deb'"
    su $user -c "distrobox enter $DISTRO -- bash -c 'sudo apt install -f -y'"
    su $user -c "distrobox enter $DISTRO -- distrobox-export --app simplex"
}

#=======================================================================                                                                      
#   Utilities                                                                                            
#=======================================================================

util_peazip() {
    cat > /tmp/peazip.sh << EOF
    distrobox enter $DISTRO -- bash -c 'sudo curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep "Qt.*deb" | cut -d : -f 2,3 | tr -d \" | wget -i - -O /tmp/peazip_install.deb'
    distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/peazip_install.deb'
    distrobox enter $DISTRO -- bash -c 'sudo apt install libqt5printsupport5t64 libqt5x11extras5 -y'
    distrobox enter $DISTRO -- distrobox-export --app peazip
EOF

    chmod +x /tmp/peazip.sh
    su $user -c /tmp/peazip.sh
}

util_master_pdf_editor5() {
    cat > /tmp/master-pdf-editor5.sh << EOF
    distrobox enter $DISTRO -- bash -c 'sudo curl -s https://code-industry.net/get-master-pdf-editor-for-ubuntu/?download | grep "qt.*deb" | cut -d \" -f 2 | head -1 | wget -i - -O /tmp/master-pdf-editor5_install.deb'
    distrobox enter $DISTRO -- bash -c 'sudo dpkg -i /tmp/master-pdf-editor5_install.deb'
    distrobox enter $DISTRO -- bash -c 'sudo apt install -f -y'
    distrobox enter $DISTRO -- bash -c 'sudo apt install libsane1:amd64 -y'
    distrobox enter $DISTRO -- distrobox-export --app masterpdfeditor5
EOF

    chmod +x /tmp/master-pdf-editor5.sh
    su $user -c /tmp/master-pdf-editor5.sh
}

#=======================================================================                                                                      
#   Others                                                                                            
#=======================================================================

vscode() {
    cat > /tmp/vscode.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install wget gpg && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null &&rm -f packages.microsoft.gpg && sudo apt install apt-transport-https && sudo apt update && sudo apt install -y code'
    distrobox enter $DISTRO -- distrobox-export --app code
EOF

    chmod +x /tmp/vscode.sh
    su $user -c /tmp/vscode.sh
}