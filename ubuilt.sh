#!/bin/bash

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/work.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "This script requires root privileges. Using pkexec..."
        # Preserve environment variables for zenity display access and use absolute path
        pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" "$SCRIPT_DIR/ubuilt.sh" "$@"
        exit $?
    fi
}

# Check dependencies
check_dependencies() {
    "$SCRIPT_DIR/Scripts/CheckDeps.sh"
}

# Show zenity dialog for options
show_options() {
    "$SCRIPT_DIR/Scripts/zenity/main_menu.sh"
}

# Create Live CD workflow
create_live_cd() {
    log "Starting Live CD creation process..."
    
    # Get ISO name from work.conf
    source "$SCRIPT_DIR/work.conf"
    
    # Ask if user wants chroot customization
    local use_chroot=$("$SCRIPT_DIR/Scripts/zenity/checkbox_choices.sh")
    
    # Check if user cancelled the checkbox dialog
    if [ $use_chroot -eq 2 ]; then
        log "User cancelled options selection."
        return 0
    fi
    
    # Confirm before starting the process
    local confirm=$("$SCRIPT_DIR/Scripts/zenity/confirm_start.sh")
    if [ $confirm -ne 0 ]; then
        log "User cancelled ISO creation."
        return 0
    fi
    
    # Execute workflow steps
    log "Creating work directories..."
    "$SCRIPT_DIR/Scripts/CreateWork.sh"
    
    log "Copying ISO files structure..."
    "$SCRIPT_DIR/Scripts/CopyISOStructure.sh"
    
    log "Copying filesystem with rsync..."
    "$SCRIPT_DIR/Scripts/CopyRootfs.sh"
    
    log "Installing Casper..."
    "$SCRIPT_DIR/Scripts/InstallCasper.sh"
    "$SCRIPT_DIR/Scripts/ConfigureCasper.sh"
    
    log "Copying kernel and initrd..."
    "$SCRIPT_DIR/Scripts/CopyKernel.sh"
    
    if [ $use_chroot -eq 0 ]; then
        log "Entering chroot environment for customization..."
        "$SCRIPT_DIR/Scripts/ChrootShell.sh"
    fi
    
    log "Creating squashfs filesystem..."
    "$SCRIPT_DIR/Scripts/CreateSquashfs.sh"
    
    log "Creating bootable ISO with GRUB..."
    "$SCRIPT_DIR/Scripts/CreateISO.sh"
    
    log "Live CD creation completed successfully!"
    log "ISO saved to: $ISO_NAME"
    
    "$SCRIPT_DIR/Scripts/zenity/success.sh" "Live CD created successfully!\n\nISO saved to:\n$ISO_NAME"
}

# Clean workspace
clean_workspace() {
    log "Cleaning workspace..."
    "$SCRIPT_DIR/Scripts/Clean.sh"
    "$SCRIPT_DIR/Scripts/zenity/success.sh" "Workspace cleaned successfully."
}

# Main function
main() {
    check_root
    check_dependencies
    
    # Expand variables in work.conf
    export WORK=$(eval echo "$WORK")
    export ISO=$(eval echo "$ISO")
    export ISO_FILES=$(eval echo "$ISO_FILES")
    export ISO_NAME=$(eval echo "$ISO_NAME")
    export ROOTFS=$(eval echo "$ROOTFS")
    
    while true; do
        local choice=$(show_options)
        
        case "$choice" in
            "Create Live CD")
                create_live_cd
                ;;
            "Clean Workspace")
                clean_workspace
                ;;
            "Exit"|"")
                log "Exiting Ubuilt."
                exit 0
                ;;
            *)
                warning "Invalid choice: $choice"
                ;;
        esac
    done
}

# Run main function
main "$@"
