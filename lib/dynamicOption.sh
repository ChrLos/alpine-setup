programchoices() {
    ((i = 0))
    checkboxes_generator=()
    command_to_execute=()
    
    command_to_execute+="case \${selected_choice[c]} in\n"

    for ((counter = 0; counter < ${#checkboxes[@]}; counter+=2))
    do
        ((i+=1))
        checkboxes_generator+=("${i}" "${checkboxes[counter]}" "OFF")
        command_to_execute+="${i})\n${checkboxes[counter+1]}\n;;\n"
    done

    command_to_execute+="esac"
}

# Creating the dialog UI along with the choices
mainui() {
    cmd=(
        dialog --separate-output \
                --title "$title" \
                --backtitle "$backtitle" \
                --checklist "Select options:" \
        15 65 5
    )

    array_of_choice=$("${cmd[@]}" "${checkboxes_generator[@]}" 2>&1 >/dev/tty)
    readarray -t selected_choice <<< "$array_of_choice"
}

command() {
    for ((c = 0; c < ${#selected_choice[@]}; c+=1))
    do  
        eval "$(echo -e "$command_to_execute")"
    done
}