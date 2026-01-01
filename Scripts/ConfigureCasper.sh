#!/bin/bash

# The issue in the previous version that it edited the casper.conf
# in the rootfs and not in the initrd.

set -e

source "$(dirname "${BASH_SOURCE[0]}")"/../work.conf
# CHROOT_CMD is now set by main script

# Configure casper
echo "Configuring casper..."

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Unpack initrd.img
mkdir -p "$ISO_FILES/casper/initrd-tmp"
echo "Unpacking initrd..."
unmkinitramfs "$ISO_FILES/casper/initrd.img" "$ISO_FILES/casper/initrd-tmp"

# Check the structure of the unpacked initrd
echo "Checking initrd structure..."
ls -la "$ISO_FILES/casper/initrd-tmp/"

# Check if original initrd was compressed
ORIGINAL_FORMAT=$(file "$ISO_FILES/casper/initrd.img")
echo "Original initrd format: $ORIGINAL_FORMAT"

# Create casper.conf for custom username and hostname
echo "Editing casper.conf..."
cat > "$ISO_FILES/casper/initrd-tmp/main/etc/casper.conf" << EOF
# This file should go in /etc/casper.conf
# Supported variables are:
# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM, FLAVOUR

export USERNAME="$CASPER_USERNAME"
export USERFULLNAME="Live session user"
export HOST="$CASPER_HOSTNAME"
export BUILD_SYSTEM="$GRUB_DISTRIBUTION_NAME"

# USERNAME and HOSTNAME as specified above won't be honoured and will be set to
# flavour string acquired at boot time, unless you set FLAVOUR to any
# non-empty string.

export FLAVOUR="$GRUB_DISTRIBUTION_NAME"
EOF

# Repack initrd
echo "Repacking initrd..."
cd "$ISO_FILES/casper/initrd-tmp"

# Modern initrd format with multiple segments
echo "Using modern initrd format with multiple segments"

# Start with early segment (uncompressed)
echo "Packing early segment..."
cd early
find . -print0 | cpio --null --create --format=newc > "$ISO_FILES/casper/new-initrd.img"
cd ..

# Add early2 segment (uncompressed)
if [ -d "early2" ]; then
    echo "Packing early2 segment..."
    cd early2
    find . -print0 | cpio --null --create --format=newc >> "$ISO_FILES/casper/new-initrd.img"
    cd ..
fi

# Add early3 segment (uncompressed)
if [ -d "early3" ]; then
    echo "Packing early3 segment..."
    cd early3
    find . -print0 | cpio --null --create --format=newc >> "$ISO_FILES/casper/new-initrd.img"
    cd ..
fi

# Add main segment (compressed with zstd if available, otherwise gzip)
echo "Packing main segment..."
cd main
if command -v zstd &> /dev/null; then
    # Use Zstandard for modern Ubuntu versions (24.04, 25.04, etc.)
    echo "Using zstd compression for main segment..."
    find . | cpio --quiet -o -H newc | zstd -19 >> "$ISO_FILES/casper/new-initrd.img"
else
    # If not available, fall back to gzip (GNU zip)
    echo "Using gzip compression for main segment..."
    find . | cpio --quiet -o -H newc | gzip -c >> "$ISO_FILES/casper/new-initrd.img"
fi
cd -

# Remove the old initrd
echo "Removing the old initrd..."
rm "$ISO_FILES/casper/initrd.img"

# Rename the new initrd
echo "Renaming the new initrd..."
mv "$ISO_FILES/casper/new-initrd.img" "$ISO_FILES/casper/initrd.img"

# Remove the temporary directory
echo "Removing the temporary directory..."
rm -rf "$ISO_FILES/casper/initrd-tmp"

echo "Casper configuration completed."
