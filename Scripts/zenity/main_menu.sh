#!/bin/bash

# Zenity main menu for Ubuilt

show_main_menu() {
    local choice=$(zenity --list --title="Ubuilt - Ubuntu Live CD Creator" \
        --text="Choose an option:" \
        --column="Option" \
        "Create Live CD" \
        "Clean Workspace" \
        "Exit" \
        --width=400 --height=300)
    
    echo "$choice"
}

show_main_menu
