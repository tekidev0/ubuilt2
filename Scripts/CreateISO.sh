#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Create bootable ISO with GRUB
echo "Creating bootable ISO with GRUB..."

# Change to ISO files directory
cd "$ISO"

# Create the ISO using grub-mkrescue
grub-mkrescue -o "$ISO_NAME" "$ISO_FILES" --iso-level 3

echo "Bootable ISO created successfully: $ISO_NAME"
