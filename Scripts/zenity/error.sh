#!/bin/bash

# Zenity error dialog

show_error() {
    local message="$1"
    zenity --error --title="Error" --text="$message" --width=400
}

show_error "$1"
