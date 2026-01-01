#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Check dependencies
check_dependencies() {
    # Format: "command:package"
    local deps=("rsync:rsync" "mksquashfs:squashfs-tools" "grub-mkrescue:grub-pc-bin" "zenity:zenity" "dialog:dialog")
    local missing_commands=()
    local missing_packages=()
    
    for dep in "${deps[@]}"; do
        local command="${dep%%:*}"
        local package="${dep##*:}"
        
        if ! command -v "$command" &> /dev/null; then
            missing_commands+=("$command")
            missing_packages+=("$package")
        fi
    done
    
    # Add Secure Boot dependencies if enabled
    if [ "$SECURE_BOOT" = "true" ]; then
        local secure_boot_deps=("sbsigntool:sbsigntool" "openssl:openssl")
        for dep in "${secure_boot_deps[@]}"; do
            local command="${dep%%:*}"
            local package="${dep##*:}"
            
            if ! command -v "$command" &> /dev/null; then
                missing_commands+=("$command")
                missing_packages+=("$package")
            fi
        done
    fi
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        echo "ERROR: Missing dependencies: ${missing_commands[*]}"
        echo "Please install them with: sudo apt update && sudo apt install ${missing_packages[*]}"
        exit 1
    fi
    
    echo "All dependencies are satisfied."
}

check_dependencies
