determine_option_mode() {
    case $option_mode in
        "multi choice")
            export dialog_type='--separate-output --checklist'
            switches="OFF"
            ;;

        "single choice")
            export dialog_type='--menu'
            switches=""
            ;;

        "y/n")
            export dialog_type='--yesno'
            switches=""
            ;;

        *)
            echo "No Variables Specified"
            sleep 20
            exit 1
            ;;
    esac
}

programchoices() {
    determine_option_mode
    
    ((i = 0))
    checkboxes_generator=()
    command_to_execute=()
    
    command_to_execute+="case \${selected_choice[c]} in\n"

    for ((counter = 0; counter < ${#checkboxes[@]}; counter+=2))
    do
        ((i+=1))
        checkboxes_generator+=("${i}" "${checkboxes[counter]}" $switches)
        command_to_execute+="${i})\n${checkboxes[counter+1]}\n;;\n"
    done

    command_to_execute+="esac"
}

# Creating the dialog UI along with the choices
mainui() {
    cmd=(
        dialog  --title "$title" \
                --backtitle "$backtitle" \
                $dialog_type "Select options:" \
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