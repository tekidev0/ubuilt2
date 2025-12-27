#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")"/../work.conf
# CHROOT_CMD is now set by main script

# Configure casper
echo "Configuring casper..."

# Create casper directory if it doesn't exist
mkdir -p "$ISO_FILES/casper"

# Create casper.conf for custom username and hostname
cat > "$ROOTFS/etc/casper.conf" << EOF
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

echo "Casper configuration completed."
