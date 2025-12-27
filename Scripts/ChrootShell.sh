#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")"/../work.conf
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

# Function to clean up on exit, even if the script fails (conditional based on chroot tool)
cleanup() {
    echo "Ensuring filesystems are unmounted..."
    # Use -l (lazy) to ensure it unmounts even if busy
    if needs_manual_binds "$CHROOT_CMD"; then
        umount -l "$ROOTFS/dev" 2>/dev/null || true
        umount -l "$ROOTFS/proc" 2>/dev/null || true
        umount -l "$ROOTFS/sys" 2>/dev/null || true
    else
        # arch-chroot handles unmounting automatically
        echo "arch-chroot handles unmounting automatically."
    fi
    rm -f "$ROOTFS/etc/resolv.conf"
    echo "Cleanup complete."
}

# Trap signals (like Ctrl+C or script exit)
trap cleanup EXIT

# Use rbind for dev to get all sub-nodes (only for chroot)
if needs_manual_binds "$CHROOT_CMD"; then
    mount --rbind /dev "$ROOTFS/dev"
else
    mount --bind /dev "$ROOTFS/dev"
fi
mount --bind /proc "$ROOTFS/proc"
mount --bind /sys "$ROOTFS/sys"

rm -f "$ROOTFS/etc/resolv.conf"
cat /etc/resolv.conf > "$ROOTFS/etc/resolv.conf"

echo "--- CHROOT SHELL ---"
echo "Customizing: $ROOTFS"
echo "Type 'exit' to finish."
echo ""

# Enter chroot
echo "Using chroot command: $CHROOT_CMD"
$CHROOT_CMD "$ROOTFS" /bin/bash

# The 'cleanup' function will now run automatically thanks to the trap