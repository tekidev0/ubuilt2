#!/bin/bash

# Install packages in the live system from PACKAGES variable

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../work.conf"
# CHROOT_CMD is now set by main script

# Function to check if manual binds are needed (arch-chroot doesn't need them)
needs_manual_binds() {
    local chroot_cmd="$1"
    if [ "$chroot_cmd" = "arch-chroot" ]; then
        return 1  # arch-chroot doesn't need manual binds
    else
        return 0  # chroot needs manual binds
    fi
}

# Check if PACKAGES is empty
if [ -z "$PACKAGES" ]; then
    echo "No packages specified in PACKAGES variable. Skipping package installation."
    exit 0
fi

echo "Installing packages: $PACKAGES"

# Check if we're in chroot environment
if [ -f "/etc/debian_chroot" ]; then
    # We're in chroot, install packages directly
    apt update
    apt install -y $PACKAGES
else
    # We need to chroot to install packages
    if [ ! -d "$ROOTFS" ]; then
        echo "Error: ROOTFS directory not found at $ROOTFS"
        exit 1
    fi
    
    # Mount necessary filesystems for chroot (conditional based on chroot tool)
    if needs_manual_binds "$CHROOT_CMD"; then
        mount -o bind /dev "$ROOTFS/dev"
        mount -o bind /proc "$ROOTFS/proc"
        mount -o bind /sys "$ROOTFS/sys"
        mount -o bind /dev/pts "$ROOTFS/dev/pts"
    else
        # arch-chroot handles mounts automatically
        :
    fi
    
    # Copy resolv.conf for network access
    cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"
    
    # Chroot and install packages
    echo "Using chroot command: $CHROOT_CMD"
    $CHROOT_CMD "$ROOTFS" /bin/bash -c "apt update && apt install -y $PACKAGES"
    
    # Cleanup (conditional based on chroot tool)
    rm -f "$ROOTFS/etc/resolv.conf"
    if needs_manual_binds "$CHROOT_CMD"; then
        umount "$ROOTFS/dev/pts"
        umount "$ROOTFS/dev"
        umount "$ROOTFS/sys"
        umount "$ROOTFS/proc"
    else
        # arch-chroot handles unmounting automatically
        echo "arch-chroot handles unmounting automatically."
    fi
fi

echo "Package installation completed successfully."
