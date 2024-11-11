#=======================================================================                                                                      
#   Main setup                                                                                            
#=======================================================================

# Install VSCode extension by reading the file lines
install_extension() {
    file="/tmp/$file_name"
    while IFS=$'\n' read -r line
    do
        install_line="code --install-extension $line "
        extension+="${install_line//\\n/ }"
    done < "$file"

    su $user -c "distrobox enter $DISTRO -- bash -c '$extension'"
}

# Check if main extension is downloaded yet or not
if [ $(su $user -c "distrobox enter $DISTRO -- bash -c \"code --list-extensions\" | grep -cE 'pkief.material-icon-theme|zhuangtongfa.material-theme|oderwat.indent-rainbow|formulahendry.code-runner|adpyke.codesnap|shd101wyy.markdown-preview-enhanced|yzhang.markdown-all-in-one'") -lt 7 ]; then

    cat > /tmp/main_extension << EOF
    pkief.material-icon-theme
    zhuangtongfa.material-theme
    oderwat.indent-rainbow
    formulahendry.code-runner
    adpyke.codesnap
    shd101wyy.markdown-preview-enhanced
    yzhang.markdown-all-in-one
EOF

    file_name=main_extension
    install_extension
fi

#=======================================================================                                                                      
#   Theme Choice                                                                                            
#=======================================================================



#=======================================================================                                                                      
#   Programming Languange Choice                                                                                            
#=======================================================================

c_or_cpp-lang() {
    # Downloading GCC and build package for c
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt install build-essential gcc g++ -y"'

    # Extensions
    cat > /tmp/c_or_cpp-extension << EOF
    ms-vscode.cmake-tools
    ms-vscode.cpptools
    ms-vscode.cpptools-extension-pack
    ms-vscode.cpptools-themes
    ms-vscode.makefile-tools
    twxs.cmake
EOF

    file_name=c_or_cpp-extension
    install_extension
}

python-lang() {
    su $user -c 'distrobox enter $DISTRO -- bash -c "sudo apt install python3 -y"'

    # Extensions
    cat > /tmp/python-lang << EOF
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
EOF

    file_name=python-lang
    install_extension
}

html_css_js-lang() {
    # Downloading NodeJS
    su $user -c 'distrobox enter $DISTRO -- bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash"'
    su $user -c 'distrobox enter $DISTRO -- bash -c "nvm install 22"'
    
    # Extensions
    cat > /tmp/html_css_js-lang << EOF
    christian-kohler.path-intellisense
    formulahendry.auto-rename-tag
    ritwickdey.liveserver
    esbenp.prettier-vscode
    dbaeumer.vscode-eslint
EOF

    file_name=html_css_js-lang
    install_extension
}