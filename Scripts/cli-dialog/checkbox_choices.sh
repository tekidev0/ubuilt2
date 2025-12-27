#!/bin/bash

# Dialog checkmark dialog for enabling features (CLI version)

get_chroot_choice() {
    # First show a confirmation dialog to detect if user wants to proceed
    if ! dialog --title "ISO Creation Options" --yesno "Configure ISO creation options?" 10 40 2>&1 >/dev/tty; then
        echo 2  # User cancelled, return to main menu
        return
    fi
    
    # User wants to configure options, show the checkbox dialog
    local choice=$(dialog --title "ISO Creation Options" \
        --checklist "Select options for ISO creation:" 12 49 2 \
        "chroot" "Enable chroot customization" off \
        "grub_splash" "Disable GRUB splash" off \
        2>&1 >/dev/tty)
    
    # For checklist, we can't detect cancel vs uncheck, so treat empty as disabled
    local chroot_enabled=1
    local grub_splash_disabled=0
    
    if [[ "$choice" == *"chroot"* ]]; then
        chroot_enabled=0  # User enabled chroot
    fi
    
    if [[ "$choice" == *"grub_splash"* ]]; then
        grub_splash_disabled=1  # User disabled GRUB splash
    fi
    
    # Return codes: chroot_enabled (0/1) and grub_splash_disabled (0/1)
    echo "$chroot_enabled $grub_splash_disabled"
}

get_chroot_choice
