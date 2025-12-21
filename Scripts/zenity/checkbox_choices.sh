#!/bin/bash

# Zenity checkmark dialog for enabling features

get_chroot_choice() {
    # First show a confirmation dialog to detect if user wants to proceed
    if ! zenity --question --title="ISO Creation Options" --text="Configure ISO creation options?" --width=400 --ok-label="Configure" --cancel-label="Cancel"; then
        echo 2  # User cancelled, return to main menu
        return
    fi
    
    # User wants to configure options, show the checkbox dialog
    local choice=$(zenity --list --title="ISO Creation Options" \
        --text="Select options for ISO creation:" \
        --checklist \
        --column="Select" --column="Option" \
        FALSE "Enable chroot customization" \
        --width=400 --height=200)
    
    # For checklist, we can't detect cancel vs uncheck, so treat empty as disabled
    if [[ "$choice" == *"Enable chroot customization"* ]]; then
        echo 0  # User enabled chroot
    else
        echo 1  # User disabled chroot (unchecked or left unchecked)
    fi
}

get_chroot_choice
