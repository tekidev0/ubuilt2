#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Create bootable ISO with GRUB
echo "Creating bootable ISO with GRUB..."

# Change to ISO files directory
cd "$ISO"

# Create the ISO using grub-mkrescue
grub-mkrescue -o "$ISO_NAME" "$ISO_FILES" --iso-level 3 -volid "$ISO_LABEL"

# Generate checksums
echo "Generating checksums..."
cd "$ISO"
sha256sum "$(basename "$ISO_NAME")" > "$(basename "$ISO_NAME" .iso).sha256"
md5sum "$(basename "$ISO_NAME")" > "$(basename "$ISO_NAME" .iso).md5"

echo "Bootable ISO created successfully: $ISO_NAME"
echo "Checksums generated:"
echo "  SHA256: $(basename "$ISO_NAME").sha256"
echo "  MD5: $(basename "$ISO_NAME").md5"
