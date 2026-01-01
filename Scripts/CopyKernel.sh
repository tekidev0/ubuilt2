#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy kernel and initrd from rootfs
echo "Copying kernel and initrd..."

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Copy kernel
echo "Looking for kernel files..."
KERNEL_VERSION=$(uname -r)
echo "Using current kernel version: $KERNEL_VERSION"

# Look for kernel in rootfs first, then fallback to host system
KERNEL_FILE=$(find "$ROOTFS/boot" -name "vmlinuz-$KERNEL_VERSION" -type f | head -1)
if [ -z "$KERNEL_FILE" ]; then
    echo "Kernel not found in rootfs, checking host system..."
    KERNEL_FILE="/boot/vmlinuz-$KERNEL_VERSION"
    if [ ! -f "$KERNEL_FILE" ]; then
        echo "ERROR: Kernel vmlinuz-$KERNEL_VERSION not found in rootfs or host system"
        exit 1
    fi
fi

echo "Found kernel: $KERNEL_FILE"

# Copy initrd - find matching version
echo "Looking for initrd files..."
# Try to find initrd with matching kernel version first
INITRD_FILE=$(find "$ROOTFS/boot" -name "initrd.img-$KERNEL_VERSION" -type f | head -1)

# If no exact match in rootfs, try host system
if [ -z "$INITRD_FILE" ]; then
    echo "No exact initrd match found in rootfs, checking host system..."
    INITRD_FILE="/boot/initrd.img-$KERNEL_VERSION"
    if [ ! -f "$INITRD_FILE" ]; then
        echo "No exact match found, searching for any initrd..."
        # Fallback to any initrd in rootfs
        INITRD_FILE=$(find "$ROOTFS/boot" -name "initrd*" -type f | head -1)
        if [ -z "$INITRD_FILE" ]; then
            # Final fallback to any initrd on host
            INITRD_FILE=$(find /boot -name "initrd*" -type f | head -1)
        fi
    fi
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
