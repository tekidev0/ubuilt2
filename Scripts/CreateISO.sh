#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Create bootable ISO with GRUB
echo "Creating bootable ISO with GRUB..."

# Change to ISO files directory
cd "$ISO"

# Create the ISO using grub-mkrescue
if [ "$SECURE_BOOT" = "true" ]; then
    echo "Creating ISO with UEFI Secure Boot support..."
    
    # Create unsigned ISO first
    grub-mkrescue -o "${ISO_NAME}.unsigned" "$ISO_FILES" --iso-level 3 -volid "$ISO_LABEL"
    
    # Sign the ISO for Secure Boot
    echo "Signing ISO for UEFI Secure Boot..."
    sbsigntool \
        --key "$SECURE_BOOT_KEY" \
        --cert "$SECURE_BOOT_CERT" \
        --output "$ISO_NAME" \
        "${ISO_NAME}.unsigned"
    
    # Remove unsigned ISO
    rm "${ISO_NAME}.unsigned"
    
    echo "ISO signed successfully for Secure Boot"
else
    grub-mkrescue -o "$ISO_NAME" "$ISO_FILES" --iso-level 3 -volid "$ISO_LABEL"
fi

# Generate checksums
echo "Generating checksums..."
cd "$ISO"
sha256sum "$(basename "$ISO_NAME")" > "$(basename "$ISO_NAME").sha256"
md5sum "$(basename "$ISO_NAME")" > "$(basename "$ISO_NAME").md5"

echo "Bootable ISO created successfully: $ISO_NAME"
echo "Checksums generated:"
echo "  SHA256: $(basename "$ISO_NAME").sha256"
echo "  MD5: $(basename "$ISO_NAME").md5"
