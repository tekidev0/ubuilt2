#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy ISO files structure
echo "Copying ISO files structure..."
cp -r "$(dirname "${BASH_SOURCE[0]}")/../ISOFiles/"* "$ISO_FILES/"

# Substitute GRUB_DISTRIBUTION_NAME variable in grub.cfg
if [ -f "$ISO_FILES/boot/grub/grub.cfg" ]; then
    echo "Substituting GRUB_DISTRIBUTION_NAME in grub.cfg..."
    sed -i "s/\$GRUB_DISTRIBUTION_NAME/$GRUB_DISTRIBUTION_NAME/g" "$ISO_FILES/boot/grub/grub.cfg"
fi

echo "ISO structure copied successfully."
