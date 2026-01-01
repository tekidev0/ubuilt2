#!/bin/bash

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/work.conf"

echo "--- Ubuilt $VERSION ($VERSION_TAG) ---"

# CLI mode flag
CLI_MODE="false"

# Check for --cli flag
for arg in "$@"; do
    case $arg in
        --cli)
            CLI_MODE="true"
            shift
            ;;
    esac
done

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
        if [[ "$CLI_MODE" == "true" ]]; then
            log "This script requires root privileges. Using sudo..."
            sudo "$SCRIPT_DIR/ubuilt.sh" --cli "$@"
        else
            log "This script requires root privileges. Using pkexec..."
            # Preserve environment variables for zenity display access and use absolute path
            pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" "$SCRIPT_DIR/ubuilt.sh" "$@"
        fi
        exit $?
    fi
}

# Check dependencies
check_dependencies() {
    "$SCRIPT_DIR/Scripts/CheckDeps.sh"
}

# Show dialog for options (GUI or CLI)
show_options() {
    if [[ "$CLI_MODE" == "true" ]]; then
        "$SCRIPT_DIR/Scripts/cli-dialog/main_menu.sh"
    else
        "$SCRIPT_DIR/Scripts/zenity/main_menu.sh"
    fi
}

# Create Live CD workflow
create_live_cd() {
    log "Starting Live CD creation process..."
    
    # Get ISO name from work.conf
    source "$SCRIPT_DIR/work.conf"
    
    # Ask if user wants chroot customization and GRUB splash options
    if [[ "$CLI_MODE" == "true" ]]; then
        local options=$("$SCRIPT_DIR/Scripts/cli-dialog/checkbox_choices.sh")
    else
        local options=$("$SCRIPT_DIR/Scripts/zenity/checkbox_choices.sh")
    fi
    
    # Check if user cancelled the checkbox dialog
    if [ "$options" == "2" ]; then
        log "User cancelled options selection."
        return 0
    fi
    
    # Parse options: chroot_enabled grub_splash_disabled
    local use_chroot=$(echo "$options" | cut -d' ' -f1)
    local disable_grub_splash=$(echo "$options" | cut -d' ' -f2)
    
    # Confirm before starting the process
    if [[ "$CLI_MODE" == "true" ]]; then
        # CLI confirmation
        dialog --title "Confirm ISO Creation" --yesno "Ready to start creating the Live CD?\n\nThis will take several minutes and requires significant disk space." 12 50 2>&1 >/dev/tty
        local confirm=$?
    else
        local confirm=$("$SCRIPT_DIR/Scripts/zenity/confirm_start.sh")
    fi
    if [ $confirm -ne 0 ]; then
        log "User cancelled ISO creation."
        return 0
    fi
    
    # Select chroot tool before starting rootfs operations
    # Function to detect available chroot tools and prompt user if both exist
    get_chroot_command() {
        local arch_chroot_available=false
        local chroot_available=false
        
        # Check for arch-chroot
        if command -v arch-chroot &> /dev/null; then
            arch_chroot_available=true
        fi
        
        # Check for chroot
        if command -v chroot &> /dev/null; then
            chroot_available=true
        fi
        
        # If only chroot is available
        if [ "$chroot_available" = true ] && [ "$arch_chroot_available" = false ]; then
            echo "chroot"
            return 0
        fi
        
        # If only arch-chroot is available
        if [ "$arch_chroot_available" = true ] && [ "$chroot_available" = false ]; then
            echo "arch-chroot"
            return 0
        fi
        
        # If both are available, prompt user
        if [ "$arch_chroot_available" = true ] && [ "$chroot_available" = true ]; then
            if [[ "$CLI_MODE" == "true" ]]; then
                # CLI mode - use dialog
                local choice=$(dialog --title "Chroot Tool Selection" \
                    --menu "Both arch-chroot and chroot are available.\nWhich chroot tool would you like to use?" \
                    12 50 2 \
                    "1" "arch-chroot" \
                    "2" "chroot" \
                    2>&1 >/dev/tty)
                
                case $choice in
                    1) echo "arch-chroot" ;;
                    2) echo "chroot" ;;
                    *) echo "chroot" ;;  # Default to chroot
                esac
            else
                # GUI mode - use zenity
                local choice=$(zenity --list --title="Chroot Tool Selection" \
                    --text="Both arch-chroot and chroot are available.\nWhich chroot tool would you like to use?" \
                    --column="Choice" --column="Tool" \
                    "1" "arch-chroot" \
                    "2" "chroot" \
                    --width=400 --height=200)
                
                case $choice in
                    "1") echo "arch-chroot" ;;
                    "2") echo "chroot" ;;
                    *) echo "chroot" ;;  # Default to chroot
                esac
            fi
            return 0
        fi
        
        # If neither is available
        echo "chroot"  # Fallback, though this will likely fail
        return 1
    }
    
    CHROOT_CMD=$(get_chroot_command)
    export CHROOT_CMD
    log "Using chroot command: $CHROOT_CMD"
    
    # Execute workflow steps
    log "Creating work directories..."
    "$SCRIPT_DIR/Scripts/CreateWork.sh"
    
    log "Copying ISO files structure..."
    "$SCRIPT_DIR/Scripts/CopyISOStructure.sh"
    
    # Handle GRUB splash disable option
    if [ $disable_grub_splash -eq 1 ]; then
        log "Disabling GRUB splash..."
        "$SCRIPT_DIR/Scripts/DisableSplash.sh"
    fi
    
    log "Copying filesystem with rsync..."
    "$SCRIPT_DIR/Scripts/CopyRootfs.sh"
    
    log "Installing Casper..."
    "$SCRIPT_DIR/Scripts/InstallCasper.sh"
    "$SCRIPT_DIR/Scripts/ConfigureCasper.sh"
    
    log "Installing additional packages..."
    "$SCRIPT_DIR/Scripts/InstallPackages.sh"
    
    log "Creating filesystem manifest..."
    "$SCRIPT_DIR/Scripts/CreateManifest.sh"
    
    log "Copying kernel and initrd..."
    "$SCRIPT_DIR/Scripts/CopyKernel.sh"
    
    # Setup Secure Boot if enabled
    if [ "$SECURE_BOOT" = "true" ]; then
        log "Setting up UEFI Secure Boot..."
        "$SCRIPT_DIR/Scripts/SetupSecureBoot.sh"
    fi
    
    if [ $use_chroot -eq 0 ]; then
        log "Entering chroot environment for customization..."
        "$SCRIPT_DIR/Scripts/ChrootShell.sh"
    fi
    
    log "Applying overlay files..."
    "$SCRIPT_DIR/Scripts/ApplyOverlay.sh"
    
    log "Creating squashfs filesystem..."
    "$SCRIPT_DIR/Scripts/CreateSquashfs.sh"
    
    log "Creating bootable ISO with GRUB..."
    "$SCRIPT_DIR/Scripts/CreateISO.sh"
    
    log "Live CD creation completed successfully!"
    log "ISO saved to: $ISO_NAME"
    
    if [[ "$CLI_MODE" == "true" ]]; then
        dialog --title "Success" --msgbox "Live CD created successfully!\n\nISO saved to:\n$ISO_NAME" 10 50 2>&1 >/dev/tty
    else
        "$SCRIPT_DIR/Scripts/zenity/success.sh" "Live CD created successfully!\n\nISO saved to:\n$ISO_NAME"
    fi
}

# Clean workspace
clean_workspace() {
    log "Cleaning workspace..."
    "$SCRIPT_DIR/Scripts/Clean.sh"
    if [[ "$CLI_MODE" == "true" ]]; then
        dialog --title "Success" --msgbox "Workspace cleaned successfully." 8 40 2>&1 >/dev/tty
    else
        "$SCRIPT_DIR/Scripts/zenity/success.sh" "Workspace cleaned successfully."
    fi
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
