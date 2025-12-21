#!/bin/bash

# Zenity success dialog

show_success() {
    local message="$1"
    zenity --info --title="Success" --text="$message" --width=400
}

show_success "$1"
