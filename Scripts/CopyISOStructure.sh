#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy ISO files structure
echo "Copying ISO files structure..."
cp -r "$(dirname "${BASH_SOURCE[0]}")/../ISOFiles/"* "$ISO_FILES/"

echo "ISO structure copied successfully."
