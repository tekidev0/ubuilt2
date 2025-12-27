#!/bin/bash

# Create filesystem.manifest with package list

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

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Generate package list using dpkg-query for installed packages
echo "Creating filesystem.manifest with package list..."
if [ -d "$ROOTFS/var/lib/dpkg" ]; then
    if needs_manual_binds "$CHROOT_CMD"; then
        # Mount filesystems for chroot
        mount -o bind /dev $ROOTFS/dev
        mount -o bind /proc $ROOTFS/proc
        mount -o bind /sys $ROOTFS/sys
        
        # Copy resolv.conf for network access
        rm -f "$ROOTFS/etc/resolv.conf"
        cat /etc/resolv.conf > "$ROOTFS/etc/resolv.conf"
        
        # Generate package list
        chroot "$ROOTFS" /bin/bash -c "dpkg-query -W -f='\${Package} \${Version}\n' > /tmp/package_list" 2>/dev/null || true
        if [ -f "$ROOTFS/tmp/package_list" ]; then
            cat "$ROOTFS/tmp/package_list" > "$ISO_FILES/casper/filesystem.manifest"
            rm -f "$ROOTFS/tmp/package_list"
        fi
        
        # Unmount filesystems
        umount "$ROOTFS/dev"
        umount "$ROOTFS/proc"
        umount "$ROOTFS/sys"
        rm -f "$ROOTFS/etc/resolv.conf"
    else
        # arch-chroot handles mounting/unmounting automatically
        chroot "$ROOTFS" /bin/bash -c "dpkg-query -W -f='\${Package} \${Version}\n' > /tmp/package_list" 2>/dev/null || true
        if [ -f "$ROOTFS/tmp/package_list" ]; then
            cat "$ROOTFS/tmp/package_list" > "$ISO_FILES/casper/filesystem.manifest"
            rm -f "$ROOTFS/tmp/package_list"
        fi
    fi
fi

# Add casper entry
echo "casper" >> "$ISO_FILES/casper/filesystem.manifest"

echo "filesystem.manifest created successfully."
