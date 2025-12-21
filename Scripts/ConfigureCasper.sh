#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Configure casper
echo "Configuring casper..."

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Create casper configuration
echo "Ubuilt Live CD" > "$ISO_FILES/casper/filesystem.manifest"
echo "casper" >> "$ISO_FILES/casper/filesystem.manifest"

echo "Casper configuration completed."
