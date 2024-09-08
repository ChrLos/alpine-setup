#!/bin/bash

# Browser

brow_brave() {
    cat > /tmp/brave.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list && sudo apt update && sudo apt install -y brave-browser'
    distrobox enter $DISTRO -- distrobox-export --app brave-browser
EOF

    chmod +x /tmp/brave.sh
    su $user -c /tmp/brave.sh
}

brow_opera() {
    cat > /tmp/opera.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo dd of=/usr/share/keyrings/opera-browser.gpg'
    distrobox enter $DISTRO -- bash -c 'echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo dd of=/etc/apt/sources.list.d/opera-archive.list'
    distrobox enter $DISTRO -- bash -c 'sudo apt-get update'
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install opera-stable -y'
EOF

    chmod +x /tmp/opera.sh
    su $user -c /tmp/opera.sh
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

brow_tor_browser() {
    cat > /tmp/torbrowser.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install -y torbrowser-launcher'
    distrobox enter $DISTRO -- distrobox-export --app torbrowser-launcher
EOF

    chmod +x /tmp/torbrowser.sh
    su $user -c /tmp/torbrowser.sh
}

# Communication

com_discord() {
    wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord_install.deb
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo dpkg -i /tmp/discord_install.deb"'
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt install -f -y"'
    su $user -c 'distrobox enter $DISTRO -- distrobox-export --app discord'
}

com_simplex() {
    mkdir /usr/share/desktop-directories/
    wget https://github.com/simplex-chat/simplex-chat/releases/latest/download/simplex-desktop-ubuntu-22_04-x86_64.deb -O /tmp/simplex-chat_install.deb
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo dpkg -i /tmp/simplex-chat_install.deb"'
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt install -f -y"'
    su $user -c 'distrobox enter $DISTRO -- distrobox-export --app simplex'
}

# Utilities


# Others

vscode() {
    cat > /tmp/vscode.sh << EOF
    #!/bin/bash
    distrobox enter $DISTRO -- bash -c 'sudo apt-get install wget gpg && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null &&rm -f packages.microsoft.gpg && sudo apt install apt-transport-https && sudo apt update && sudo apt install -y code'
    distrobox enter $DISTRO -- distrobox-export --app code
EOF

    chmod +x /tmp/vscode.sh
    su $user -c /tmp/vscode.sh
}