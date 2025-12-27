#!/bin/bash

# Dialog confirmation dialog before starting ISO creation (CLI version)

confirm_start() {
    dialog --title "Confirm ISO Creation" \
        --yesno "Create the ISO now? Select No to exit." \
        8 40 2>&1 >/dev/tty
    echo $?
}

confirm_start
