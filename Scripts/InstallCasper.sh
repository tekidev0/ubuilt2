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

# Mount filesystems (conditional based on chroot tool)
if needs_manual_binds "$CHROOT_CMD"; then
    mount -o bind /dev $ROOTFS/dev
    mount -o bind /proc $ROOTFS/proc
    mount -o bind /sys $ROOTFS/sys
else
    # arch-chroot handles mounts automatically
    :
fi

# Copy resolv.conf contents (handle symlink case)
# Remove the existing symlink and create a real file with current DNS config
rm -f "$ROOTFS/etc/resolv.conf"
if [ -L /etc/resolv.conf ]; then
    # Host has symlink, read the actual content and write it
    cat /etc/resolv.conf > "$ROOTFS/etc/resolv.conf"
else
    # Host has regular file, copy it normally
    cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"
fi

# Install Casper to rootfs
echo "Installing Casper to rootfs..."
echo "Using chroot command: $CHROOT_CMD"
$CHROOT_CMD $ROOTFS /bin/bash -c "apt update && apt install -y casper"

# Unmount filesystems (conditional based on chroot tool)
echo "Unmounting filesystems..."
if needs_manual_binds "$CHROOT_CMD"; then
    umount $ROOTFS/dev
    umount $ROOTFS/proc
    umount $ROOTFS/sys
else
    # arch-chroot handles unmounting automatically
    echo "arch-chroot handles unmounting automatically."
fi

rm -f "$ROOTFS/etc/resolv.conf"

echo "Casper installed to rootfs."