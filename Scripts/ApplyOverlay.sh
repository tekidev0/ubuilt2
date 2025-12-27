#!/bin/bash

# Apply overlay directory to RootFS using rsync

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../work.conf"

# Check if Overlay directory exists
OVERLAY_DIR="$SCRIPT_DIR/Overlay"
if [ ! -d "$OVERLAY_DIR" ]; then
    echo "Warning: Overlay directory not found at $OVERLAY_DIR"
    echo "Skipping overlay application."
    exit 0
fi

echo "Applying overlay from $OVERLAY_DIR to $ROOTFS..."

# Use rsync to copy everything from Overlay to RootFS
# -a: archive mode (preserves permissions, ownership, etc.)
# -v: verbose
rsync -av "$OVERLAY_DIR/" "$ROOTFS/"

echo "Overlay application completed successfully."
