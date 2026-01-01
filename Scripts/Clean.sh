#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Check if the work directory exists
if [ ! -d "$WORK" ]; then
    echo "Work directory does not exist. You still can build the ISO."
    sleep 2
    exit 0
fi

# Auto-unmount any mounted filesystems
echo "Checking for mounted filesystems..."

# Unmount common mount points that might be in use during build
for mount_point in "$ROOTFS" "$ROOTFS/dev" "$ROOTFS/proc" "$ROOTFS/sys" "$ROOTFS/run" "$ROOTFS/dev/pts"; do
    if mountpoint -q "$mount_point" 2>/dev/null; then
        echo "Unmounting $mount_point..."
        umount "$mount_point" 2>/dev/null || {
            echo "Warning: Failed to unmount $mount_point, trying lazy unmount..."
            umount -l "$mount_point" 2>/dev/null || echo "Error: Could not unmount $mount_point"
        }
    fi
done

# Check for any remaining bind mounts or loop devices
echo "Checking for loop devices..."
for loop_dev in $(losetup -a | grep -o "^/dev/loop[0-9]*" | sort -u); do
    if losetup -l "$loop_dev" 2>/dev/null | grep -q "$WORK"; then
        echo "Detaching loop device $loop_dev..."
        losetup -d "$loop_dev" 2>/dev/null || echo "Warning: Failed to detach $loop_dev"
    fi
done

# Remove work directories
echo "Removing work directories..."
rm -rf "$WORK"
echo "Work directory removed successfully."