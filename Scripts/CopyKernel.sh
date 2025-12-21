#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy kernel and initrd from rootfs
echo "Copying kernel and initrd..."

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Copy kernel
echo "Looking for kernel files..."
KERNEL_FILE=$(find "$ROOTFS/boot" -name "vmlinuz*" -type f | head -1)
if [ -n "$KERNEL_FILE" ]; then
    echo "Found kernel: $KERNEL_FILE"
    cp "$KERNEL_FILE" "$ISO_FILES/casper/vmlinuz"
else
    echo "ERROR: No kernel file found in $ROOTFS/boot"
    exit 1
fi

# Copy initrd
echo "Looking for initrd files..."
INITRD_FILE=$(find "$ROOTFS/boot" -name "initrd*" -type f | head -1)
if [ -n "$INITRD_FILE" ]; then
    echo "Found initrd: $INITRD_FILE"
    cp "$INITRD_FILE" "$ISO_FILES/casper/initrd.img"
else
    echo "ERROR: No initrd file found in $ROOTFS/boot"
    exit 1
fi

# Verify kernel and initrd exist
if [ ! -f "$ISO_FILES/casper/vmlinuz" ] || [ ! -f "$ISO_FILES/casper/initrd.img" ]; then
    echo "ERROR: Kernel or initrd not found. Please ensure your system has a kernel installed."
    exit 1
fi

echo "Kernel and initrd copied successfully."
