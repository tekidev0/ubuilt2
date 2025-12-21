#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy filesystem with rsync using exclude list
echo "Copying filesystem with rsync..."
rsync -avh --ignore-missing-args --exclude-from="$(dirname "${BASH_SOURCE[0]}")/../rsync-exclude.txt" / "$ROOTFS"

echo "Filesystem copied successfully."
