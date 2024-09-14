#!/bin/bash

((indicator = 0))

programchoices() {
    ((indicator+=1))
    choices=()
    dynamic_choice=()
    ((i = 0))
    dynamic_choice+="case \${!pickings_testing} in\n"

    for ((p = 0; p < ${#checkboxes[@]}; p+=2))
    do
        ((i+=1))
        choices+=("${i}" "${checkboxes[p]}" "OFF")
        dynamic_choice+="${i})\n${checkboxes[p+1]}\n;;\n"
    done

    dynamic_choice+="esac"

    declare -g "execute_$indicator=$dynamic_choice"
    command_execute=execute_$indicator
}

mainui() {
    cmd=(dialog --separate-output --title "$title" --backtitle "$backtitle" --checklist "Select options:" 15 65 5)
    array=$("${cmd[@]}" "${choices[@]}" 2>&1 >/dev/tty)

    readarray -t picking <<<"$array"
    declare -g "picking_$indicator=${picking[*]}"
    picking_testing=picking_$indicator
    array_ref=${!picking_testing}
    count=${#array_ref[*]}

    echo $count
    echo $array_ref

    sleep 25
}

command() {
    for ((c = 0; c < ${#picking[@]}; c+=1))
    do
        declare -g "pickings_$indicator=${picking[c]}"
        pickings_testing=pickings_$indicator

        echo $pickings_1
        echo $pickings_2
        echo "c : $c"
        echo "total array : ${#picking[@]}"
        sleep 5

        eval "$(echo -e "${!command_execute}")"
    done
}

browser() {
    title="test1"
    backtitle="test1"

    local -a checkboxes
    checkboxes+=("1" "echo 11")
    checkboxes+=("2" "echo 22")
    checkboxes+=("3" "echo 33")
    checkboxes+=("4" "echo 44")

    programchoices && mainui && command
}

communication() {
    title="p1"
    backtitle="p1"

    local -a checkboxes
    checkboxes+=("test1" "echo test1")
    checkboxes+=("test2" "echo test2")

    programchoices && mainui && command
}

last() {
    title="c1"
    backtitle="c1"

    local -a checkboxes
    checkboxes+=("p1" "echo p1")
    checkboxes+=("p2" "echo p2")
    checkboxes+=("p3" "echo p3")

    programchoices && mainui && command
}

mainui_ui() {
    title="c1"
    backtitle="c1"

    local -a checkboxes
    checkboxes+=("browser" "browser")
    checkboxes+=("communication" "communication")
    checkboxes+=("last" "last")

    programchoices && mainui && command

    echo testhehe
}

mainui_ui
