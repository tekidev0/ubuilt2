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
    
    # Extract kernel version from filename
    KERNEL_VERSION=$(basename "$KERNEL_FILE" | sed 's/vmlinuz-//')
    echo "Kernel version: $KERNEL_VERSION"
    
    cp "$KERNEL_FILE" "$ISO_FILES/casper/vmlinuz"
else
    echo "ERROR: No kernel file found in $ROOTFS/boot"
    exit 1
fi

# Copy initrd - find matching version
echo "Looking for initrd files..."
# Try to find initrd with matching kernel version first
INITRD_FILE=$(find "$ROOTFS/boot" -name "initrd.img-$KERNEL_VERSION" -type f | head -1)

# If no exact match, try broader search
if [ -z "$INITRD_FILE" ]; then
    echo "No exact initrd match found, searching for any initrd..."
    INITRD_FILE=$(find "$ROOTFS/boot" -name "initrd*" -type f | head -1)
fi

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
