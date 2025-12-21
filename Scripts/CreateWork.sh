#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Check if the directories are created
if [ -d "$WORK" ]; then
    echo "Work directory already exists. Please clean up and try again."
    exit 1
fi

# Create work directories
echo "Creating work directories..."
mkdir -p "$WORK" "$ISO" "$ISO_FILES" "$ROOTFS"
echo "Work directories created successfully."