#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Function to clean up on exit, even if the script fails
cleanup() {
    echo "Ensuring filesystems are unmounted..."
    # Use -l (lazy) to ensure it unmounts even if busy
    umount -l "$ROOTFS/dev" 2>/dev/null || true
    umount -l "$ROOTFS/proc" 2>/dev/null || true
    umount -l "$ROOTFS/sys" 2>/dev/null || true
    rm -f "$ROOTFS/etc/resolv.conf"
    echo "Cleanup complete."
}

# Trap signals (like Ctrl+C or script exit)
trap cleanup EXIT

# Use rbind for dev to get all sub-nodes
mount --rbind /dev "$ROOTFS/dev"
mount --bind /proc "$ROOTFS/proc"
mount --bind /sys "$ROOTFS/sys"

rm -f "$ROOTFS/etc/resolv.conf"
cat /etc/resolv.conf > "$ROOTFS/etc/resolv.conf"

echo "--- CHROOT SHELL ---"
echo "Customizing: $ROOTFS"
echo "Type 'exit' to finish."
echo ""

# Enter chroot
chroot "$ROOTFS" /bin/bash

# The 'cleanup' function will now run automatically thanks to the trap