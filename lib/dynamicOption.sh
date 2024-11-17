programchoices() {
    ((i = 0))
    choices=()
    command_execute=()
    
    command_execute+="case \${selected_choice[c]} in\n"

    for ((counter = 0; counter < ${#checkboxes[@]}; counter+=2))
    do
        ((i+=1))
        choices+=("${i}" "${checkboxes[counter]}" "OFF")
        command_execute+="${i})\n${checkboxes[counter+1]}\n;;\n"
    done

    command_execute+="esac"
}

mainui() {
    cmd=(dialog --separate-output --title "$title" --backtitle "$backtitle" --checklist "Select options:" 15 65 5)
    array=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)

    readarray -t selected_choice <<< "$array"
}

command() {
    for ((c = 0; c < ${#selected_choice[@]}; c+=1))
    do  
        eval "$(echo -e "$command_execute")"
    done
}