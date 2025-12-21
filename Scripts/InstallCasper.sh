#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Mount filesystems
mount -o bind /dev $ROOTFS/dev
mount -o bind /proc $ROOTFS/proc
mount -o bind /sys $ROOTFS/sys

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
chroot $ROOTFS /bin/bash -c "apt update && apt install -y casper"

# Unmount filesystems
echo "Unmounting filesystems..."
umount $ROOTFS/dev
umount $ROOTFS/proc
umount $ROOTFS/sys

rm -f "$ROOTFS/etc/resolv.conf"

echo "Casper installed to rootfs."