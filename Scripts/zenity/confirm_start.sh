#!/bin/bash

# Zenity confirmation dialog before starting ISO creation

confirm_start() {
    zenity --question --title="Confirm ISO Creation" --text="Create the ISO now? Click No to exit." --width=400
    echo $?
}

confirm_start
