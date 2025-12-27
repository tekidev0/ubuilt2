#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Create squashfs filesystem
echo "Creating squashfs filesystem..."
mksquashfs "$ROOTFS" "$ISO_FILES/casper/filesystem.squashfs" $SQUASHFS_OPTIONS

# Create filesystem size file
echo "Creating filesystem size file..."
echo $(($(du -s "$ROOTFS" | cut -f1) * 1024)) > "$ISO_FILES/casper/filesystem.size"

echo "Squashfs filesystem created successfully."
