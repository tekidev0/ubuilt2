#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Check if the work directory exists
if [ ! -d "$WORK" ]; then
    echo "Work directory does not exist. You still can build the ISO."
    exit 0
fi

# Remove work directories
rm -rf "$WORK"
echo "Work directory removed successfully."