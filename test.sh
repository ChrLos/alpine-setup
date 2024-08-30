#!/bin/bash

programchoices() {
    choices=()
    dynamic_choice=()
    ((i = 0))
    dynamic_choice+="case \$pickings in\n"

    for ((p = 0; p < ${#checkboxes[@]}; p+=2))
    do
        ((i+=1))
        choices+=("${i}" "${checkboxes[p]}" "OFF")
        dynamic_choice+="${i})\n${checkboxes[p+1]}\n;;\n"
    done

    dynamic_choice+="esac"

    # echo ${choices[@]}
}

mainpage() {
    cmd=(dialog --separate-output --title "Alpine Setup" --backtitle "Alpine Linux Interactive Installer" --checklist "Select options:" 15 65 5)
    picking=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)
    clear
}

command() {
    # echo -e "$dynamic_choice"
    # echo "$picking"
    for pickings in $picking
    do
        eval "$(echo -e "$dynamic_choice")"
    done
}

testing() {
    local -a checkboxes
    checkboxes+=("test1" "echo command1")
    checkboxes+=("test3" "echo command3")
    checkboxes+=("test2" "echo command2")
    checkboxes+=("test55" "echo commandolla")

    programchoices && mainpage && command
}

testing1() {
    local -a checkboxes
    checkboxes+=("another1" "echo long1")
    checkboxes+=("another3" "echo long3")
    checkboxes+=("another2" "echo long2")

    programchoices && mainpage && command
}

testing
testing1
