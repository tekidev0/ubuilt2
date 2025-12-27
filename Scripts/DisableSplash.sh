#!/bin/bash

# Disable GRUB splash screen

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../work.conf"

echo "Disabling GRUB splash..."

# Remove background_image line from grub.cfg
if [ -f "$ISO_FILES/boot/grub/grub.cfg" ]; then
    sed -i '/^background_image/d' "$ISO_FILES/boot/grub/grub.cfg"
    echo "Removed background_image line from grub.cfg"
else
    echo "Warning: grub.cfg not found at $ISO_FILES/boot/grub/grub.cfg"
fi

# Remove bootlogo.png file if it exists
if [ -f "$ISO_FILES/boot/grub/bootlogo.png" ]; then
    rm -f "$ISO_FILES/boot/grub/bootlogo.png"
    echo "Removed bootlogo.png file"
else
    echo "Warning: bootlogo.png not found at $ISO_FILES/boot/grub/bootlogo.png"
fi

echo "GRUB splash disabled successfully."
