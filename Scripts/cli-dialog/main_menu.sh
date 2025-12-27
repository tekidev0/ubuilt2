#!/bin/bash

# Dialog main menu for Ubuilt (CLI version)

show_main_menu() {
    local choice=$(dialog --title "Ubuilt - Ubuntu Live CD Creator" \
        --menu "Choose an option:" 15 50 3 \
        "Create Live CD" "Create a new Ubuntu Live CD" \
        "Clean Workspace" "Clean the workspace" \
        "Exit" "Exit the program" \
        2>&1 >/dev/tty)
    
    echo "$choice"
}

show_main_menu
